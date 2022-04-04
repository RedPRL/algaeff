(** Reusable effect-based components. *)

(** {1 Reusable components} *)

module State : module type of State

module Reader : module type of Reader

module Mutex : module type of Mutex

module Unmonad : module type of Unmonad

(** {1 Auxiliary functions and modules} *)

(** A {!module:Stdlib.Effect} shim for OCaml < 5.

    Add the following line to the beginning of the code:
    {[
      open Eff.StdlibShim
    ]}
*)
module StdlibShim : module type of StdlibShim

module Fun : module type of Fun
