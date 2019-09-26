(lang dune 1.10)
(name orandom)
(version 1.0.0)

(implicit_transitive_deps true)
(generate_opam_files true)
(license BSL-1.0)
(authors "r6eve <r6eve179f@gmail.com>")
(maintainers "r6eve <r6eve179f@gmail.com>")
(source (github r6eve/orandom))
(homepage "https://github.com/r6eve/orandom")

(package
 (name orandom)
 (depends
  (ocaml (>= 4.07.0))
  (dune :build)
  (ounit (>= 2.0.8)))
 (synopsis "OCaml library for java.util.Random"))
