module Parsing : sig
  (** OCamlformat's version of OCaml's parsing modules *)

  include module type of Ocamlformat_ocaml_common
  include module type of Ocamlformat_parser_extended
end

open Parsing

exception Syntax_error of Location.t

val format_structure_in_place :
  file:string -> modify_ast:(Parsetree.structure -> Parsetree.structure) -> unit
(** Format the content of and overwrite [file]. [modify_ast] can be used to
    apply any change to the program. Raises [Failure] and [Sys_error]. *)
