open StdlibShim

module type Param =
sig
  type state
end

module type S =
sig
  include Param

  val get : unit -> state
  val set : state -> unit
  val run : init:state -> (unit -> 'a) -> 'a
end

module Make (P : Param) =
struct
  include P

  type _ Effect.t +=
    | Get : unit -> state Effect.t
    | Set : state -> unit Effect.t

  let get () = Effect.perform (Get ())
  let set st = Effect.perform (Set st)

  let run ~(init:state) f =
    let open Effect.Deep in
    let st = ref init in
    try_with f ()
      { effc = fun (type a) (eff : a Effect.t) ->
            match eff with
            | Get () -> Option.some @@ fun (k : (a, _) continuation) ->
              continue k !st
            | Set v -> Option.some @@ fun (k : (a, _) continuation) ->
              st := v; continue k ()
            | _ -> None }
end
