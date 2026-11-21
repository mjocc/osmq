type pos = int * int
(** Line and column number, both starting at 1. *)

val pp_pos : Format.formatter -> pos -> unit
(** Prints [line:col], both indexed from 1. *)

exception Parse_error of { reason : string; position : pos }

(** The type for input sources. [String] and [Channel] are self-explanatory,
    while [File] takes a filename to read from. *)
type source = String of string | File of string | Channel of Stdlib.in_channel

val fold : ('acc -> Raw.element -> 'acc) -> 'acc -> source -> 'acc
(** Takes the standard [fold] arguments and some source to read XML from and
    then performs a left fold over the elements in the XML stream.
    @raise Parse_error if there is some issue with the provided XML.*)

val iter : (Raw.element -> unit) -> source -> unit
(** Takes the standard [iter] arguments and some source to read XML from and
    then performs the given operation for each element in the XML stream.
    @raise Parse_error if there is some issue with the provided XML.*)
