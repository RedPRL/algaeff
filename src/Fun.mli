open StdlibShim

(** Useful helper functions around effects. *)

module Deep :
sig

  val finally : ('a, 'b) Effect.Deep.continuation -> (unit -> 'a) -> 'b
  (**
     There are cases where one wants to resume a continuation with an expression, regardless of whether the expression will raise an exception or not. The current OCaml API forces us to choose between [continue] and [discontinue], depending on whether the expression is returning a value or raising an exception. I am tired of writing the boilerplate to redirect the value/exception. This simple function will do the right thing in both cases. Usage:
     {[
       Eff.Fun.Deep.finally k @@ fun () -> some OCaml expression
     ]}
  *)

  val reperform : ('a, 'b) Effect.Deep.continuation -> 'a Effect.t -> 'b
  (** [reperform k e] performs the effect [e] and continues the execution with the continuation [k], in a way similar to {!val:finally}. *)
end

module Shallow :
sig
  val finally_with : ('a, 'b) Effect.Shallow.continuation -> (unit -> 'a) -> ('b, 'c) Effect.Shallow.handler -> 'c
  (** See {!val:Deep.finally}. *)

  val reperform_with : ('a, 'b) Effect.Shallow.continuation -> 'a Effect.t -> ('b, 'c) Effect.Shallow.handler -> 'c
  (** See {!val:Deep.reperform}. *)
end
