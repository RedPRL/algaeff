module type S =
sig
  exception Locked

  val exclusively : (unit -> 'a) -> 'a
  val run : (unit -> 'a) -> 'a
end

module Make () =
struct
  exception Locked

  module S = State.Make(struct type state = bool end)

  let exclusively f =
    if S.get() then
      raise Locked
    else begin
      S.set true;
      Stdlib.Fun.protect ~finally:(fun () -> S.set false) f
    end

  let run f = S.run ~init:false f
end
