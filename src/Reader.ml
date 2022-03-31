open StdlibShim

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

module Make (P : Param) =
struct
  include P

  type _ Effect.t += Read : env Effect.t

  let read () = Effect.perform Read

  let run (env:env) f =
    let open Effect.Deep in
    try_with f ()
      { effc = fun (type a) (eff : a Effect.t) ->
            match eff with
            | Read -> Option.some @@ fun (k : (a, _) continuation) ->
              continue k env
            | _ -> None }

  let scope f c = run (f @@ read ()) c
end
