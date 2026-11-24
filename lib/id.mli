(** Represents IDs of nodes, ways, and relations using an abstract interface
    that compiles away at runtime. This prevents you accidently e.g. passing a
    [node_id] to a function mean for ways. Think of it as providing effectively
    tagged ints that are really just ints but are tagged by a type during type
    checking. These types are also defined as polymorphic variants, allowing you
    to express the idea of e.g. "a {!t} that can be either a node or a way".
    Some standard functions across these are IDs are also provided, as well as
    all the plumbing necessary for [ppx_deriving] to work out of the box without
    needing explicit annotation (as long as you use the {!node_id} form for
    types as opposed to {!type:Id.node} {!Id.t}).*)

type +'k t
(** [+k'] specifies that [t] is {i covariant} in ['k], allowing us to say e.g. a
    "node" id can be used wherever a "node-or-way" id can be used *)

type node = [ `Node ]
type way = [ `Way ]
type relation = [ `Relation ]

type node_id = node t
(** Equivalent to {!type:Id.node} {!Id.t} but this convention allows for simpler
    [ppx_deriving] usage and cleaner type signatures. *)

type way_id = way t
(** See {!node_id}. *)

type relation_id = relation t
(** See {!node_id}. *)

val node : int -> node t
val way : int -> way t
val relation : int -> relation t
val equal : 'k t -> 'k t -> bool
val compare : 'k t -> 'k t -> int
val hash : 'k t -> int
val pp : Format.formatter -> 'k t -> unit [@@ocaml.toplevel_printer]
val pp_node_id : Format.formatter -> node_id -> unit [@@ocaml.toplevel_printer]
val pp_way_id : Format.formatter -> way_id -> unit [@@ocaml.toplevel_printer]

val pp_relation_id : Format.formatter -> relation_id -> unit
[@@ocaml.toplevel_printer]
