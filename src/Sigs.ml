(** Signatures shared across different components. *)

(** This is a type wrapped as a module. *)
module type Type =
sig
  (** The wrapped type. *)
  type t
end
