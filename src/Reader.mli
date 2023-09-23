(** Effects for reading immutable environments. *)

(**
   {[
     module R = Algaeff.Reader.Make (struct type env = int end)

     let () = R.run ~env:42 @@ fun () ->
       (* this will print out 42 *)
       print_int (R.read ());

       (* this will print out 43 *)
       R.scope (fun i -> i + 1) (fun () -> print_int (R.read ()));

       (* this will print out 42 again *)
       print_int (R.read ())
   ]}
*)

(** This should be equivalent to {!Unmonad} applying to the standard reader monad. *)

module type Param =
sig
  (** Parameters of read effects. *)

  type env
  (** The type of environments. *)
end

module type S =
sig
  (** Signatures of read effects. *)

  include Param
  (** @open *)

  val read : unit -> env
  (** Read the environment. *)

  val scope : (env -> env) -> (unit -> 'a) -> 'a
  (** [scope f t] runs the thunk [t] under the new environment that is the result of applying [f] to the current environment. *)

  val run : env:env -> (unit -> 'a) -> 'a
  (** [run t] runs the thunk [t] which may perform reading effects. *)

  val register_printer : ([`Read] -> string option) -> unit
  (** [register_printer p] registers a printer [p] via {!val:Printexc.register_printer} to convert the unhandled internal effect into a string for the OCaml runtime system to display. Ideally, the internal effect should have been handled by {!val:run} and there is no need to use this function, but when it is not the case, this function can be helpful for debugging. The functor {!module:Modifier.Make} always registers a simple printer to suggest using {!val:run}, but you can register new ones to override it. The return type of the printer [p] should return [Some s] where [s] is the resulting string, or [None] if it chooses not to convert a particular effect. The registered printers are tried in reverse order until one of them returns [Some s] for some [s]; that is, the last registered printer is tried first. Note that this function is a wrapper of {!val:Printexc.register_printer} and all the registered printers (via this function or {!val:Printexc.register_printer}) are put into the same list.

      The input type of the printer [p] is a variant representation of the only internal effect used in this module. It corresponds to the effect trigger by {!val:read}.

      @since 1.0.0
  *)
end

module Make (P : Param) : S with type env = P.env
(** The implementation of read effects. *)
