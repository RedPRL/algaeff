module type Param =
sig
  type env
end

module type S =
sig
  include Param

  val read : unit -> env
  val scope : (env -> env) -> (unit -> 'a) -> 'a
  val run : env -> (unit -> 'a) -> 'a
end

module Make (P : Param) : S with type env = P.env
