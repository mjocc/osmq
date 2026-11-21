type t = int

exception Invalid_timestamp of { input : string; reason : string }

let of_rfc3339 s =
  match Ptime.of_rfc3339 s with
  | Ok (timestamp, _, _) ->
      timestamp |> Ptime.truncate ~frac_s:0 |> Ptime.to_span
      |> Ptime.Span.to_int_s |> Option.get
      (* [to_int_s] raises if there isn't enough room in an OCaml 63-bit [int]
         to store the second value, but since we've truncated to whole seconds
         this should never be able to happen, so [Option.get] is safe.*)
  | Error (`RFC3339 (_, e)) ->
      let reason = Format.asprintf "%a" Ptime.pp_rfc3339_error e in
      raise (Invalid_timestamp { input = s; reason })

let equal = Int.equal
let compare = Int.compare
(* two inputs differing in only fractional seconds will look equal here but
   that's fine, it's documented*)

let pp ppf timestamp =
  Ptime.pp_rfc3339 ~tz_offset_s:0 () ppf
    (timestamp |> Ptime.Span.of_int_s |> Ptime.of_span |> Option.get)
(* there should be no way to construct a value of type {!t} that isn't a valid
   timestamp so [Option.get] should be safe here.*)

(* TODO: add tests for this that parsing a date and then printing it gives the
   same value, and then that if you do it from a different timezone you get a
   valid value, etc. *)
