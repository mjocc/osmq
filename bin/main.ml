let string_of_tag (((_, name), attrs) : Xmlm.tag) =
  "<" ^ name ^ " "
  ^ String.concat " " (List.map (fun ((_, k), v) -> k ^ "=\"" ^ v ^ "\"") attrs)
  ^ ">"

let id ic =
  let i = Xmlm.make_input ~strip:true (`Channel ic) in
  let rec pull i depth print_depth =
    (* print_depth, if defined, means "print until we reach this depth again" *)
    let indent d = String.make (d * 2) ' ' in
    match Xmlm.input i with
    | `El_start el ->
        let is_mine =
          List.exists
            (fun ((_, name), v) -> name = "user" && v = "mjo52")
            (snd el)
        in
        let print_depth =
          match print_depth with
          | Some _ ->
              (* already inside a region: print, keep the outer depth *)
              Printf.printf "%s`El_start %s\n" (indent depth) (string_of_tag el);
              print_depth
          | None when is_mine ->
              (* start a region, remembering the depth this element opened at *)
              Printf.printf "%s`El_start %s\n" (indent depth) (string_of_tag el);
              Some depth
          | None -> None
        in
        pull i (depth + 1) print_depth
    | `El_end ->
        let print_depth =
          match print_depth with
          | Some pd when depth - 1 = pd ->
              Printf.printf "%s`El_end\n" (indent (depth - 1));
              None (* region element closing *)
          | Some _ ->
              Printf.printf "%s`El_end\n" (indent (depth - 1));
              print_depth
          | None -> None
        in
        if depth = 1 then () else pull i (depth - 1) print_depth
    | `Data d ->
        if Option.is_some print_depth then
          Printf.printf "%s`Data %s\n" (indent depth) d;
        pull i depth print_depth
    | `Dtd _ -> assert false
  in
  ignore (Xmlm.input i);
  (* `Dtd *)
  pull i 0 None;
  if not (Xmlm.eoi i) then invalid_arg "document not well-formed"

let () = In_channel.with_open_text "bluebell.osm" (fun ic -> id ic)
