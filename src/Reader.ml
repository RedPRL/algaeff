module type S =
sig
  type env
  val read : unit -> env
  val scope : (env -> env) -> (unit -> 'a) -> 'a
  val run : env:env -> (unit -> 'a) -> 'a
  val register_printer : ([`Read] -> string option) -> unit
end

module Make (Env : Sigs.Type) =
struct
  type _ eff += Read : Env.t eff

  let read () = Effect.perform Read

  let run ~(env:Env.t) f =
    let open Effect.Deep in
    try f () with effect Read, k -> continue k env

  let scope f c = run ~env:(f @@ read ()) c

  let register_printer f = Printexc.register_printer @@ function
    | Effect.Unhandled Read -> f `Read
    | _ -> None

  let () = register_printer @@ fun _ -> Some "Unhandled algaeff effect; use Algaeff.Reader.run"
end
