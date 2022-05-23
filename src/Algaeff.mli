(** Reusable effects-based components. *)

(** {1 Reusable components} *)

module State : module type of State

module Reader : module type of Reader

module Mutex : module type of Mutex

module Unmonad : module type of Unmonad

(**/**)
module AutoIncrement : module type of AutoIncrement
(**/**)

(** {1 Auxiliary tools} *)

module Fun : module type of Fun
