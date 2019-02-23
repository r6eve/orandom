(****************************************************************)
(*                                                              *)
(*           Copyright r6eve 2019 -                             *)
(*  Distributed under the Boost Software License, Version 1.0.  *)
(*     (See accompanying file LICENSE_1_0.txt or copy at        *)
(*           https://www.boost.org/LICENSE_1_0.txt)             *)
(*                                                              *)
(****************************************************************)

module Random : sig
  val init : unit -> unit
  (** Create a new random number generator. *)

  val set_seed : int -> unit
  (** Set the seed of the random number generator using the given seed. *)

  val next_boolean : unit -> bool
  (** Return the next random, uniformly distributed boolean value. *)

  val next_int : unit -> int
  (** Same as [next_boolean] except return int value. *)

  val next_float : unit -> float
  (** Same as [next_boolean] except return float value. *)

  val next_gaussian : unit -> float
  (** Return the next random, Gaussian (normally) distributed value
      with mean 0.0 and standard deviation 1.0. *)

  val ints : unit -> int Seq.t
  (** Return an effectively unlimited stream of random int values. *)

  val floats : unit -> float Seq.t
  (** Same as [ints] except return float values. *)
end
