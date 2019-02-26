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

  let next_gaussian = ref None

  let set_seed s =
    let module I = Int64 in
    let lhs = I.of_int @@ 1 lsl 48 - 1 in
    let rhs = I.logxor soil @@ I.of_int s in
    seed := I.logand lhs rhs

  let init () =
    let milli_time = truncate @@ ( *. ) 1000. @@ Unix.gettimeofday () in
    set_seed milli_time

  let next bits =
    let module I = Int64 in
    let lhs = I.of_int @@ 1 lsl 48 - 1 in
    let rhs = I.add 0xBL @@ I.mul soil !seed in
    seed := I.logand lhs rhs;
    I.shift_right_logical !seed (48 - bits)

  let next_boolean () = not @@ Int64.equal 0L @@ next 1

  let next_int () =
    (* Bit trick for built-in [int] type. *)
    Int32.to_int @@ Int64.to_int32 @@ next 32

  let next_bytes bytes = bytes
    (*
    let max = Bytes.length bytes land lnot 0x3 in
    let rec doit i =
      if i >= max then ()
      else
        let n = next_int () in
        for j = i to i + 3 do
          Bytes.set bytes j @@ char_of_int @@ n lsr 8 * (j - i);
        done;
        doit (i + 4) in
    doit 0;
    if max >= Bytes.length bytes then bytes
    else begin
      Bytes.set bytes max @@ char_of_int @@ next_int ();
      for i = max + 1 to Bytes.length bytes - 1 do
        let n = (lsr) 8 @@ int_of_char @@ Bytes.get bytes (i - 1) in
        Bytes.set bytes i @@ char_of_int n;
      done;
      bytes
    end
  *)

  let next_float () =
    let module I = Int64 in
    (* Must be called as this order. *)
    let x = next 26 in
    let y = next 27 in
    let lhs = I.to_float @@ I.add (I.shift_left x 27) y in
    let rhs = float @@ 1 lsl 53 in
    lhs /. rhs

  let next_gaussian () =
    match !next_gaussian with
    | Some g ->
      next_gaussian := None;
      g
    | None ->
      let rec doit (x, y, z) =
        if x < 1. then x, y, z
        else
          let y = 2. *. next_float () -. 1. in
          let z = 2. *. next_float () -. 1. in
          doit (y *. y +. z *. z, y, z) in
      let x, y, z = doit (1., 0., 0.) in
      let norm = sqrt @@ -2. *. log x /. x in
      next_gaussian := Some (z *. norm);
      y *. norm

  let ints () = Stream.from @@ fun _ -> Some (next_int ())

  let floats () = Stream.from @@ fun _ -> Some (next_float ())

end
