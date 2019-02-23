(****************************************************************)
(*                                                              *)
(*           Copyright r6eve 2019 -                             *)
(*  Distributed under the Boost Software License, Version 1.0.  *)
(*     (See accompanying file LICENSE_1_0.txt or copy at        *)
(*           https://www.boost.org/LICENSE_1_0.txt)             *)
(*                                                              *)
(****************************************************************)

module Random = struct

  let soil = 0x5DEECE66DL

  let seed = ref 0L

  let next_next_gaussian_p = ref false

  let next_next_gaussian = ref 0.

  let set_seed s =
    let module I = Int64 in
    seed := I.logand (I.of_int (1 lsl 48 - 1)) @@ I.logxor soil @@ I.of_int s

  let init () =
    let milli_time = truncate @@ ( *. ) 1000. @@ Unix.gettimeofday () in
    set_seed milli_time

  let next bits =
    let module I = Int64 in
    seed := I.logand (I.of_int (1 lsl 48 - 1)) @@ I.add 0xBL @@ I.mul soil !seed;
    I.shift_right_logical !seed (48 - bits)

  let next_boolean () = not @@ Int64.equal (next 1) 0L

  (* Bit trick for built-in [int] type. *)
  let next_int () = Int32.to_int @@ Int64.to_int32 @@ next 32

  let next_float () =
    let module I = Int64 in
    (* Must be called as this order. *)
    let na = next 26 in
    let nb = next 27 in
    let lhs = I.to_float @@ I.add (I.shift_left na 27) nb in
    let rhs = float @@ 1 lsl 53 in
    lhs /. rhs

  let next_gaussian () =
    if !next_next_gaussian_p then begin
      next_next_gaussian_p := false;
      !next_next_gaussian
    end else begin
      let rec doit (s, v1, v2) =
        if s < 1. then s, v1, v2
        else
          let v1 = 2. *. next_float () -. 1. in
          let v2 = 2. *. next_float () -. 1. in
          doit (v1 *. v1 +. v2 *. v2, v1, v2) in
      let s, v1, v2 = doit (1., 0., 0.) in
      let norm = sqrt @@ -2. *. log s /. s in
      next_next_gaussian := v2 *. norm;
      next_next_gaussian_p := true;
      v1 *. norm
    end

  let ints () = assert false

  let floats () = assert false

end
