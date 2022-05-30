module Deep =
struct
  let finally k f =
    match f () with
    | x -> Effect.Deep.continue k x
    | exception e -> Effect.Deep.discontinue k e
end

module Shallow =
struct
  let finally_with k f h =
    match f () with
    | x -> Effect.Shallow.continue_with k x h
    | exception e -> Effect.Shallow.discontinue_with k e h
end
