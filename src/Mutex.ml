module type S =
sig
  exception RecursiveLocking

  val exclusively : (unit -> 'a) -> 'a
  val run : (unit -> 'a) -> 'a
end

module Make () =
struct
  exception RecursiveLocking

  module S = State.Make(struct type state = bool end)

  let exclusively f =
    if S.get() then
      raise RecursiveLocking
    else begin
      S.set true;
      Fun.protect ~finally:(fun () -> S.set false) f
    end

  let run f = S.run ~init:false f
end
