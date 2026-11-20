(** This module is for dealing with the timestamps in the [timestamp] field on
    many of the objects in OSM data. In XML-formatted OSM data, the documented
    approach is to store timestamps in ISO 8601 style. Here we parse RFC 3339,
    which is a strict subset of ISO 8601, but the specific format OSM uses
    ([YYYY-MM-DDTHH:MM:SSZ]) satisfies both.*)

type t
(** Represents an instant in time, truncated to the second.*)

exception Invalid_timestamp of { input : string; reason : string }

val of_rfc3339 : string -> t
(** Takes a [string] containing an RFC 3339 timestamp and returns an {!t}
    representing the corresponding UNIX timestamp in a memory efficient way. If
    fractional-seconds are included, we truncate them to whole seconds. We
    offset times by their time zones and then store them all as points on the
    UTC timeline.
    @raise Invalid_timestamp
      if you try to parse a timestamp string that doesn't (loosely) satisfy RFC
      3339.*)

val equal : t -> t -> bool
val compare : t -> t -> int

val pp : Format.formatter -> t -> unit
(** Represents {!t} as an RFC3339 timestamp on the UTC timeline.*)
