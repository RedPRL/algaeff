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

module Make (M : Monad) : S with type 'a t = 'a M.t
