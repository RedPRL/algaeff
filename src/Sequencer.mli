(** Effects for constructing a [Seq.t].
    @since 0.2 *)

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

  val register_printer : ([`Yield of elt] -> string option) -> unit
  (** [register_printer p] registers a printer [p] via {!val:Printexc.register_printer} to convert unhandled internal effects into strings for the OCaml runtime system to display. Ideally, all internal effects should have been handled by {!val:run} and there is no need to use this function, but when it is not the case, this function can be helpful for debugging. The functor {!module:Modifier.Make} always registers a simple printer to suggest using {!val:run}, but you can register new ones to override it. The return type of the printer [p] should return [Some s] where [s] is the resulting string, or [None] if it chooses not to convert a particular effect. The registered printers are tried in reverse order until one of them returns [Some s] for some [s]; that is, the last registered printer is tried first. Note that this function is a wrapper of {!val:Printexc.register_printer} and all the registered printers (via this function or {!val:Printexc.register_printer}) are put into the same list.

      The input type of the printer [p] is a variant representation of the internal effects used in this module. They correspond to the effects trigger by {!val:yield}. More precisely, [`Yield elt] corresponds to the effect triggered by [yield elt].

      @since 1.0.0
  *)
end

module Make (P : Param) : S with type elt = P.elt
(** The implementation of sequencing effects. *)
