(****************************************************************)
(*                                                              *)
(*           Copyright r6eve 2019 -                             *)
(*  Distributed under the Boost Software License, Version 1.0.  *)
(*     (See accompanying file LICENSE_1_0.txt or copy at        *)
(*           https://www.boost.org/LICENSE_1_0.txt)             *)
(*                                                              *)
(****************************************************************)

module Random = struct
  let init () = "junk"

  let set_seed _seed = assert false

  let next_boolean () = assert false

  let next_int () = assert false

  let next_float () = assert false

  let next_gaussian () = assert false

  let ints () = assert false

  let floats () = assert false
end
