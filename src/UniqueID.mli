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

  val register_printer : ([`Register of elt | `Retrieve of id | `Export] -> string option) -> unit
  (** [register_printer p] registers a printer [p] via {!val:Printexc.register_printer} to convert unhandled internal effects into strings for the OCaml runtime system to display. Ideally, all internal effects should have been handled by {!val:run} and there is no need to use this function, but when it is not the case, this function can be helpful for debugging. The functor {!module:Modifier.Make} always registers a simple printer to suggest using {!val:run}, but you can register new ones to override it. The return type of the printer [p] should return [Some s] where [s] is the resulting string, or [None] if it chooses not to convert a particular effect. The registered printers are tried in reverse order until one of them returns [Some s] for some [s]; that is, the last registered printer is tried first. Note that this function is a wrapper of {!val:Printexc.register_printer} and all the registered printers (via this function or {!val:Printexc.register_printer}) are put into the same list.

      The input type of the printer [p] is a variant representation of the internal effects used in this module. They correspond to the effects trigger by {!val:register}, {!val:retrieve} and {!val:export}. More precisely,
      - [`Register elt] corresponds to the effect triggered by [register elt].
      - [`Retrieve id] corresponds to the effect triggered by [retrieve id].
      - [`Export] corresponds to the effect triggered by [export ()].

      @since 1.0.0
  *)
end

module Make (P : Param) : S with type elt = P.elt
(** The implementation of the effects. *)
