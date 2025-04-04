open Ocamlformat_utils.Parsing
open Parsetree

module Loc = struct
  type t = {
    line : int;
    col : int;
    len : int; [@warning "-69"]
        (* Silent unused-field warning. This field is used implicitly by
         polymorphic compare in [Hashtbl]. *)
  }
  (** Remove information from the [Location.t] to avoid problems with different
      filenames due to custom Dune rules and offset positions due to PPXes. *)

  let of_location { Location.loc_start; loc_end; _ } =
    {
      line = loc_start.pos_lnum;
      col = loc_start.pos_cnum - loc_start.pos_bol;
      len = loc_end.pos_cnum - loc_start.pos_cnum;
    }

  let pp ppf loc = Format.fprintf ppf "line %d column %d" loc.line (loc.col + 1)
end

type state = {
  occ : (Loc.t, string * string) Hashtbl.t;
  mutable comments : Ocamlformat_utils.Cmt.t list;
  mutable comment_default_loc : Location.t;
}

let add_comment state ?(loc = state.comment_default_loc) text =
  let cmt = " " ^ text ^ " " in
  state.comments <-
    Ocamlformat_utils.Cmt.create_comment cmt loc :: state.comments

let set_default_comment_loc state loc = state.comment_default_loc <- loc

module Occ = struct
  open Location

  let init lids =
    let new_tbl = Hashtbl.create (List.length lids) in
    List.iter
      (fun (ident, lid) ->
        Hashtbl.replace new_tbl (Loc.of_location lid.loc) ident)
      lids;
    new_tbl

  let remove state lid = Hashtbl.remove state.occ (Loc.of_location lid.loc)

  let pop state lid =
    if Hashtbl.mem state.occ (Loc.of_location lid.loc) then (
      remove state lid;
      true)
    else false

  let may_rewrite state lid f =
    match Hashtbl.find_opt state.occ (Loc.of_location lid.loc) with
    | Some ident ->
        let r = f ident in
        if Option.is_some r then remove state lid;
        r
    | None -> None

  (** Warn about locations that have not been rewritten so far. *)
  let warn_missing_locs state fname =
    let missing = Hashtbl.length state.occ in
    if missing > 0 then (
      Format.eprintf "Warning: %s: %d occurrences have not been rewritten.@\n"
        fname missing;
      Hashtbl.fold
        (fun loc (unit_name, ident) acc ->
          (loc, unit_name ^ "." ^ ident) :: acc)
        state.occ []
      |> List.sort compare (* Sort for a reproducible output. *)
      |> List.iter (fun (loc, ident) ->
             Format.eprintf "  %s (%a)@\n" ident Loc.pp loc);
      Format.eprintf "%!")
end

type modify_ast = {
  structure : state -> structure -> structure;
  signature : state -> signature -> signature;
}

let make_modify_ast ~modify_ast ~fname occurrences =
  let modify_ast = modify_ast ~fname in
  let rewrite f x =
    let state =
      {
        occ = Occ.init occurrences;
        comments = [];
        comment_default_loc = Location.none;
      }
    in
    let r = f state x in
    Occ.warn_missing_locs state fname;
    (r, state.comments)
  in
  {
    Ocamlformat_utils.structure = rewrite modify_ast.structure;
    signature = rewrite modify_ast.signature;
  }

let errorf fmt = Format.kasprintf (fun msg -> Error (`Msg msg)) fmt

(** Map from file names to their path. This is used when locations point to the
    wrong path (eg. it only contains the basename), which is often the case with
    [.eliom] files. *)
let lookup_filename_map () =
  let tbl = Hashtbl.create 64 in
  Fs_utils.find_ml_files
    (fun path -> Hashtbl.add tbl (Filename.basename path) path)
    ".";
  tbl

let resolve_file_name ~filename_map path =
  if Sys.file_exists path then Ok path
  else
    match Hashtbl.find_all filename_map (Filename.basename path) with
    | [] -> errorf "Couldn't find file %S" path
    | _ :: _ :: _ -> errorf "Ambiguous location in index for file %S" path
    | [ f ] -> Ok f

(** Call [f] for every files that contain occurrences of [Lwt]. *)
let group_occurrences_by_file lids f =
  let module Tbl = Hashtbl.Make (String) in
  let tbl = Tbl.create 64 in
  List.iter
    (fun ((_ident, lid) as occ) ->
      let file = lid.Location.loc.loc_start.pos_fname in
      Tbl.replace tbl file
        (match Tbl.find_opt tbl file with
        | Some lids -> occ :: lids
        | None -> [ occ ]))
    lids;
  Tbl.iter f tbl

let migrate_file ~filename_map ~formatted ~errors ~modify_ast file =
  let ( >>= ) = Result.bind in
  match
    resolve_file_name ~filename_map file >>= fun file ->
    Ocamlformat_utils.format_in_place ~file ~modify_ast
  with
  | Ok () -> incr formatted
  | Error (`Msg msg) ->
      Format.eprintf "%s: %s\n%!" file msg;
      incr errors

let dune_build_dir = "_build"

let occurrences ~packages ~units =
  match Ocaml_index_utils.occurrences ~dune_build_dir ~packages ~units with
  | [] ->
      Format.eprintf "Found no occurrences.\n%!";
      exit 1
  | occ -> occ

let migrate ~packages ~units ~modify_ast =
  let occurs = occurrences ~packages ~units in
  let errors = ref 0 in
  let formatted = ref 0 in
  let filename_map = lookup_filename_map () in
  group_occurrences_by_file occurs (fun fname occurrences ->
      let modify_ast = make_modify_ast ~modify_ast ~fname occurrences in
      migrate_file ~filename_map ~formatted ~errors ~modify_ast fname);
  Format.printf "Formatted %d files, %d errors\n%!" !formatted !errors;
  if !errors > 0 then exit 1

let print_occurrences ~packages ~units =
  let occurs = occurrences ~packages ~units in
  let pp_occurrence ppf ((unit_name, ident), lid) =
    Format.fprintf ppf "%s.%s %a" unit_name ident Printast.fmt_location
      lid.Location.loc
  in
  group_occurrences_by_file occurs (fun file occurrences ->
      Format.printf "@[<v 2>%s: (%d occurrences)@ %a@]@\n" file
        (List.length occurrences)
        (Format.pp_print_list pp_occurrence)
        occurrences)
