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

  val register_printer : ?read:string -> unit -> unit
end

module Make (P : Param) : S with type env = P.env
(** The implementation of read effects. *)
