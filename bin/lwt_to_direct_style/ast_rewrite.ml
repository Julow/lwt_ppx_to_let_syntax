open Ocamlformat_utils.Parsing
open Asttypes
open Parsetree
open Ast_helper
open Ocamlformat_utils.Ast_utils
module Occ = Migrate_utils.Occ

let add_comment state ?loc text =
  Migrate_utils.add_comment state ?loc ("TODO: lwt-to-direct-style: " ^ text)

let is_unit_pat = function
  | { ppat_desc = Ppat_construct ({ txt = Lident "()"; _ }, None); _ } -> true
  | _ -> false

(* Rewrite a continuation to a let binding, a match or an apply. *)
let rewrite_continuation cont ~arg:cont_arg =
  let get =
    match cont.pexp_desc with
    | _ when cont.pexp_attributes <> [] -> `Apply
    | Pexp_function
        ( [ { pparam_desc = Pparam_val (Nolabel, None, arg_pat); _ } ],
          None,
          Pfunction_body body ) ->
        if is_unit_pat arg_pat then `Seq body else `Let (arg_pat, body)
    | Pexp_function ([], None, Pfunction_cases (cases, _loc, [])) ->
        `Match cases
    | _ -> `Apply
  in
  match get with
  | `Let (arg_pat, body) -> mk_let arg_pat cont_arg body
  | `Match cases -> Exp.match_ cont_arg cases
  | `Seq rhs -> Exp.sequence cont_arg rhs
  | `Apply -> Exp.apply cont [ (Nolabel, cont_arg) ]

let rewrite_exp_into_cases = function
  | {
      pexp_desc = Pexp_function ([], None, Pfunction_cases (cases, _, []));
      pexp_attributes = [];
      _;
    } ->
      cases
  | {
      pexp_desc =
        Pexp_function
          ( [ { pparam_desc = Pparam_val (Nolabel, None, arg_pat); _ } ],
            None,
            Pfunction_body body );
      pexp_attributes = [];
      _;
    } ->
      [ Exp.case arg_pat body ]
  | exp ->
      [
        Exp.case
          (Pat.var (mk_loc "v"))
          (Exp.apply exp [ (Nolabel, mk_exp_var "v") ]);
      ]

(* Like [rewrite_exp_into_cases] but also remove the catch-all case that calls
   [Lwt.reraise]. *)
let rewrite_exp_into_cases_no_reraise ~state exn_f =
  rewrite_exp_into_cases exn_f
  |> List.filter_map (fun case ->
         match case.pc_rhs.pexp_desc with
         (* Drop cases doing just a [Lwt.reraise]. *)
         | Pexp_apply
             ({ pexp_desc = Pexp_ident lid; pexp_attributes = []; _ }, [ _ ])
           when same_longident lid.txt [ "Lwt"; "reraise" ] ->
             Occ.remove state lid;
             None
         | _ -> Some case)

let rewrite_try_bind ~state thunk value_f exn_f =
  let body =
    match thunk with
    | {
     pexp_desc = Pexp_function ([ _ ], None, Pfunction_body body);
     pexp_attributes = [];
     _;
    } ->
        body
    | _ -> Exp.apply thunk [ (Nolabel, mk_unit_val) ]
  and value_cases = rewrite_exp_into_cases value_f
  and exn_cases =
    rewrite_exp_into_cases_no_reraise ~state exn_f
    |> List.map (fun case -> { case with pc_lhs = Pat.exception_ case.pc_lhs })
  in
  Exp.match_ body (value_cases @ exn_cases)

(* Call a [unit -> 'a] function. If [exp] is a [fun] expression, it is
   simplified. *)
let call_thunk thunk =
  match thunk.pexp_desc with
  | Pexp_function ([ _ ], None, Pfunction_body body) -> body
  | _ -> Exp.apply thunk [ (Nolabel, mk_unit_val) ]

(* Suspend an expression into a thunk. Some expressions cannot be suspended this
   way and a "TODO" comment is generated to indicate that the program is changed
   in an undefined way. *)
let suspend ~state exp =
  let is_suspended =
    match exp.pexp_desc with
    | Pexp_ident _ -> false
    | Pexp_apply _ -> true
    | _ -> false
  in
  if not is_suspended then
    add_comment state ~loc:exp.pexp_loc
      "This computation might not be suspended correctly.";
  match exp.pexp_desc with
  | Pexp_apply (f_exp, [ (Nolabel, arg) ]) when is_unit_val arg -> f_exp
  | _ -> mk_thunk exp

(* The expression [lst] hoping that it is a literal list and suspend its
   elements. *)
let suspend_list ~state lst =
  match lst.pexp_desc with
  | Pexp_list exprs ->
      { lst with pexp_desc = Pexp_list (List.map (suspend ~state) exprs) }
  | _ ->
      add_comment state ~loc:lst.pexp_loc
        "This expression is a ['a Lwt.t list] but a [(unit -> 'a) list] is \
         expected.";
      lst

let rewrite_lwt_both ~backend ~state left right =
  Some (backend#both ~left:(suspend ~state left) ~right:(suspend ~state right))

let rewrite_lwt_condition_wait ~backend ~state mutex_opt cond =
  let mutex =
    match mutex_opt with
    | Some (m, `Lbl) -> m
    | Some (m, `Opt) ->
        add_comment state "[mutex] shouldn't be an option.";
        mk_apply_simple [ "Option"; "get" ] [ m ]
    | None ->
        add_comment state "A mutex must be passed";
        mk_exp_ident [ "__mutex__" ]
  in
  backend#condition_wait mutex cond

let mk_cstr c = Some (mk_constr_exp c)

(* Rewrite calls to functions from the [Lwt] module. See [rewrite_apply] for
   the other modules. *)
let rewrite_apply_lwt ~backend ~state ident args =
  let open Unpack_apply in
  unapply args
  @@
  match ident with
  (* Control flow *)
  | "bind" ->
      take @@ fun promise_arg ->
      take @@ fun fun_arg ->
      return (Some (rewrite_continuation fun_arg ~arg:promise_arg))
  | "map" ->
      take @@ fun fun_arg ->
      take @@ fun promise_arg ->
      return (Some (rewrite_continuation fun_arg ~arg:promise_arg))
  | "try_bind" ->
      take @@ fun thunk ->
      take @@ fun value_f ->
      take @@ fun exn_f ->
      return (Some (rewrite_try_bind ~state thunk value_f exn_f))
  | "catch" ->
      take @@ fun thunk ->
      take @@ fun exn_f ->
      return
        (Some
           (Exp.try_ (call_thunk thunk)
              (rewrite_exp_into_cases_no_reraise ~state exn_f)))
  | "finalize" ->
      take @@ fun f ->
      take @@ fun finally_f ->
      return
        (Some
           (Exp.apply
              (mk_exp_ident [ "Fun"; "protect" ])
              [ (Labelled (mk_loc "finally"), finally_f); (Nolabel, f) ]))
  (* Async composition *)
  | "both" ->
      take @@ fun left ->
      take @@ fun right -> return (rewrite_lwt_both ~backend ~state left right)
  | "pick" ->
      take @@ fun lst -> return (Some (backend#pick (suspend_list ~state lst)))
  | "choose" ->
      take @@ fun _lst ->
      add_comment state
        ("[Lwt.choose] can't be automatically translated."
       ^ backend#choose_comment_hint);
      return None
  | "join" ->
      take @@ fun lst -> return (Some (backend#join (suspend_list ~state lst)))
  (* Async primitives *)
  | "async" -> take @@ fun process_f -> return (Some (backend#async process_f))
  | "pause" -> take @@ fun _unit -> return (Some (backend#pause ()))
  | "wait" -> take @@ fun _unit -> return (Some (backend#wait ()))
  | "wakeup" | "wakeup_later" ->
      take @@ fun u ->
      take @@ fun arg -> return (Some (backend#wakeup u arg))
  | "ignore_result" ->
      take @@ fun p -> return (Some (backend#async (suspend ~state p)))
  | "task" ->
      add_comment state backend#cancel_message;
      take @@ fun _unit -> return (Some (backend#wait ()))
  | "cancel" | "no_cancel" | "protected" | "on_cancel" | "wrap_in_cancelable" ->
      add_comment state backend#cancel_message;
      return None
  | "state" -> take @@ fun p -> return (Some (backend#state p))
  (* Return *)
  | "return" -> take @@ fun value_arg -> return (Some value_arg)
  | "return_some" ->
      take @@ fun value_arg ->
      return (Some (mk_constr_exp ~arg:value_arg "Some"))
  | "return_ok" ->
      take @@ fun value_arg -> return (Some (mk_constr_exp ~arg:value_arg "Ok"))
  | "return_error" ->
      take @@ fun value_arg ->
      return (Some (mk_constr_exp ~arg:value_arg "Error"))
  | "return_unit" -> return (mk_cstr "()")
  | "return_none" -> return (mk_cstr "None")
  | "return_nil" -> return (mk_cstr "[]")
  | "return_true" -> return (mk_cstr "true")
  | "return_false" -> return (mk_cstr "false")
  | "fail" ->
      take @@ fun exn -> return (Some (mk_apply_simple [ "raise" ] [ exn ]))
  | "fail_with" ->
      take @@ fun msg -> return (Some (mk_apply_simple [ "failwith" ] [ msg ]))
  | "fail_invalid_arg" ->
      take @@ fun msg ->
      return (Some (mk_apply_simple [ "invalid_arg" ] [ msg ]))
  (* Keys *)
  | "new_key" -> take @@ fun _unit -> return (Some (backend#key_new ()))
  | "get" -> take @@ fun key -> return (Some (backend#key_get key))
  | "with_value" ->
      take @@ fun key ->
      take @@ fun val_opt ->
      take @@ fun f -> return (Some (backend#key_with_value key val_opt f))
  (* Operators *)
  | ">>=" | ">|=" ->
      take @@ fun lhs ->
      take @@ fun rhs -> return (Some (rewrite_continuation rhs ~arg:lhs))
  | "=<<" | "=|<" ->
      take @@ fun lhs ->
      take @@ fun rhs -> return (Some (rewrite_continuation lhs ~arg:rhs))
  | "<&>" ->
      take @@ fun lhs ->
      take @@ fun rhs -> return (rewrite_lwt_both ~backend ~state lhs rhs)
  | "<?>" ->
      take @@ fun _lhs ->
      take @@ fun _rhs ->
      add_comment state
        ("[<?>] can't be automatically translated."
       ^ backend#choose_comment_hint);
      return None
  | _ -> return None

let string_drop_suffix ~suffix s =
  if String.ends_with ~suffix s then
    Some (String.sub s 0 (String.length s - String.length suffix))
  else None

let rewrite_apply ~backend ~state full_ident args =
  let open Unpack_apply in
  let ( >>= ) = Option.bind in
  let transparent ident =
    take_all (fun args -> Some (mk_apply_ident ident args))
  in
  unapply args
  @@
  match full_ident with
  | "Lwt", ident ->
      take_all @@ fun args -> rewrite_apply_lwt ~backend ~state ident args
  | ( "Lwt_fmt",
      (( "printf" | "eprintf" | "stdout" | "stderr" | "fprintf" | "kfprintf"
       | "ifprintf" | "ikfprintf" ) as ident) ) ->
      transparent [ "Format"; ident ]
  | "Lwt_list", ident -> (
      match string_drop_suffix ~suffix:"_s" ident with
      | Some ident -> transparent [ "List"; ident ]
      | None -> (
          match
            string_drop_suffix ~suffix:"_p" ident >>= fun ident ->
            backend#list_parallel ident
          with
          | Some ident -> transparent ident
          | None -> return None))
  | "Lwt_unix", "sleep" -> take @@ fun d -> return (Some (backend#sleep d))
  | "Lwt_unix", "with_timeout" ->
      take @@ fun d ->
      take @@ fun f -> return (Some (backend#with_timeout d f))
  | "Lwt_condition", "create" ->
      take @@ fun _unit -> return (Some (backend#condition_create ()))
  | "Lwt_condition", "wait" ->
      take_lblopt "mutex" @@ fun mutex ->
      take @@ fun cond ->
      return (Some (rewrite_lwt_condition_wait ~backend ~state mutex cond))
  | "Lwt_mutex", "create" ->
      take @@ fun _unit -> return (Some (backend#mutex_create ()))
  | "Lwt_mutex", "lock" -> take @@ fun t -> return (Some (backend#mutex_lock t))
  | "Lwt_mutex", "unlock" ->
      take @@ fun t -> return (Some (backend#mutex_unlock t))
  | "Lwt_mutex", "with_lock" ->
      take @@ fun t ->
      take @@ fun f -> return (Some (backend#mutex_with_lock t f))
  | _ -> return None

(** Transform a [binding_op] into a [pattern] and an [expression] while
    preserving the type annotation. *)
let split_binding_op ~state pb =
  let exp =
    match pb.pbop_args with
    | [] -> pb.pbop_exp
    | args -> Exp.function_ args None (Pfunction_body pb.pbop_exp)
  and pat =
    match pb.pbop_typ with
    | Some (Pvc_constraint { typ; locally_abstract_univars = [] }) ->
        Pat.constraint_ pb.pbop_pat typ
    | Some _ ->
        add_comment state ~loc:pb.pbop_pat.ppat_loc
          "Type annotation was lost during transformation.";
        pb.pbop_pat
    | None -> pb.pbop_pat
  in
  (pat, exp)

let rewrite_letop ~backend ~state let_ ands body = function
  | "Lwt", ("let*" | "let+") -> (
      match ands with
      | [] ->
          Some
            (mk_let ~is_pun:let_.pbop_is_pun ?value_constraint:let_.pbop_typ
               let_.pbop_pat ~args:let_.pbop_args let_.pbop_exp body)
      | _ :: _ ->
          List.iter (fun and_ -> Occ.remove state and_.pbop_op) ands;
          let let_pat, let_exp = split_binding_op ~state let_
          and ands_pats, ands_exps =
            List.map (split_binding_op ~state) ands |> List.split
          in
          let pat =
            List.fold_right (fun a b -> Pat.tuple [ a; b ]) ands_pats let_pat
          and exp =
            List.fold_right
              (fun a b -> backend#both ~left:a ~right:b)
              ands_exps let_exp
          in
          Some (mk_let pat exp body))
  | _ -> None

let rewrite_expression ~backend ~state exp =
  (* Flatten pipelines before applying rewrites. *)
  match (flatten_apply exp).pexp_desc with
  (* Rewrite a call to a [Lwt] function. *)
  | Pexp_apply ({ pexp_desc = Pexp_ident lid; _ }, args) ->
      Occ.may_rewrite state lid (fun ident ->
          rewrite_apply ~backend ~state ident args)
  (* Rewrite the use of a [Lwt] infix operator. *)
  | Pexp_infix (op, lhs, rhs) ->
      let args = [ (Nolabel, lhs); (Nolabel, rhs) ] in
      Occ.may_rewrite state op (fun op -> rewrite_apply ~backend ~state op args)
  (* Rewrite expressions such as [Lwt.return_unit], but also any partially
     applied [Lwt] function. *)
  | Pexp_ident lid ->
      Occ.may_rewrite state lid (fun ident ->
          rewrite_apply ~backend ~state ident [])
  (* Simple [let*]. *)
  | Pexp_letop { let_; ands; body; _ } ->
      Occ.may_rewrite state let_.pbop_op
        (rewrite_letop ~backend ~state let_ ands body)
  | _ -> None

let rewrite_pattern ~backend ~state pat =
  match pat.ppat_desc with
  | Ppat_construct (lid, arg) ->
      Occ.may_rewrite state lid (fun ident ->
          match (ident, arg) with
          | ("Lwt_unix", "Timeout"), None -> Some backend#timeout_exn
          | ("Lwt", "Return"), arg -> Some (Pat.construct mk_some_ident arg)
          | ("Lwt", "Sleep"), arg -> Some (Pat.construct mk_none_ident arg)
          | ("Lwt", "Fail"), Some _ ->
              add_comment state ~loc:lid.loc "[Lwt.Fail] shouldn't be used";
              None
          | _ -> None)
  | _ -> None

(** The return type of a function is transformed into the direct-style type
    instead of the promise type. *)
let rewrite_type_rhs ~backend ~state typ =
  match typ.ptyp_desc with
  | Ptyp_constr (lid, params) ->
      Occ.may_rewrite state lid (fun ident ->
          match (ident, params) with
          | ("Lwt", "t"), [ param ] -> Some (backend#direct_style_type param)
          | _ -> None)
  | _ -> None

let rewrite_type ~backend ~state typ =
  match typ.ptyp_desc with
  | Ptyp_arrow (params, ret) -> (
      match rewrite_type_rhs ~backend ~state ret with
      | Some ret -> Some (Typ.arrow params ret)
      | None -> None)
  | Ptyp_constr (lid, params) ->
      Occ.may_rewrite state lid (fun ident ->
          match (ident, params) with
          | ("Lwt", "t"), [ param ] -> Some (backend#promise_type param)
          | ("Lwt_condition", "t"), [ param ] ->
              Some (backend#condition_type param)
          | _ -> None)
  | _ -> None

let remove_lwt_opens ~state stri =
  match stri.pstr_desc with
  | Pstr_open { popen_expr = { pmod_desc = Pmod_ident lid; _ }; _ }
    when Occ.pop state lid ->
      false
  | _ -> true

let add_extra_opens ~backend str =
  let extra_opens =
    List.fold_left
      (fun extra_opens stri ->
        match stri.pstr_desc with
        | Pstr_open { popen_expr = { pmod_desc = Pmod_ident opn_ident; _ }; _ }
          ->
            List.filter (( <> ) opn_ident.txt) extra_opens
        | _ -> extra_opens)
      backend#extra_opens str
    |> List.map (fun ident -> Str.open_ (Opn.mk (Mod.ident (mk_loc ident))))
  in
  extra_opens @ str

let mapper ~backend ~state =
  let default = Ast_mapper.default_mapper in
  let rec call_rewrite ~default ~loc f m x =
    Migrate_utils.set_default_comment_loc state loc;
    (* Apply the rewrite again if it succeed *)
    match f x with
    | Some x -> call_rewrite ~default ~loc f m x
    | None -> default m x
  in
  let expr m x =
    call_rewrite ~default:default.expr ~loc:x.pexp_loc
      (rewrite_expression ~backend ~state)
      m x
  and pat m x =
    call_rewrite ~default:default.pat ~loc:x.ppat_loc
      (rewrite_pattern ~backend ~state)
      m x
  and typ m x =
    call_rewrite ~default:default.typ ~loc:x.ptyp_loc
      (rewrite_type ~backend ~state)
      m x
  in
  let structure m str =
    default.structure m (List.filter (remove_lwt_opens ~state) str)
  in
  { default with expr; pat; typ; structure }

let rewrite_lwt_uses ~fname:_ ~(backend : (string -> unit) -> _) =
  let structure state str =
    let backend = backend (add_comment state) in
    let m = mapper ~backend ~state in
    let str = m.structure m str in
    add_extra_opens ~backend str
  in
  let signature state sg =
    let backend = backend (add_comment state) in
    let m = mapper ~backend ~state in
    m.signature m sg
  in
  { Migrate_utils.structure; signature }
