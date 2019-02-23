(****************************************************************)
(*                                                              *)
(*           Copyright r6eve 2019 -                             *)
(*  Distributed under the Boost Software License, Version 1.0.  *)
(*     (See accompanying file LICENSE_1_0.txt or copy at        *)
(*           https://www.boost.org/LICENSE_1_0.txt)             *)
(*                                                              *)
(****************************************************************)

(*
`data_sinusoidal.txt` is generated by

```clojure
(let [rnd (java.util.Random.), random-seed 1, num-points 100, period (/ num-points 4)]
  (.setSeed rnd random-seed)
  (map #(+ (Math/sin (/ (\* 2 Math/PI %) period)) (\* 0.1 (.nextGaussian rnd)))
       (range num-points)))
```

and `data_sinusoidal.txt` is

```clojure
(let [rnd (java.util.Random.), random-seed 1, num-points 100]
  (.setSeed rnd random-seed)
  (map #(+
         (let [x (- (/ (double %) num-points) 0.5)]
           (\* (- x 0.75) (- x 0.5) (- x 0.25) (- x 0.1) (+ x 0.25) (+ x 0.5)))
         (\* 0.0001 (.nextGaussian rnd)))
       (range num-points)))
```

Note that I escaped '*' due to the awkward ocAML comments.
*)

open Orandom.Random

let delta = 1e-16

let same_float_p a b = abs_float (a -. b) < delta

let random_seed = 0xA12EA88

(** Testcase is generated by the following.
```java
final Random rnd = new Random();
rnd.setSeed(random_seed);
for (int i = 0; i < 10; ++i) { System.err.println(rnd.nextBoolean()); }
```
*)
let next_boolean_test () =
  let expected = [false; true; true; true; false; true; true; true; true; false] in
  Random.set_seed random_seed;
  expected
  |> List.iter @@ fun e ->
    assert (e = Random.next_boolean ())

(**
```java
final Random rnd = new Random();
rnd.setSeed(random_seed);
for (int i = 0; i < 10; ++i) { System.err.println(rnd.nextInt()); }
```
*)
let next_int_test () =
  let expected = [699623645; -1595099454; -1287389250; -1685747256; 1682232222;
                  -913754311; -574631589; -119104651; -1773027241; 1347232330] in
  Random.set_seed random_seed;
  expected
  |> List.iter @@ fun e ->
    assert (e = Random.next_int ())

(**
```java
final Random rnd = new Random();
rnd.setSeed(random_seed);
for (int i = 0; i < 10; ++i) { System.err.println(rnd.nextDouble()); }
```
*)
let next_float_test () =
  let expected = [0.16289382619577597; 0.7002563269064781; 0.391675215769559;
                   0.8662081654707906; 0.5871849255811716; 0.795985400090248;
                   0.8753358845961806; 0.5779306167183001; 0.25412226823745343;
                   0.6590125741968693] in
  Random.set_seed random_seed;
  expected
  |> List.iter @@ fun e ->
    assert (same_float_p e @@ Random.next_float ())

(**
```java
final Random rnd = new Random();
rnd.setSeed(random_seed);
for (int i = 0; i < 10; ++i) { System.err.println(rnd.nextGaussian()); }
```
*)
let next_gaussian_test () =
  let _expected = [-0.8477761452662856; 0.5036174062731802; -0.29448804340345225;
                   0.9955609595163628; 0.39261781282371044; 1.3329040500584017;
                   1.0093628600758726; 0.20957300755532526; -1.2284538576703976;
                   0.7944583219878215] in
  ()

(**
```java
final Random rnd = new Random();
rnd.setSeed(random_seed);
rnd.ints().limit(10).forEach(e -> System.err.println(e));
```
*)
let ints_test () =
  let _expected = [699623645; -1595099454; -1287389250; -1685747256; 1682232222;
                   -913754311; -574631589; -119104651; -1773027241; 1347232330] in
  ()

(**
```java
final Random rnd = new Random();
rnd.setSeed(random_seed);
rnd.doubles().limit(10).forEach(e -> System.err.println(e));
```
*)
let floats_test () =
  let _expected = [0.16289382619577597; 0.7002563269064781; 0.391675215769559;
                   0.8662081654707906; 0.5871849255811716; 0.795985400090248;
                   0.8753358845961806; 0.5779306167183001; 0.25412226823745343;
                   0.6590125741968693] in
  ()

let () =
  next_boolean_test ();
  next_int_test ();
  next_float_test ();
  next_gaussian_test ();
  ints_test ();
  floats_test ();
