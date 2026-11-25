open Osmq

type elements = {
  nodes : Raw.Node.t list;
  ways : Raw.Way.t list;
  relations : Raw.Relation.t list;
}
[@@deriving show]

let () =
  let els =
    Xml_parser.fold
      (fun els -> function
        | Raw.Node n -> { els with nodes = n :: els.nodes }
        | Raw.Way w -> { els with ways = w :: els.ways }
        | Raw.Relation r -> { els with relations = r :: els.relations })
      { nodes = []; ways = []; relations = [] }
      (Xml_parser.File "falklands.osm")
  in
  Format.printf "%a" pp_elements els

(** TODO if actually going to have some sort of cli tool type thing in here,
    need to catch Parse_error exceptions and print a nice message properly*)
