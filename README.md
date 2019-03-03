# orandom
[![Build Status][]][CI Results]

orandom is an OCaml library which acts partially like [java.util.Random][].
You can check out the methods at lib/random.mli file.

## Usage

### Import orandom in your code

```console
> opam repo add orandom https://github.com/r6eve/orandom.git
> opam install orandom
```

Then, you can use orandom on your machine.

```console
> utop
utop [0]: #require "orandom";;
utop [1]: open Orandom.Random;;
utop [2]: Random.set_seed(0xA12EA88);;
- : unit = ()
utop [3]: Random.next_boolean ();;
- : bool = false
utop [4]: Random.next_boolean ();;
- : bool = true
```

See also test/random.ml for examples of use.

### Unit Testing

```console
> dune runtest
```

[Build Status]: https://circleci.com/gh/r6eve/orandom.svg?style=svg
[CI Results]: https://circleci.com/gh/r6eve/orandom
[java.util.Random]: https://docs.oracle.com/javase/10/docs/api/java/util/Random.html
