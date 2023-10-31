module type S =
sig
  type state
  val get : unit -> state
  val set : state -> unit
  val modify : (state -> state) -> unit
  val run : init:state -> (unit -> 'a) -> 'a
  val register_printer : ([`Get | `Set of state] -> string option) -> unit
end

module Make (State : Sigs.Type) =
struct
  type _ Effect.t +=
    | Get : State.t Effect.t
    | Set : State.t -> unit Effect.t

  let get () = Effect.perform Get
  let set st = Effect.perform (Set st)

  let run ~(init:State.t) f =
    let open Effect.Deep in
    let st = ref init in
    try_with f ()
      { effc = fun (type a) (eff : a Effect.t) ->
            match eff with
            | Get -> Option.some @@ fun (k : (a, _) continuation) ->
              continue k !st
            | Set v -> Option.some @@ fun (k : (a, _) continuation) ->
              st := v; continue k ()
            | _ -> None }

  let modify f = set @@ f @@ get ()

  let register_printer f = Printexc.register_printer @@ function
    | Effect.Unhandled Get -> f `Get
    | Effect.Unhandled (Set state) -> f (`Set state)
    | _ -> None

  let () = register_printer @@ fun _ -> Some "Unhandled algaeff effect; use Algaeff.State.run"
end
