(** EXPERIMENTAL *)

(** This is like Domain.at_startup and Domain.at_exit, but composable. *)

val scope : ?at_spawn:(unit -> unit) -> ?at_exit:(unit -> unit) -> (unit -> 'a) -> 'a
(* [scope ~at_spawn ~at_exit f] runs the thunk [f], and for spawn effects performed within [f],
   the function [at_spawn] will be run at the start of the spawned domain and then
   [at_exit] at the end of the domain (even when an exception is raised).

   [scope] can be arbitrarily nested: the outermost [at_spawn] will run first
   and the outermost [at_exit] will run last.
*)

val spawn : (unit -> 'a) -> 'a Domain.t
(* [spawn f] spawns a new domain to run [f]. *)

val run : (unit -> 'a) -> 'a
(* [run f] runs the thunk [f] that may perform spawn effects. *)
