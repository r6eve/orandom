# orandom
[![Build Status][]][CI Results]

orandom is an OCaml library which acts partially like [java.util.Random][].
You can check out the methods at [lib/random.mli](./lib/random.mli) file.

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
utop [1]: module Random = Orandom.Random;;
utop [2]: Random.set_seed(0xA12EA88);;
- : unit = ()
utop [3]: Random.next_boolean ();;
- : bool = false
utop [4]: Random.next_boolean ();;
- : bool = true
```

See also [test/random.ml](./test/random.ml) for examples of use.

### Unit Testing

```console
> dune runtest
```

### Manually testing

I suggest `dune utop` that gives you REPL for local library.

```console
> dune utop
utop [0]: module Random = Orandom.Random;;
module Random = Orandom.Random
utop [1]: Random.set_seed(0xA12EA88);;
- : unit = ()
utop [2]: Random.next_boolean ();;
- : bool = false
```

## Style Guide

* [Jane Street Style Guide][]

## Contributing

If you would like to help make this repository, take the following steps
(it's just guidelines, not rules).

1. Fork this repository: https://github.com/r6eve/orandom/fork
2. Switch branches: `git checkout -b new-feature`
3. Do something.
4. Commits: `git commit -am 'add some feature'`
5. Push to your repository: `git push origin new-feature`
6. Send a pull request.

## Contributors

- [r6eve][] - Neat


[Build Status]: https://circleci.com/gh/r6eve/orandom.svg?style=svg
[CI Results]: https://circleci.com/gh/r6eve/orandom
[java.util.Random]: https://docs.oracle.com/javase/10/docs/api/java/util/Random.html
[Jane Street Style Guide]: https://opensource.janestreet.com/standards/
[r6eve]: https://github.com/r6eve
