module type Param =
sig
  type state
end

module type S =
sig
  include Param

  val get : unit -> state
  val set : state -> unit
  val modify : (state -> state) -> unit
  val run : init:state -> (unit -> 'a) -> 'a
end

module Make (P : Param) =
struct
  include P

  type _ Effect.t +=
    | Get : state Effect.t
    | Set : state -> unit Effect.t

  let get () = Effect.perform Get
  let set st = Effect.perform (Set st)

  let run ~(init:state) f =
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

  let register_printer ?get ?set () = Printexc.register_printer @@ function
  | Effect.Unhandled Get -> get
  | Effect.Unhandled (Set state) -> Option.map (fun f -> f state) set
  | _ -> None
end
