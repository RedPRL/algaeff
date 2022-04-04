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
end

module Make () : S
(** The implementation of mutex effects. [Make] is generative so that one can use multiple
    mutexes at the same time. *)
