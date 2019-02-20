(****************************************************************)
(*                                                              *)
(*           Copyright r6eve 2019 -                             *)
(*  Distributed under the Boost Software License, Version 1.0.  *)
(*     (See accompanying file LICENSE_1_0.txt or copy at        *)
(*           https://www.boost.org/LICENSE_1_0.txt)             *)
(*                                                              *)
(****************************************************************)

module Random = struct
  let seed = ref Int64.zero

  let _next_next_gaussian_p = ref false

  let _next_gaussian_p = ref false

  let set_seed s =
    let module I = Int64 in
    seed := I.logand (I.of_int (1 lsl 48 - 1)) @@ I.logor 0x5DEECE66DL @@ I.of_int s

  let init () =
    let milli_time = truncate @@ ( *. ) 1000. @@ Unix.gettimeofday () in
    set_seed milli_time

  let next bits =
    let module I = Int64 in
    seed := I.logand (I.of_int (1 lsl 48 - 1)) @@ I.add 0xBL @@ I.mul 0x5DEECE66DL !seed;
    I.shift_right_logical !seed (48 - bits)

  let next_boolean () = next(1) <> Int64.zero

  let next_int () = assert false

  let next_float () = assert false

  let next_gaussian () = assert false

  let ints () = assert false

  let floats () = assert false
end
