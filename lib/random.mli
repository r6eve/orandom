(****************************************************************)
(*                                                              *)
(*           Copyright r6eve 2019 -                             *)
(*  Distributed under the Boost Software License, Version 1.0.  *)
(*     (See accompanying file LICENSE_1_0.txt or copy at        *)
(*           https://www.boost.org/LICENSE_1_0.txt)             *)
(*                                                              *)
(****************************************************************)

module Random : sig

  type next_int_t = Unit | Bound of int

  module Ints : sig
    type t =
      | Unit
      | StreamSize of stream_size
      | Range of range
      | SandR of stream_size * range
    and stream_size = int
    and range = int * int  (* [origin, bound) *)
  end

  module Floats : sig
    type t =
      | Unit
      | StreamSize of stream_size
      | Range of range
      | SandR of stream_size * range
    and stream_size = int
    and range = float * float  (* [origin, bound) *)
  end

  val init : unit -> unit
  (** Create a new random number generator. *)

  val set_seed : int -> unit
  (** Set the seed of the random number generator using the given seed. *)

  val next_boolean : unit -> bool
  (** Return the next random, uniformly distributed boolean value. *)

  val next_bytes : int array -> int array
  (** Generate random bytes and place them into a user-supplied int array.
      Note that the byte type in Java ranges from [-128, 127] but in OCaml
      [0, 255]. In order to make the results corresponding to Java, use int
      array instead of bytes. *)

  val next_int : next_int_t -> int
  (** Same as [next_boolean] except return int value. *)
  (* TODO: Add documentation about [bound]. *)

  val next_float : unit -> float
  (** Same as [next_boolean] except return float value. *)

  val next_gaussian : unit -> float
  (** Return the next random, Gaussian (normally) distributed value
      with mean 0.0 and standard deviation 1.0. *)

  val ints : Ints.t -> int Stream.t
  (** Return an effectively unlimited stream of random int values. *)
  (* TODO: Add documentation about more possibilities. *)

  val floats : Floats.t -> float Stream.t
  (** Same as [ints] except return float values. *)
  (* TODO: Add documentation about more possibilities. *)

end
