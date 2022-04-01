open StdlibShim

module Deep =
struct
  let retinue k f =
    match f () with
    | x -> Effect.Deep.continue k x
    | exception e -> Effect.Deep.discontinue k e

  let retinue_preserving_backtrace k f =
    match f () with
    | x -> Effect.Deep.continue k x
    | exception e ->
      let bt = Printexc.get_raw_backtrace () in
      Effect.Deep.discontinue_with_backtrace k e bt
end

module Shallow =
struct
  let retinue_with k f h =
    match f () with
    | x -> Effect.Shallow.continue_with k x h
    | exception e -> Effect.Shallow.discontinue_with k e h

  let retinue_preserving_backtrace_with k f h =
    match f () with
    | x -> Effect.Shallow.continue_with k x h
    | exception e ->
      let bt = Printexc.get_raw_backtrace () in
      Effect.Shallow.discontinue_with_backtrace k e bt h
end
