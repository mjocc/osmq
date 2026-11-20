type 'u t
type node
type way
type relation

val node : int -> node t
val way : int -> way t
val relation : int -> relation t
val equal : 'u t -> 'u t -> bool
val compare : 'u t -> 'u t -> int
val hash : 'u t -> int
val pp : Format.formatter -> 'u t -> unit
