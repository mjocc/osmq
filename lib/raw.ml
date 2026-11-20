(** Specifies the types that are returned by a parser, either XML or PBF (the
    latter not yet implemented). Largely just contains types, so has no
    corresponding .mli. Some OSM export formats do not include any metadata
    unless explicitly asked to (e.g. Overpass), including timestamps, so the
    [timestamp] field is optional in all three main record types.*)

module Node = struct
  type t = {
    id : Id.node Id.t;
    latitude : float;
    longitude : float;
    timestamp : Timestamp.t option;
    tags : Tags.t;
  }
end

module Way = struct
  type t = {
    id : Id.way Id.t;
    timestamp : Timestamp.t option;
    tags : Tags.t;
    nodes : Id.node Id.t list;
  }
end

module Relation = struct
  type member_ref =
    | Node of Id.node Id.t
    | Way of Id.way Id.t
    | Relation of Id.relation Id.t

  type member = {
    ref : member_ref;
    role : string option;
        (** An option since the role field is optional (conceptually, always
            present in the export format but represented by empty string), so
            this makes it easier to handle.*)
  }
  (** Contains a reference to some element by its ID and a the "role" of that
      member of the relation: see
      {{:https://wiki.openstreetmap.org/wiki/Relation} the relevant OSM wiki page} for
      more*)

  type t = {
    id : Id.relation Id.t;
    timestamp : Timestamp.t option;
    tags : Tags.t;
    members : member list;
  }
end

type element = Node of Node.t | Way of Way.t | Relation of Relation.t
