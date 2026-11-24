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
let pp_node_id ppf x = Format.fprintf ppf "n%d" x
let pp_way_id ppf x = Format.fprintf ppf "w%d" x
let pp_relation_id ppf x = Format.fprintf ppf "r%d" x
