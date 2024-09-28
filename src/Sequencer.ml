module type S =
sig
  type elt
  val yield : elt -> unit
  val run : (unit -> unit) -> elt Seq.t
  val register_printer : ([`Yield of elt] -> string option) -> unit
end

module Make (Elt : Sigs.Type) =
struct
  type _ eff += Yield : Elt.t -> unit eff

  let yield x = Effect.perform (Yield x)

  let run f () =
    let open Effect.Deep in
    try f (); Seq.Nil with
    | effect Yield x, k -> Seq.Cons (x, continue k)

  let register_printer f = Printexc.register_printer @@ function
    | Effect.Unhandled (Yield elt) -> f (`Yield elt)
    | _ -> None

  let () = register_printer @@ fun _ -> Some "Unhandled algaeff effect; use Algaeff.Sequencer.run"
end
