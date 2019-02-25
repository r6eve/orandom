# orandom
[![Build Status][]][CI Results]

orandom is an OCaml library which acts partially like [java.util.Random][].
You can check out the methods at lib/random.mli file.

## Usage

### Import orandom in your code

TBD:

See test/random.ml for examples of use.

### Interactive Session

```console
> dune utop
utop [0]: open Orandom.Random;;
utop [1]: Random.set_seed(0xA12EA88);;
- : unit = ()
utop [2]: Random.next_boolean ();;
- : bool = false
utop [3]: Random.next_boolean ();;
- : bool = true
```

### Unit Testing

```console
> dune runtest
```

[Build Status]: https://circleci.com/gh/r6eve/orandom.svg?style=svg
[CI Results]: https://circleci.com/gh/r6eve/orandom
[java.util.Random]: https://docs.oracle.com/javase/10/docs/api/java/util/Random.html
