(** Effects for generating unique IDs. *)

(** Generate unique IDs for registered items. *)

module type Param =
sig
  type elt
  (** The type of elements. *)
end

module type S =
sig
  include Param
  (** @open *)

  type id = private int
  (** The type of unique IDs. The client should not assume a particular indexing scheme. *)

  val unsafe_id_of_int : int -> id
  (** Unsafe conversion from {!type:int} to {!type:id}. Should be used only for de-serialization. *)

  val register : elt -> id
  (** Register a new item and get an ID. Note that registering the same item twice will get two different IDs. *)

  val retrieve : id -> elt
  (** Retrieve the item associated with the ID. *)

  val export : unit -> elt Seq.t
  (** Export the internal storage. Once exported, the representation is persistent and can be used without the effect handler. *)

  val run : ?init:elt Seq.t -> (unit -> 'a) -> 'a
  (** [run t] runs the thunk [t] and handles the effects for generating unique IDs.

      @param init The initial storage exported by {!val:export}.
  *)
end

module Make (P : Param) : S with type elt = P.elt
