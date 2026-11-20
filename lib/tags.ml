module String_map = Map.Make (String)

type t = string String_map.t
(** TODO: Probably change this to a less heavy representation, maybe an array of
    pairs sorted by key or two parallel arrays with keys and values. given how
    common key names and some values are could also have a lookup table of
    strings and then share them so don't have to allocate loads in memory maybe.*)

exception
  Duplicate_tag_key of { key : string; old_value : string; new_value : string }

let empty = String_map.empty
let of_list xs = List.fold_left (fun acc (k, v) -> 
  match String_map.find_opt k acc with
  | Some old_value -> raise (Duplicate_tag_key { key = k; new_value = v; old_value })
  | None -> String_map.add k v acc) empty xs
let mem = String_map.mem
let find_opt = String_map.find_opt
let to_list = String_map.bindings
let equal = String_map.equal String.equal
let pp_pair ppf (x, y) = Format.fprintf ppf "%s=\"%s\"" x y
let pp ppf x =
Format.fprintf ppf "tags[%a]"
  (Format.pp_print_list
    ~pp_sep:(fun ppf () -> Format.fprintf ppf " @ ")
    pp_pair) (to_list x) 
