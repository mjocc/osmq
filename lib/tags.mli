type t

exception
  Duplicate_tag_key of { key : string; old_value : string; new_value : string }

val empty : t

val of_list : (string * string) list -> t
(** Builds a {!t} from a list of key-value pairs, ensuring there are no duplicate keys.
    @raise Duplicate_tag_key if you try to add to a key that has already been defined with the key,
      existing value, and new value .*)
val mem : string -> t -> bool
val find_opt : string -> t -> string option
val to_list : t -> (string * string) list
(** Returns a {i consistently ordered} list of key-value pairs.*)
(* TODO: maybe want a better way to traverse over it than to-list (probs fold or iter type thign? *)
val equal : t -> t -> bool
val pp : Format.formatter -> t -> unit
