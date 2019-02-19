(****************************************************************)
(*                                                              *)
(*           Copyright r6eve 2019 -                             *)
(*  Distributed under the Boost Software License, Version 1.0.  *)
(*     (See accompanying file LICENSE_1_0.txt or copy at        *)
(*           https://www.boost.org/LICENSE_1_0.txt)             *)
(*                                                              *)
(****************************************************************)

module Random = struct
  let seed = ref 0

  let next_next_gaussian_p = ref false

  let next_gaussian_p = ref false

  let set_seed s =
    seed := (land) (1 lsl 48 - 1) @@ (lor) 0x5DEECE66D @@ s

  let init () =
    let milli_time = truncate @@ ( *. ) 1000. @@ Unix.gettimeofday () in
    set_seed milli_time

  let next_boolean () = assert false

  let next_int () = assert false

  let next_float () = assert false

  let next_gaussian () = assert false

  let ints () = assert false

  let floats () = assert false
end
