type +'k t
(** +k' specifies that t is covariant in 'k, allowing us to say e.g. a "node" id
    can be used wherever a "node-or-way" id can be used *)

type node = [ `Node ]
type way = [ `Way ]
type relation = [ `Relation ]

val node : int -> node t
val way : int -> way t
val relation : int -> relation t
val equal : 'k t -> 'k t -> bool
val compare : 'k t -> 'k t -> int
val hash : 'k t -> int
val pp : Format.formatter -> 'k t -> unit
