(** Specifies the types that are returned by a parser, either XML or PBF (the
    latter not yet implemented). Largely just contains types, so has no
    corresponding .mli. Some OSM export formats do not include any metadata
    unless explicitly asked to (e.g. Overpass), including timestamps, so the
    [timestamp] field is optional in all three main record types.*)

module Node = struct
  type t = {
    id : Id.node_id;
    latitude : float;
    longitude : float;
    timestamp : Timestamp.t option;
    tags : Tags.t;
  }
  [@@deriving show]
end

module Way = struct
  type t = {
    id : Id.way_id;
    timestamp : Timestamp.t option;
    tags : Tags.t;
    nodes : Id.node_id list;
  }
  [@@deriving show]
end

module Relation = struct
  type member_ref =
    | Node of Id.node_id
    | Way of Id.way_id
    | Relation of Id.relation_id
  [@@deriving show]

  type member = {
    ref : member_ref;
    role : string option;
        (** An option since the role field is optional (conceptually, always
            present in the export format but represented by empty string), so
            this makes it easier to handle.*)
  }
  [@@deriving show]
  (** Contains a reference to some element by its ID and a the "role" of that
      member of the relation: see
      {{:https://wiki.openstreetmap.org/wiki/Relation} the relevant OSM wiki
       page} for more.*)

  type t = {
    id : Id.relation_id;
    timestamp : Timestamp.t option;
    tags : Tags.t;
    members : member list;
  }
  [@@deriving show]
end

type element = Node of Node.t | Way of Way.t | Relation of Relation.t
[@@deriving show]
