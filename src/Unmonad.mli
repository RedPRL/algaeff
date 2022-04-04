(** Effects for any monad. *)

(** This is a general construction that uses effects to construct monadic expressions.
    Here is an alternative implementation of {!module:State} using
    the standard state monad:

    {[
      module StateMonad =
      struct
        type state = int
        type 'a t = state -> 'a * state
        let ret x s = x, s
        let bind m f s = let x, s = m s in f x s
        let get s = s, s
        let set s _ = (), s
        let modify f s = (), f s
      end

      module StateUnmonad =
      struct
        type state = int
        module U = Algaeff.Unmonad.Make (StateMonad)
        let get () = U.perform StateMonad.get
        let set s = U.perform @@ StateMonad.set s
        let modify f = U.perform @@ StateMonad.modify f
        let run ~init f = fst @@ U.run f init
      end
    ]}

    Note that continuations in OCaml are one-shot, so the list monad will not work;
    it will quickly lead to the runtime error that the continuation is resumed twice.
    Also, monads do not mix well with exceptions, and thus the [bind] operation should not
    raise an exception unless it encounters a truly unrecoverable fatal error. Raising an exception
    within [bind] will skip the continuation, and thus potentially skipping exception handlers
    within the continuation. Those handlers might be crucial for properly releasing allocated resources.
*)

module type Monad =
sig
  (** The signature of monads. *)

  type 'a t
  val ret : 'a -> 'a t
  val bind : 'a t -> ('a -> 'b t) -> 'b t
end

module type Param = Monad
(** Parameters of monad effects. *)

module type S =
sig
  (** Signatures of monad effects. *)

  type 'a t
  (** The monad. *)

  val perform : 'a t -> 'a
  (** Perform an monadic operation. *)

  val run : (unit -> 'a) -> 'a t
  (** [run t] runs the thunk [t] which may perform monad effects,
      and then returns the corresponding monadic expression. *)
end

module Make (M : Monad) : S with type 'a t = 'a M.t
(** The implementation of monad effects. *)
