type 'k t = int
type node = [ `Node ]
type way = [ `Way ]
type relation = [ `Relation ]

(* basically just have these so ppx_deriving doesn't need manual annotation
   every time *)
type node_id = node t
type way_id = way t
type relation_id = relation t

let node x = x
let way x = x
let relation x = x
let equal = Int.equal
let compare = Int.compare
let hash = Hashtbl.hash
let pp ppf x = Format.fprintf ppf "%d" x

(* these are largely also here for ppx_deriving*)
let pp_node_id = pp
let pp_way_id = pp
let pp_relation_id = pp
