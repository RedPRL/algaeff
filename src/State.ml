module type S =
sig
  type state
  val get : unit -> state
  val set : state -> unit
  val modify : (state -> state) -> unit
  val run : init:state -> (unit -> 'a) -> 'a
  val try_with : ?get:(unit -> state) -> ?set:(state -> unit) -> (unit -> 'a) -> 'a
  val register_printer : ([`Get | `Set of state] -> string option) -> unit
end

module Make (State : Sigs.Type) =
struct
  type _ eff +=
    | Get : State.t eff
    | Set : State.t -> unit eff

  let get () = Effect.perform Get
  let set st = Effect.perform (Set st)

  let run ~(init:State.t) f =
    let open Effect.Deep in
    let st = ref init in
    try f () with
    | effect Get, k -> continue k !st
    | effect Set v, k -> st := v; continue k ()

  let try_with ?(get=get) ?(set=set) f =
    let open Effect.Deep in
    try f () with
    | effect Get, k -> continue k (get ())
    | effect Set v, k -> set v; continue k ()

  let modify f = set @@ f @@ get ()

  let register_printer f = Printexc.register_printer @@ function
    | Effect.Unhandled Get -> f `Get
    | Effect.Unhandled (Set state) -> f (`Set state)
    | _ -> None

  let () = register_printer @@ fun _ -> Some "Unhandled algaeff effect; use Algaeff.State.run"
end
