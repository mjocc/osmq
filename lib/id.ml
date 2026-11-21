type 'k t = int
type node = [ `Node ]
type way = [ `Way ]
type relation = [ `Relation ]

let node x = x
let way x = x
let relation x = x
let equal = Int.equal
let compare = Int.compare
let hash = Hashtbl.hash
let pp ppf x = Format.fprintf ppf "%d" x
