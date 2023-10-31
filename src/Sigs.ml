(** Common signatures shared across different components. *)

(** A signature carrying a type. *)
module type Type =
sig
  (** The type. *)
  type t
end
