let () =
  let els =
    Osmq.Xml_parser.fold
      (fun acc x -> x :: acc)
      [] (Osmq.Xml_parser.File "falklands.osm")
  in
  Printf.printf "%d\n" (List.length els)

(** TODO if actually going to have some sort of cli tool type thing in here,
    need to catch Parse_error exceptions and print a nice message properly*)
