(*
 *           Copyright r6eve 2019 -
 *  Distributed under the Boost Software License, Version 1.0.
 *     (See accompanying file LICENSE_1_0.txt or copy at
 *           https://www.boost.org/LICENSE_1_0.txt)
 *)

module Random = struct

  type next_int_t = Unit | Bound of int

  module Ints = struct
    type elt = int

    type t =
      | Unit
      | StreamSize of stream_size
      | Range of range
      | SandR of stream_size * range
    and stream_size = int
    and range = elt * elt  (* [origin, bound) *)
  end

  module Floats = struct
    type elt = float

    type t =
      | Unit
      | StreamSize of stream_size
      | Range of range
      | SandR of stream_size * range
    and stream_size = int
    and range = elt * elt  (* [origin, bound) *)
  end

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

  let int_of_int64 n =
    (* Bit trick for built-in [int] type. *)
    Int32.to_int @@ Int64.to_int32 n

  let next_int = function
    | Unit -> int_of_int64 @@ next 32
    | Bound n when n <= 0 -> invalid_arg "[bound] must be positive."
    (* [n] is 0 or 1 or power of 2 *)
    | Bound n when n land -n = n ->
      let lhs = Int64.mul (Int64.of_int n) @@ next 31 in
      int_of_int64 @@ Int64.shift_right_logical lhs 31
    | Bound n ->
      let rec doit b v =
        if b - v + n - 1 >= 0 then v
        else
          let b = int_of_int64 @@ next 31 in
          doit b (b mod n) in
      (* Start from dummy. *)
      doit 0 n

  let next_bytes ba =
    let byte_of_int i =
      let n = 0xFF land i in
      if n land 0x80 = 0x80 then - (0xFF - n + 1) else n in
    let max = Array.length ba land lnot 0x3 in
    let rec doit i =
      if i >= max then
        ()
      else
        let n = next_int Unit in
        for j = i to i + 3 do
          ba.(j) <- byte_of_int @@ (lsr) n @@ 8 * (j - i);
        done;
        doit (i + 4)
    in
    doit 0;
    if max >= Array.length ba then ba
    else begin
      ba.(max) <- byte_of_int @@ next_int Unit;
      for i = max + 1 to Array.length ba - 1 do
        ba.(i) <- byte_of_int @@ ba.(i - 1) lsr 8;
      done;
      ba
    end

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

  let next_range_ints origin bound = next_int (Bound (bound - origin)) + origin

  let ints = function
    | Ints.Unit -> Stream.from @@ fun _ -> Some (next_int Unit)

    | Ints.StreamSize s when s <= 0 ->
      invalid_arg "[stream_size] must be positive."
    | Ints.StreamSize s ->
      Stream.from @@ fun n -> if n = s then None else Some (next_int Unit)

    | Ints.Range (origin, bound) when origin >= bound ->
      invalid_arg "[bound] must be greater than [origin]."
    | Ints.Range (origin, bound) ->
      Stream.from @@ fun _ -> Some (next_range_ints origin bound)

    | Ints.SandR (s, _) when s <= 0 ->
      invalid_arg "[stream_size] must be positive."
    | Ints.SandR (_, (origin, bound)) when origin >= bound ->
      invalid_arg "[bound] must be greater than [origin]."
    | Ints.SandR (s, (origin, bound)) ->
      Stream.from @@ fun n ->
        if n = s then None else Some (next_range_ints origin bound)

  let next_range_floats origin bound =
    let f = next_float () *. (bound -. origin) +. origin in
    if f < bound then f else bound -. 1.

  let floats = function
    | Floats.Unit -> Stream.from @@ fun _ -> Some (next_float ())

    | Floats.StreamSize s when s <= 0 ->
      invalid_arg "[stream_size] must be positive."
    | Floats.StreamSize s ->
      Stream.from @@ fun n -> if n = s then None else Some (next_float ())

    | Floats.Range (origin, bound) when origin >= bound ->
      invalid_arg "[bound] must be greater than [origin]."
    | Floats.Range (origin, bound) ->
      Stream.from @@ fun _ -> Some (next_range_floats origin bound)

    | Floats.SandR (s, _) when s <= 0 ->
      invalid_arg "[stream_size] must be positive."
    | Floats.SandR (_, (origin, bound)) when origin >= bound ->
      invalid_arg "[bound] must be greater than [origin]."
    | Floats.SandR (s, (origin, bound)) ->
      Stream.from @@ fun n ->
        if n = s then None else Some (next_range_floats origin bound)

end
