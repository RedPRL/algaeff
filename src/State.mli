(** Effects for changing states. *)

(**
   {[
     module S = Algaeff.State.Make (struct type state = int end)

     let forty_two = S.run ~init:100 @@ fun () ->
       print_int (S.get ()); (* this will print out 100 *)
       S.set 42;
       S.get ()
   ]}
*)

(** This should be equivalent to {!module:Unmonad} applying to the standard state monad when continuations are one-shot.
    (The current implementation uses mutable references and this statement has not been formally proved.) *)

module type Param =
sig
  (** Parameters of state effects. *)

  type state
  (** The type of states. *)
end

module type S =
sig
  (** Signatures of read effects. *)

  include Param
  (** @open *)

  val get : unit -> state
  (** [get ()] reads the current state. *)

  val set : state -> unit
  (** [set x] makes [x] the new state. *)

  val modify : (state -> state) -> unit
  (** [modify f] applies [f] to the current state and then set the result as the new state. *)

  val run : init:state -> (unit -> 'a) -> 'a
  (** [run t] runs the thunk [t] which may perform state effects. *)

  val register_printer : ?get:string -> ?set:(state -> string) -> unit
end

module Make (P : Param) : S with type state = P.state
(** The implementation of state effects. *)
