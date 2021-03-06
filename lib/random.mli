(*
 *           Copyright r6eve 2019 -
 *  Distributed under the Boost Software License, Version 1.0.
 *     (See accompanying file LICENSE_1_0.txt or copy at
 *           https://www.boost.org/LICENSE_1_0.txt)
 *)

val init : unit -> unit
(** Create a new random number generator. *)

val set_seed : int -> unit
(** Set the seed of the random number generator using the given seed. *)

val next_boolean : unit -> bool
(** Return the next random, uniformly distributed boolean value. *)

val next_bytes : int array -> int array
(** Generate random bytes and place them into a user-supplied int array.
    Note that the byte type in Java ranges from [-128, 127] but in OCaml [0, 255].
    In order to make the results corresponding to Java, use int array instead
    of bytes. *)

module NextInt : sig
  type t = Unit | Bound of int
end

val next_int : NextInt.t -> int
(** Same as [next_boolean] except return int value. If [bound] is given, return
    int value between 0 (inclusive) and [bound] (exclusive). *)

val next_float : unit -> float
(** Same as [next_boolean] except return float value. *)

val next_gaussian : unit -> float
(** Return the next random, Gaussian (normally) distributed value with mean 0.0
    and standard deviation 1.0. *)

module Ints : sig
  type elt = int
  (** The type of stream elements. *)

  type size = int

  type t =
    | Unit
    | StreamSize of { size : size }
    | Range of { origin : elt; bound : elt }
    | SandR of { size : size; origin : elt; bound : elt }
  (** The type of streams. [origin] is 0-based inclusive and [bound] is
      exclusive. i.e. [origin, bound)*)
end

val ints : Ints.t -> int Stream.t
(** Return an effectively unlimited stream of random int values. *)

module Floats : sig
  type elt = float
  (** The type of stream elements. *)

  type size = int

  type t =
    | Unit
    | StreamSize of { size : size }
    | Range of { origin : elt; bound : elt }
    | SandR of { size : size; origin : elt; bound : elt }
  (** The type of streams. [origin] is 0-based inclusive and [bound] is
      exclusive. i.e. [origin, bound)*)
end

val floats : Floats.t -> float Stream.t
(** Same as [ints] except return float values. *)
