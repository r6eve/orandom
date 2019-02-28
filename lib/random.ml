(****************************************************************)
(*                                                              *)
(*           Copyright r6eve 2019 -                             *)
(*  Distributed under the Boost Software License, Version 1.0.  *)
(*     (See accompanying file LICENSE_1_0.txt or copy at        *)
(*           https://www.boost.org/LICENSE_1_0.txt)             *)
(*                                                              *)
(****************************************************************)

module Random = struct

  (* TODO: declare each points. *)
  type next_int_t =
    | Unit
    | Bound of int
  and ints_t =
    | IUnit
    | IStreamSize of stream_size_t
    | IRange of ints_range_t
    | ISandR of stream_size_t * ints_range_t
  and floats_t =
    | FUnit
    | FStreamSize of stream_size_t
    | FRange of floats_range_t
    | FSandR of stream_size_t * floats_range_t
  and stream_size_t = int
  and ints_range_t = int * int  (* [start, end) *)
  and floats_range_t = float * float  (* [start, end) *)

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
    | Bound n when n <= 0 -> invalid_arg "next_int: [bound] must be positive."
    (* [n] is 0 or 1 or power of 2 *)
    | Bound n when n land -n = n ->
      ( * ) n @@ int_of_int64 @@ Int64.shift_right_logical (next 31) 31
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
      if i >= max then ()
      else
        let n = next_int Unit in
        for j = i to i + 3 do
          ba.(j) <- byte_of_int @@ (lsr) n @@ 8 * (j - i);
        done;
        doit (i + 4) in
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

  let ints = function
    | IUnit -> Stream.from @@ fun _ -> Some (next_int Unit)
    | IStreamSize s ->
      Stream.from @@ fun n -> if n = s then None else Some (next_int Unit)
    | IRange (origin, bound) when origin < bound ->
      Stream.from @@ fun _ -> Some (next_int (Bound (bound - origin)) + origin)
    | IRange _ -> invalid_arg "ints: [bound] must be greater than [origin]."
    | _ -> assert false

  let floats = function
    | FUnit -> Stream.from @@ fun _ -> Some (next_float ())
    | FStreamSize s ->
      Stream.from @@ fun n -> if n = s then None else Some (next_float ())
    | FRange (origin, bound) when origin < bound -> assert false
    | FRange _ -> assert false
    | _ -> assert false

end
