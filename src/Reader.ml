module type S =
sig
  module Env : Sigs.Type

  val read : unit -> Env.t
  val scope : (Env.t -> Env.t) -> (unit -> 'a) -> 'a
  val run : env:Env.t -> (unit -> 'a) -> 'a
  val register_printer : ([`Read] -> string option) -> unit
end

module Make (Env : Sigs.Type) =
struct
  type _ Effect.t += Read : Env.t Effect.t

  let read () = Effect.perform Read

  let run ~(env:Env.t) f =
    let open Effect.Deep in
    try_with f ()
      { effc = fun (type a) (eff : a Effect.t) ->
            match eff with
            | Read -> Option.some @@ fun (k : (a, _) continuation) ->
              continue k env
            | _ -> None }

  let scope f c = run ~env:(f @@ read ()) c

  let register_printer f = Printexc.register_printer @@ function
    | Effect.Unhandled Read -> f `Read
    | _ -> None

  let () = register_printer @@ fun _ -> Some "Unhandled algaeff effect; use Algaeff.Reader.run"
end
