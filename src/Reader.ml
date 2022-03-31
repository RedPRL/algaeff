open StdlibShim

module type Param =
sig
  type env
end

module type S =
sig
  include Param

  val get : unit -> env
  val run : env -> (unit -> 'a) -> 'a
end

module Make (P : Param) =
struct
  include P

  type _ Effect.t += Get : env Effect.t

  let get () = Effect.perform Get

  let run (env:env) f =
    let open Effect.Deep in
    try_with f ()
      { effc = fun (type a) (eff : a Effect.t) ->
            match eff with
            | Get -> Option.some @@ fun (k : (a, _) continuation) ->
              continue k env
            | _ -> None }
end
