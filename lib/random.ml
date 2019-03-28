(*
 *           Copyright r6eve 2019 -
 *  Distributed under the Boost Software License, Version 1.0.
 *     (See accompanying file LICENSE_1_0.txt or copy at
 *           https://www.boost.org/LICENSE_1_0.txt)
 *)

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
  I.shift_right_logical !seed @@ 48 - bits

let next_boolean () =
  not @@ Int64.equal 0L @@ next 1

let int_of_int64 n =
  (* Bit trick for built-in [int] type. *)
  Int32.to_int @@ Int64.to_int32 n

module NextInt = struct
  type t = Unit | Bound of int

  let next_int = function
    | Unit -> int_of_int64 @@ next 32
    | Bound n when n <= 0 -> invalid_arg "[bound] must be positive."
    (* [n] is 0 or 1 or power of 2 *)
    | Bound n when n land -n = n ->
      let lhs = Int64.mul (Int64.of_int n) @@ next 31 in
      int_of_int64 @@ Int64.shift_right_logical lhs 31
    | Bound n ->
      let rec doit b v =
        if b - v + n - 1 >= 0 then
          v
        else
          let b = int_of_int64 @@ next 31 in
          doit b @@ b mod n
      in
      (* Start from dummy. *)
      doit 0 n
end

let next_int x = NextInt.next_int x

let next_bytes ba =
  let byte_of_int i =
    let n = 0xFF land i in
    if n land 0x80 = 0x80 then - (0xFF - n + 1) else n
  in
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
  if max >= Array.length ba then
    ba
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
      if x < 1. then
        x, y, z
      else
        let y = 2. *. next_float () -. 1. in
        let z = 2. *. next_float () -. 1. in
        doit (y *. y +. z *. z, y, z)
    in
    let x, y, z = doit (1., 0., 0.) in
    let norm = sqrt @@ -2. *. log x /. x in
    next_gaussian := Some (z *. norm);
    y *. norm

module type Streamable = sig
  type elt
  val next_val : unit -> elt
  val next_range : elt -> elt -> elt
end

module Make_stream(M : Streamable) = struct
  type elt = M.elt

  type size = int

  type origin = elt
  type bound = elt

  type t =
    | Unit
    | StreamSize of { size : size }
    | Range of { origin : origin; bound : bound }
    | SandR of { size : size; origin : origin; bound : bound }

  let next_val () = M.next_val ()

  let next_range origin bound = M.next_range origin bound

  let stream = function
    | Unit -> Stream.from @@ fun _ -> Some (next_val ())

    | StreamSize { size } when size <= 0 ->
      invalid_arg "[stream_size] must be positive."
    | StreamSize { size } ->
      Stream.from @@ fun n -> if n = size then None else Some (next_val ())

    | Range { origin; bound } when origin >= bound ->
      invalid_arg "[bound] must be greater than [origin]."
    | Range { origin; bound } ->
      Stream.from @@ fun _ -> Some (next_range origin bound)

    | SandR { size; _ } when size <= 0 ->
      invalid_arg "[stream_size] must be positive."
    | SandR { origin; bound; _ } when origin >= bound ->
      invalid_arg "[bound] must be greater than [origin]."
    | SandR { size; origin; bound } ->
      Stream.from @@ fun n ->
        if n = size then None else Some (next_range origin bound)
end

module Ints = Make_stream(struct
  type elt = int
  let next_val () = next_int Unit
  let next_range origin bound =
    next_int (Bound (bound - origin)) + origin
end)

let ints x = Ints.stream x

module Floats = Make_stream(struct
  type elt = float
  let next_val () = next_float ()
  let next_range origin bound =
    let f = next_float () *. (bound -. origin) +. origin in
    if f < bound then f else bound -. 1.
end)

let floats x = Floats.stream x
