(** Effects for unique ids. *)

(** EXPERIMENTAL *)

module type Param =
sig
  type item
  (** The type of items. *)
end

module type S =
sig
  include Param
  (** @open *)

  type id = int

  val insert : item -> id

  val select : id -> item

  val export : unit -> item Seq.t

  val run : ?init:item Seq.t -> (unit -> 'a) -> 'a
end

module Make (P : Param) : S with type item = P.item
