module type Param =
sig
  type state
end

module type S =
sig
  include Param

  val get : unit -> state
  val set : state -> unit
  val modify : (state -> state) -> unit
  val run : init:state -> (unit -> 'a) -> 'a
end

module Make (P : Param) : S with type state = P.state
