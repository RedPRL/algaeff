module type Param =
sig
  type env
end

module type S =
sig
  include Param

  val get : unit -> env
  val run : env -> (unit -> 'a) -> 'a
end

module Make (P : Param) : S with type env = P.env
