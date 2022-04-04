(** Effects for any monad. *)

(** This is a general construction that uses effects to construct monadic expressions.
    Here is an alternative implementation of {!module:State} using
    the standard state monad:

    {[
      module StateMonad =
      struct
        type 'a t = int -> 'a * int
        let ret x s = x, s
        let bind m f s = let x, s = m s in f x s
        let get s = s, s
        let set s _ = (), s
        let modify f s = (), f s
      end

      module StateUnmonad =
      struct
        module U = Algaeff.Unmonad.Make (StateMonad)
        type state = int
        let get () = U.perform StateMonad.get
        let set s = U.perform @@ StateMonad.set s
        let modify f = U.perform @@ StateMonad.modify f
        let run ~init f = fst @@ U.run f init
      end
    ]}
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
