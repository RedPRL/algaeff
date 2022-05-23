module type Monad =
sig
  type 'a t
  val ret : 'a -> 'a t
  val bind : 'a t -> ('a -> 'b t) -> 'b t
end

module type Param = Monad

module type S =
sig
  type 'a t
  val perform : 'a t -> 'a
  val run : (unit -> 'a) -> 'a t
end

module Make (M : Monad) =
struct
  include M

  type 'a Effect.t += Monadic : 'a t -> 'a Effect.t

  let perform m = Effect.perform (Monadic m)
  let run f =
    Effect.Deep.match_with f ()
      { retc = M.ret
      ; exnc = raise
      ; effc = function Monadic m -> Option.some @@ fun k -> M.bind m (Effect.Deep.continue k) | _ -> None
      }
end
