(* When using [--no-comment-check] (to format code despite warning 50),
   We should not complain if doc-comments start appearing in the AST.
*)

module type T = sig
val test_raises_some_exc : ('a -> 'b) -> 'a -> bool;;
(** AAAA *)

val test_raises_this_exc : exn -> ('a -> 'b) -> 'a -> bool;;
(** BBBB *)
end

module T = struct

let test_raises_some_exc = 2;;
(** CCCC *)

let test_raises_this_exc = 3;;
(** DDDD *)
end
