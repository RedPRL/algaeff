(** Effects for generating a [Seq.t]. *)

(**
   {[
     module S = Algaeff.Sequencer.Make (struct type elt = int end)

     (* The sequence corresponding to [[1; 2; 3]]. *)
     let seq : int Seq.t = S.run @@ fun () -> S.yield 1; S.yield 2; S.yield 3

     (* An implementation of [List.to_seq]. *)
     let to_seq l : int Seq.t = S.run @@ fun () -> List.iter S.yield l
   ]}
*)

(** The sequencers are generators for [Seq.t]. *)

module type Param =
sig
  (** Parameters of sequencing effects. *)

  type elt
  (** The type of elementers. *)
end

module type S =
sig
  (** Signatures of sequencing effects. *)

  include Param
  (** @open *)

  val yield : elt -> unit
  (** Yield the element. *)

  val run : (unit -> unit) -> elt Seq.t
  (** [run t] runs the thunk [t] which may perform sequencing effects. *)
end

module Make (P : Param) : S with type elt = P.elt
(** The implementation of sequencing effects. *)
