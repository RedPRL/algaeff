module type S =
sig
  exception Locked

  val exclusively : (unit -> 'a) -> 'a
  val run : (unit -> 'a) -> 'a
end

module Make () =
struct
  exception Locked

  let () = Printexc.register_printer @@
    function
    | Locked -> Some "Mutex already locked"
    | _ -> None

  module S = State.Make(struct type state = bool end)

  let exclusively f =
    if S.get() then
      raise Locked
    else begin
      S.set true;
      match f () with
      | ans -> S.set false; ans
      | exception e -> S.set false; raise e
    end

  let run f = S.run ~init:false f
end
