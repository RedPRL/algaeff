(** Effects for unique ids. *)

(** EXPERIMENTAL *)

module type Param =
sig
  type row
  (** The type of rows. *)
end

module type S =
sig
  include Param
  (** @open *)

  type id = int

  val insert : row -> id

  val select : id -> row

  val export : unit -> row Seq.t

  val run : ?init:row Seq.t -> (unit -> 'a) -> 'a
end

module Make (P : Param) : S with type row = P.row
