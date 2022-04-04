open StdlibShim

(* an ugly hack before ocaml/ocaml#11159 is resolved *)
type !'a wrap = Wrap of 'a Domain.t

type _ Effect.t += Spawn : (unit -> 'a) -> 'a wrap Effect.t

let scope ?(at_spawn=Stdlib.Fun.id) ?(at_exit=Stdlib.Fun.id) f =
  Effect.Deep.try_with f ()
    { effc =
        fun (type a) (eff : a Effect.t) ->
          match eff with
          | Spawn t -> Option.some @@ fun (k : (a, _) Effect.Deep.continuation) ->
            Fun.Deep.reperform k @@ Spawn (fun () ->
                at_spawn ();
                match t () with
                | ans -> at_exit (); ans
                | exception exn -> at_exit (); raise exn)
          | _ -> None }

let spawn t = match Effect.perform (Spawn t) with Wrap dom -> dom

let run f =
  Effect.Deep.try_with f ()
    { effc =
        fun (type a) (eff : a Effect.t) ->
          match eff with
          | Spawn t -> Option.some @@ fun (k : (a, _) Effect.Deep.continuation) ->
            Fun.Deep.finally k @@ fun () -> Wrap (Domain.spawn t)
          | _ -> None }
