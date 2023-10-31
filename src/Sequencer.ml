module type S =
sig
  module Elt : Sigs.Type

  val yield : Elt.t -> unit
  val run : (unit -> unit) -> Elt.t Seq.t
  val register_printer : ([`Yield of Elt.t] -> string option) -> unit
end

module Make (Elt : Sigs.Type) =
struct
  type _ Effect.t += Yield : Elt.t -> unit Effect.t

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
