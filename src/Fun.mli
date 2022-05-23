(** Useful helper functions around effects. *)

module Deep :
sig
  (** Useful helper functions for deep handlers. *)

  val finally : ('a, 'b) Effect.Deep.continuation -> (unit -> 'a) -> 'b
  (** [finally f] runs the thunk [f] and calls [continue] if a value is returned and [discontinue] if an exception is raised.
      Here is an example that calls {!val:List.nth} and then either returns the found element with [continue]
      or raises the exception {!exception:Not_found} with [discontinue].
      {[
        Algaeff.Fun.Deep.finally k @@ fun () -> List.nth elements n
      ]}
  *)

  val reperform : ('a, 'b) Effect.Deep.continuation -> 'a Effect.t -> 'b
  (** [reperform k e] performs the effect [e] and then resumes the execution with the continuation [k], in a way similar to {!val:finally}.
      It relays the result of performing the effect [e] with [continue] or [discontinue] depending on whether an exception is raised. *)
end

module Shallow :
sig
  (** Useful helper functions for shallow handlers. *)

  val finally_with : ('a, 'b) Effect.Shallow.continuation -> (unit -> 'a) -> ('b, 'c) Effect.Shallow.handler -> 'c
  (** See {!val:Deep.finally}. *)

  val reperform_with : ('a, 'b) Effect.Shallow.continuation -> 'a Effect.t -> ('b, 'c) Effect.Shallow.handler -> 'c
  (** See {!val:Deep.reperform}. *)
end
