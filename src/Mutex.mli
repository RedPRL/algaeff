(** Mutexes to make concurrent execution immediately fail.

    Note that the exception {!exception:S.Locked} would be immediately raised
    for any attempt to lock an already locked mutex.
    The typical application of this component is to protect
    an API from being accessed concurrently,
    not to provide synchronization between lightweight threads.
    Therefore, no waiting would happen.

    It is impossible to implement waiting queues unless this module also
    handles lightweight threading.
    For applications that need synchronization between lightweight threads
    (so that one thread would wait for another thread to unlock the mutex),
    check other libraries such as the {{: https://github.com/ocaml-multicore/eio}Eio} and {{: https://erratique.ch/software/affect}Affect}.
*)

(** The signature of locking effects. *)
module type S =
sig
  exception Locked
  (** The exception raised by {!val:exclusively} if the mutex is locked. *)

  val exclusively : (unit -> 'a) -> 'a
  (** [exclusively f] locks the mutex, run the thunk [f], and then unlock the mutex.
      If the mutex was already locked, [exclusively f] immediately raises {!exception:Locked}
      without waiting. Note that calling [exclusively] inside [f] is an instance of
      attempting to lock an already locked mutex.

      @raises Locked The mutex was already locked.
  *)

  val run : (unit -> 'a) -> 'a
  (** [run f] executes the thunk [f] which might perform locking effects.
      Each call of [run] creates a fresh mutex; in particular, calling [run] inside
      the thunk [f] will start a new scope that does not interfere with the outer scope.
  *)
end

(** The implementation of locking effects. [Make] is generative so that one can use multiple
    mutexes at the same time. *)
module Make () : S
