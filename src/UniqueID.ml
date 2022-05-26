module type Param =
sig
  type elt
end

module type S =
sig
  include Param

  type id = private int
  val unsafe_id_of_int : int -> id
  val register : elt -> id
  val retrieve : id -> elt
  val export : unit -> elt Seq.t
  val run : ?init:elt Seq.t -> (unit -> 'a) -> 'a
end

module Make (P : Param) =
struct
  include P

  type id = int
  let unsafe_id_of_int i = i

  type _ Effect.t +=
    | Insert : elt -> id Effect.t
    | Select : id -> elt Effect.t
    | Export : elt Seq.t Effect.t

  let register x = Effect.perform (Insert x)
  let retrieve i = Effect.perform (Select i)
  let export () = Effect.perform Export

  module M = Map.Make (Int)
  module Eff = State.Make (struct type state = elt M.t end)

  let run ?(init=Seq.empty) f =
    let init = M.of_seq @@ Seq.zip (Seq.ints 0) init in
    Eff.run ~init @@ fun () ->
    let open Effect.Deep in
    try_with f ()
      { effc = fun (type a) (eff : a Effect.t) ->
            match eff with
            | Insert x -> Option.some @@ fun (k : (a, _) continuation) ->
              let st = Eff.get () in
              let next = M.cardinal st in
              Eff.set @@ M.add next x st;
              continue k next
            | Select i -> Option.some @@ fun (k : (a, _) continuation) ->
              continue k @@ M.find i @@ Eff.get ()
            | Export -> Option.some @@ fun (k : (a, _) continuation) ->
              continue k @@ Seq.map snd @@ M.to_seq @@ Eff.get ()
            | _ -> None }
end
