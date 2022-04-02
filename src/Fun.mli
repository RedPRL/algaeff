open StdlibShim

module Deep :
sig

  val finally : ('a, 'b) Effect.Deep.continuation -> (unit -> 'a) -> 'b
  (**
     There are cases where one wants to resume a continuation with an expression, regardless of whether the expression will raise an exception or not. The current OCaml API forces us to choose between [continue] and [discontinue], depending on whether the expression is returning a value or raising an exception. I am tired of writing the boilerplate to redirect the value/exception. This simple function will do the right thing in both cases. Usage:
     {[
       Eff.Fun.Deep.finally k @@ fun () -> some OCaml expression
     ]}
  *)

  val finally_preserving_backtrace : ('a, 'b) Effect.Deep.continuation -> (unit -> 'a) -> 'b
  (**
     A variant of {!val:finally} that preserves the backtrace of the exception thrown by the expression. I am still not sure whether this is in general a good idea, because the backtrace associated with the original {!val:Effect.perform} could potentially be more useful for debugging than that associated with the {!val:raise} inside the OCaml expression. (This is different from exception handling where original backtraces are probably always better.)
     {[
       Eff.Fun.Deep.finally_preserving_backtrace k @@ fun () -> some OCaml expression
     ]}
  *)
end

module Shallow :
sig
  val finally_with : ('a, 'b) Effect.Shallow.continuation -> (unit -> 'a) -> ('b, 'c) Effect.Shallow.handler -> 'c
  (** See {!val:Deep.finally}. *)

  val finally_preserving_backtrace_with : ('a, 'b) Effect.Shallow.continuation -> (unit -> 'a) -> ('b, 'c) Effect.Shallow.handler -> 'c
  (** See {!val:Deep.finally_preserving_backtrace}. *)
end
