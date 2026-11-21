(lang dune 3.24)

(name osmq)

(generate_opam_files true)

(source
 (github mjocc/osmq))

(authors "Matt Occleshaw")

(maintainers "Matt Occleshaw")

(license MIT)

(documentation https://mjocc.org/osmq)

(package
 (name osmq)
 (synopsis "An eDSL for OpenStreetMap in OCaml.")
 (description "An eDSL for OpenStreetMap in OCaml, completed for my Part II project.")
 (depends ocaml xmlm ptime)
 )

; See the complete stanza docs at https://dune.readthedocs.io/en/stable/reference/dune-project/index.html
