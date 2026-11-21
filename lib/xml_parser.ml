type pos = Xmlm.pos

exception Parse_error of { reason : string; position : pos }

let pp_pos ppf (line, col) = Format.fprintf ppf "%d:%d" line col

let () =
  Printexc.register_printer (function
    | Parse_error { reason; position } ->
        Some
          (Format.asprintf "Xml_parser.Parse_error at %a of input: %s" pp_pos
             position reason)
    | _ -> None)

(* TODO probably add more odoc comments to a lot of this stuff?*)

let parse_errorf position fmt =
  Printf.ksprintf (fun reason -> raise (Parse_error { reason; position })) fmt

type source = String of string | File of string | Channel of Stdlib.in_channel
type xmlm_tree = E of Xmlm.tag * xmlm_tree list

let find_attr (attrs : Xmlm.attribute list) attr =
  let check_attr ((_, name), _) = String.equal name attr in
  List.find_opt check_attr attrs |> Option.map snd

let required_attr position attrs attr =
  match find_attr attrs attr with
  | Some v -> v
  | None -> parse_errorf position "required attribute \"%s\" not present" attr

let int_attr position attrs attr =
  let attr_val = required_attr position attrs attr in
  match int_of_string_opt attr_val with
  | Some v -> v
  | None -> parse_errorf position "failed to parse \"%s\" value as an int" attr

let float_attr position attrs attr =
  let attr_val = required_attr position attrs attr in
  match Float.of_string_opt attr_val with
  | Some v -> v
  | None -> parse_errorf position "failed to parse \"%s\" value as a float" attr

let tags_of_children position children =
  let tag_of_child = function
    | E (((_, "tag"), attrs), _) ->
        let k = required_attr position attrs "k" in
        let v = required_attr position attrs "v" in
        Some (k, v)
    | _ -> None
  in
  try Tags.of_list (List.filter_map tag_of_child children)
  with Tags.Duplicate_key { key; old_value; new_value } ->
    parse_errorf position
      "duplicate key on tag, contains both %s=\"%s\" and %s=\"%s\"" key
      old_value key new_value

(** Ensure that if visible is present in the attributes of a tag, it isn't
    malformed and doesn't have the value false, otherwise we may be looking at
    some historic data.
    @raise Parse_error if the conditions on visible aren't met. *)
let check_visible position attrs =
  match find_attr attrs "visible" with
  | Some "true" | None -> ()
  | Some visible (* including "false" *) ->
      parse_errorf position
        "element has visible=\"%s\", indicating this is some sort of historic \
         OSM export, which is unsupported by this tool"
        visible

(** Returns an (id, timestamp, tags) triple since these are shared between
    {!Raw.Node.t}, {!Raw.Way.t}, and {!Raw.Relation.t}.
    @raise Parse_error
      if the timestamp is defined but doesn't parse, or if any integer or float
      values fail to parse to their respective types, or if the node has
      attribute visible="false" as this indicates we're look at some sort of
      history file while this tool is not built to parse.*)
let header_of_tree position attrs children =
  let () = check_visible position attrs in
  let id = int_attr position attrs "id" in
  let timestamp =
    try Option.map Timestamp.of_rfc3339 (find_attr attrs "timestamp")
    with Timestamp.Invalid_timestamp { input; reason } ->
      parse_errorf position "error parsing timestamp \"%s\" - %s" input reason
  in
  let tags = tags_of_children position children in
  (id, timestamp, tags)

let node_of_tree position attrs children =
  let float_attr = float_attr position attrs in
  let id, timestamp, tags = header_of_tree position attrs children in
  Raw.Node
    {
      id = Id.node id;
      latitude = float_attr "lat";
      longitude = float_attr "lon";
      timestamp;
      tags;
    }

let way_of_tree position attrs children =
  let nd_id_of_tree nds = function
    | E (((_, "nd"), nd_attrs), _) ->
        Id.node (int_attr position nd_attrs "ref") :: nds
    | _ -> nds
  in
  let id, timestamp, tags = header_of_tree position attrs children in
  let nodes = List.fold_left nd_id_of_tree [] children |> List.rev in
  Raw.Way { id = Id.way id; timestamp; tags; nodes }

let relation_of_tree position attrs children =
  let member_of_tree members = function
    | E (((_, "member"), member_attrs), _) ->
        let ref_int = int_attr position member_attrs "ref" in
        let member_ref =
          match required_attr position member_attrs "type" with
          | "node" -> Raw.Relation.Node (Id.node ref_int)
          | "way" -> Raw.Relation.Way (Id.way ref_int)
          | "relation" -> Raw.Relation.Relation (Id.relation ref_int)
          | type_ ->
              parse_errorf position "relation member cannot have type \"%s\""
                type_
        in
        let role =
          match required_attr position member_attrs "role" with
          | "" -> None
          | s -> Some s
        in
        { Raw.Relation.ref = member_ref; role } :: members
    | _ -> members
  in
  let id, timestamp, tags = header_of_tree position attrs children in
  let members = List.fold_left member_of_tree [] children |> List.rev in
  Raw.Relation { id = Id.relation id; timestamp; tags; members }

(* TODO probably want to include element ID in more of the parse messages here*)

(* TODO need to have tests for each one of the raise scenarios below*)
let rec fold_top_level f acc i =
  let s = Xmlm.peek i in
  let position = Xmlm.pos i in

  (* for top-level tag we want to parse, generate generic tree *)
  let el tag childs = E (tag, childs) in
  (* osm xml formats don't include xml data in "node", "way", or "relation"
     tags *)
  let data _ =
    parse_errorf position
      "data signals aren't allowed as children of top-level elements"
  in
  (* build a generic tree from the current top-level node and its children, then
     call the provided convertor on it
     ([node_of_tree]/[way_of_tree]/[relation_of_tree]), then step the fold*)
  let emit converter =
    let (E ((_, attrs), children)) = Xmlm.input_tree ~el ~data i in
    let element = converter position attrs children in
    let acc = f acc element in
    fold_top_level f acc i
  in
  match s with
  | `El_start ((_, "node"), _) -> emit node_of_tree
  | `El_start ((_, "way"), _) -> emit way_of_tree
  | `El_start ((_, "relation"), _) -> emit relation_of_tree
  | `El_start _ ->
      (* skip unknown tags, some editors/APIs like to insert their own *)
      Xmlm.input_tree ~el:(fun _ _ -> ()) ~data:(fun _ -> ()) i;
      fold_top_level f acc i
  | `Data _ ->
      (* there shouldn't be data between top-level elements since
         [~strip:true] *)
      parse_errorf position "data between top-level elements isn't allowed"
  | `Dtd _ ->
      assert false
      (* guaranteed to only show up once at start of stream and has already been
         consumed in [fold_input] *)
  | `El_end ->
      ignore (Xmlm.input i);
      (* consume the `El_end *)
      (* ensure there aren't any extra tags after the closing xml one, if not then return [acc] *)
      if Xmlm.eoi i then acc
      else parse_errorf position "tags after closing </osm> tag"

let fold_input f acc xmlm_source =
  let i = Xmlm.make_input ~strip:true xmlm_source in
  try
    ignore (Xmlm.input i) (* `Dtd *);
    let position = Xmlm.pos i in
    match Xmlm.input i with
    | `El_start ((_, "osm"), _) -> fold_top_level f acc i
    | `El_start ((_, tag), _) ->
        parse_errorf position
          "doesn't seem to be an osm file (begins with tag <%s ... >)" tag
    | _ -> assert false (* xmlm will only ever emit an `El_start after a `Dtd *)
  with Xmlm.Error (pos, e) ->
    parse_errorf pos "malformed xml - %s" (Xmlm.error_message e)

let fold f acc source =
  match source with
  | String s -> fold_input f acc (`String (0, s))
  | File filename ->
      In_channel.with_open_text filename (fun channel ->
          fold_input f acc (`Channel channel))
  | Channel channel -> fold_input f acc (`Channel channel)

(* TODO should have a test calling [fold] on an empty file *)

let iter f source = fold (fun _ el -> f el) () source
