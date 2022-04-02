open StdlibShim

module Deep =
struct
  let finally k f =
    match f () with
    | x -> Effect.Deep.continue k x
    | exception e -> Effect.Deep.discontinue k e

  let finally_preserving_backtrace k f =
    match f () with
    | x -> Effect.Deep.continue k x
    | exception e ->
      let bt = Printexc.get_raw_backtrace () in
      Effect.Deep.discontinue_with_backtrace k e bt

  let reperform k e =
    finally k @@ fun () -> Effect.perform e

  let reperform_preserving_backtrace k e =
    finally_preserving_backtrace k @@ fun () -> Effect.perform e
end

module Shallow =
struct
  let finally_with k f h =
    match f () with
    | x -> Effect.Shallow.continue_with k x h
    | exception e -> Effect.Shallow.discontinue_with k e h

  let finally_preserving_backtrace_with k f h =
    match f () with
    | x -> Effect.Shallow.continue_with k x h
    | exception e ->
      let bt = Printexc.get_raw_backtrace () in
      Effect.Shallow.discontinue_with_backtrace k e bt h

  let reperform_with k e =
    finally_with k @@ fun () -> Effect.perform e

  let reperform_preserving_backtrace_with k e =
    finally_preserving_backtrace_with k @@ fun () -> Effect.perform e
end
