type 'u t = int
type node
type way
type relation

let node x = x
let way x = x
let relation x = x
let equal = Int.equal
let compare = Int.compare
let hash = Hashtbl.hash
let pp ppf x = Format.fprintf ppf "%d" x
