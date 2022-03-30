module type S =
sig
  exception RecursiveLocking

  val exclusively : (unit -> 'a) -> 'a
  val run : (unit -> 'a) -> 'a
end

module Make () : S
