module type Param =
sig
  type elt
end

module type S =
sig
  include Param

  val yield : elt -> unit
  val run : (unit -> unit) -> elt Seq.t
  val register_printer : ([`Yield of elt] -> string option) -> unit
end

module Make (P : Param) =
struct
  include P

  type _ Effect.t += Yield : elt -> unit Effect.t

  let yield x = Effect.perform (Yield x)

  let run f () =
    let open Effect.Deep in
    try_with (fun () -> f (); Seq.Nil) ()
      { effc = fun (type a) (eff : a Effect.t) ->
            match eff with
            | Yield x -> Option.some @@ fun (k : (a, _) continuation) ->
              Seq.Cons (x, continue k)
            | _ -> None }

  let register_printer f = Printexc.register_printer @@ function
    | Effect.Unhandled (Yield elt) -> f (`Yield elt)
    | _ -> None

  let () = register_printer @@ fun _ -> Some "Unhandled algaeff effect; use Algaeff.Sequencer.run"
end
