(** Effects for making concurrent execution immediately fail. *)

(**
   {[
     module M = Algaeff.Mutex.Make ()

     let () = M.run @@ fun () ->
       let ten = M.exclusively @@ fun () -> 10 in
       let nine = M.exclusively @@ fun () -> 9 in
       (* this will print out 19 *)
       print_int (ten + nine)

     let _ = M.run @@ fun () ->
       M.exclusively @@ fun () ->
       (* this raise M.Locked *)
       M.exclusively @@ fun () ->
       100
   ]}
*)

(** Note that the exception {!exception:S.Locked} would be immediately raised
    for any attempt to lock an already locked mutex.
    The typical application of this component is to prevent erroneous concurrent API access,
    not to provide synchronization. Therefore, no waiting would happen.

    It is impossible to implement meaningful synchronization
    unless this module also handles lightweight threading.
    For applications that need synchronization between lightweight threads
    (so that one thread would wait for another thread to unlock the mutex),
    check out other libraries such as the {{: https://github.com/ocaml-multicore/eio}Eio}
    and {{: https://erratique.ch/software/affect}Affect}. *)

module type S =
sig
  (** The signature of mutex effects. *)

  exception Locked
  (** The exception raised by {!val:exclusively} if the mutex was locked. *)

  val exclusively : (unit -> 'a) -> 'a
  (** [exclusively f] locks the mutex, run the thunk [f], and then unlock the mutex.
      If the mutex was already locked, [exclusively f] immediately raises {!exception:Locked}
      without waiting. Note that calling [exclusively] inside [f] is an instance of
      attempting to lock an already locked mutex.

      @raises Locked The mutex was already locked. *)

  val run : (unit -> 'a) -> 'a
  (** [run f] executes the thunk [f] which may perform mutex effects.
      Each call of [run] creates a fresh mutex; in particular, calling [run] inside
      the thunk [f] will start a new scope that does not interfere with the outer scope. *)

  val register_printer : ([`Exclusively] -> string option) -> unit
  (** [register_printer p] registers a printer [p] via {!val:Printexc.register_printer} to convert unhandled internal effects into strings for the OCaml runtime system to display. Ideally, all internal effects should have been handled by {!val:run} and there is no need to use this function, but when it is not the case, this function can be helpful for debugging. The functor {!module:Modifier.Make} always registers a simple printer to suggest using {!val:run}, but you can register new ones to override it. The return type of the printer [p] should return [Some s] where [s] is the resulting string, or [None] if it chooses not to convert a particular effect. The registered printers are tried in reverse order until one of them returns [Some s] for some [s]; that is, the last registered printer is tried first. Note that this function is a wrapper of {!val:Printexc.register_printer} and all the registered printers (via this function or {!val:Printexc.register_printer}) are put into the same list.

      The input type of the printer [p] is a variant representing internal effects used in this module. It corresponds to all the effects trigger by {!val:exclusively}.

      @since 1.1.0
  *)
end

module Make () : S
(** The implementation of mutex effects. [Make] is generative so that one can use multiple
    mutexes at the same time. *)
