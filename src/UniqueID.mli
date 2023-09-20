(** Effects for generating unique IDs.
    @since 0.2 *)

(** Generate unique IDs for registered items. *)

module type Param =
sig
  (** Parameters of the effects. *)

  type elt
  (** The type of elements. *)
end

module type S =
sig
  (** Signatures of the effects. *)

  include Param
  (** @open *)

  (** The type of IDs and its friends. *)
  module ID :
  sig
    type t = private int
    (** Semi-abstract type of IDs. *)

    val equal : t -> t -> bool
    (** Checking whether two IDs are equal. *)

    val compare : t -> t -> int
    (** Compare two IDs. *)

    val dump : Format.formatter -> t -> unit
    (** Printing the ID. *)

    val unsafe_of_int : int -> t
    (** Unsafe conversion from {!type:int}. Should be used only for de-serialization. *)
  end

  type id = ID.t
  (** The type of unique IDs. The client should not assume a particular indexing scheme. *)

  val register : elt -> id
  (** Register a new item and get an ID. Note that registering the same item twice will get two different IDs. *)

  val retrieve : id -> elt
  (** Retrieve the item associated with the ID. *)

  val export : unit -> elt Seq.t
  (** Export the internal storage for serialization. Once exported, the representation is persistent and can be traversed without the effect handler. *)

  val run : ?init:elt Seq.t -> (unit -> 'a) -> 'a
  (** [run t] runs the thunk [t] and handles the effects for generating unique IDs.

      @param init The initial storage, which should be the output of some previous {!val:export}.
  *)

  val register_printer : ?register:(elt -> string) -> ?retrieve:(id -> string) -> ?export:string -> unit
end

module Make (P : Param) : S with type elt = P.elt
(** The implementation of the effects. *)
