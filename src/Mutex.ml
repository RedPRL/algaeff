open StdlibShim

module type S =
sig
  exception RecursiveLocking

  val exclusively : (unit -> 'a) -> 'a
  val run : (unit -> 'a) -> 'a
end

module Make () =
struct
  exception RecursiveLocking

  type _ Effect.t +=
    | Lock : unit Effect.t
    | Unlock : unit Effect.t

  let exclusively f =
    Effect.perform Lock;
    Fun.protect ~finally:(fun () -> Effect.perform Unlock) f

  let run f =
    let open Effect.Deep in
    let mutex = Stdlib.Mutex.create () in
    try_with f ()
      { effc = fun (type a) (eff : a Effect.t) ->
            match eff with
            | Lock -> Option.some @@ fun (k : (a, _) continuation) ->
              begin
                match Stdlib.Mutex.lock mutex with
                | () -> continue k ()
                | exception Sys_error _ -> discontinue k RecursiveLocking
              end
            | Unlock -> Option.some @@ fun (k : (a, _) continuation) ->
              Stdlib.Mutex.unlock mutex;
              continue k ()
            | _ -> None }
end
