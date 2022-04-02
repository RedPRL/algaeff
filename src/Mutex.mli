module type S =
sig
  exception Locked

  val exclusively : (unit -> 'a) -> 'a
  val run : (unit -> 'a) -> 'a
end

module Make () : S
