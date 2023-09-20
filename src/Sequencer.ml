module type Param =
sig
  type elt
end

module type S =
sig
  include Param

  val yield : elt -> unit
  val run : (unit -> unit) -> elt Seq.t
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

  let register_printer ?yield () = Printexc.register_printer @@ function
    | Effect.Unhandled (Yield elt) -> Option.map (fun f -> f elt) yield
    | _ -> None
end
