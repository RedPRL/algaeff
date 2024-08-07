(** Effects for changing states. *)

(**
   {[
     module S = Algaeff.State.Make (Int)

     let forty_two = S.run ~init:100 @@ fun () ->
       print_int (S.get ()); (* this will print out 100 *)
       S.set 42;
       S.get ()
   ]}
*)

module type S =
sig
  (** Signatures of state effects. *)

  type state
  (** The type of states. *)

  val get : unit -> state
  (** [get ()] reads the current state. *)

  val set : state -> unit
  (** [set x] makes [x] the new state. *)

  val modify : (state -> state) -> unit
  (** [modify f] applies [f] to the current state and then set the result as the new state. *)

  val run : init:state -> (unit -> 'a) -> 'a
  (** [run ~init t] runs the thunk [t] which may perform state effects. The initial state is [init]. *)

  val try_with : ?get:(unit -> state) -> ?set:(state -> unit) -> (unit -> 'a) -> 'a
  (** [try_with ~get ~set t] runs the thunk [t] which may perform state effects, handling these effects with [get] and [set] (which may perform effects from some other module). The default handlers re-perform the effects. *)

  val register_printer : ([`Get | `Set of state] -> string option) -> unit
  (** [register_printer p] registers a printer [p] via {!val:Printexc.register_printer} to convert unhandled internal effects into strings for the OCaml runtime system to display. Ideally, all internal effects should have been handled by {!val:run} and there is no need to use this function, but when it is not the case, this function can be helpful for debugging. The functor {!module:Make} always registers a simple printer to suggest using {!val:run}, but you can register new ones to override it. The return type of the printer [p] should return [Some s] where [s] is the resulting string, or [None] if it chooses not to convert a particular effect. The registered printers are tried in reverse order until one of them returns [Some s] for some [s]; that is, the last registered printer is tried first. Note that this function is a wrapper of {!val:Printexc.register_printer} and all the registered printers (via this function or {!val:Printexc.register_printer}) are put into the same list.

      The input type of the printer [p] is a variant representation of the internal effects used in this module. They correspond to the effects trigger by {!val:get} and {!val:set}. More precisely,
      - [`Get] corresponds to the effect triggered by [get ()].
      - [`Set state] corresponds to the effect triggered by [set state].

      @since 1.1.0
  *)
end

module Make (State : Sigs.Type) : S with type state := State.t
(** The implementation of state effects. *)
