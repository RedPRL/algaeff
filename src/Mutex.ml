module type S =
sig
  exception Locked

  val exclusively : (unit -> 'a) -> 'a
  val run : (unit -> 'a) -> 'a

  val register_printer : ([`Exclusively] -> string option) -> unit
end

module Make () =
struct
  exception Locked

  let () = Printexc.register_printer @@
    function
    | Locked -> Some "Mutex already locked"
    | _ -> None

  module S = State.Make (Bool)

  let exclusively f =
    if S.get() then
      raise Locked
    else begin
      S.set true;
      (* Favonia: I learn from the developers of eio that Fun.protect is not good at
         preserving the backtraces. See https://github.com/ocaml-multicore/eio/pull/209. *)
      match f () with
      | ans -> S.set false; ans
      | exception e -> S.set false; raise e
    end

  let run f = S.run ~init:false f

  let register_printer f = S.register_printer @@ fun _ -> f `Exclusively

  let () = register_printer @@ fun _ -> Some "Unhandled algaeff effect; use Algaeff.Mutex.run"
end
