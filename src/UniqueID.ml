module type S =
sig
  type elt

  module ID :
  sig
    type t = private int
    val equal : t -> t -> bool
    val compare : t -> t -> int
    val dump : Format.formatter -> t -> unit
    val unsafe_of_int : int -> t
  end
  type id = ID.t

  val register : elt -> id
  val retrieve : id -> elt
  val export : unit -> elt Seq.t
  val run : ?init:elt Seq.t -> (unit -> 'a) -> 'a
  val register_printer : ([`Register of elt | `Retrieve of id | `Export] -> string option) -> unit
end

module Make (Elt : Sigs.Type) =
struct
  module ID =
  struct
    type t = int
    let equal = Int.equal
    let compare = Int.compare
    let dump = Format.pp_print_int
    let unsafe_of_int i = i
  end
  type id = int

  type _ Effect.t +=
    | Register : Elt.t -> id Effect.t
    | Retrieve : id -> Elt.t Effect.t
    | Export : Elt.t Seq.t Effect.t

  let register x = Effect.perform (Register x)
  let retrieve i = Effect.perform (Retrieve i)
  let export () = Effect.perform Export

  module M = Map.Make (Int)
  module Eff = State.Make (struct type t = Elt.t M.t end)

  let run ?(init=Seq.empty) f =
    let init = M.of_seq @@ Seq.zip (Seq.ints 0) init in
    Eff.run ~init @@ fun () ->
    let open Effect.Deep in
    try_with f ()
      { effc = fun (type a) (eff : a Effect.t) ->
            match eff with
            | Register x -> Option.some @@ fun (k : (a, _) continuation) ->
              let st = Eff.get () in
              let next = M.cardinal st in
              Eff.set @@ M.add next x st;
              continue k next
            | Retrieve i -> Option.some @@ fun (k : (a, _) continuation) ->
              continue k @@ M.find i @@ Eff.get ()
            | Export -> Option.some @@ fun (k : (a, _) continuation) ->
              continue k @@ Seq.map snd @@ M.to_seq @@ Eff.get ()
            | _ -> None }

  let register_printer f = Printexc.register_printer @@ function
    | Effect.Unhandled (Register elt) -> f (`Register elt)
    | Effect.Unhandled (Retrieve id) -> f (`Retrieve id)
    | Effect.Unhandled Export -> f `Export
    | _ -> None

  let () = register_printer @@ fun _ -> Some "Unhandled algaeff effect; use Algaeff.UniqueID.run"
end
