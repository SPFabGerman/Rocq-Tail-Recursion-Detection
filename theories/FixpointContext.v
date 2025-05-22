From MetaRocq.Utils Require Import utils.
From MetaRocq.Template Require Import All.

(** This file contains the definition of a fixpoint context.
    All relevant fixpoints in the current context are kept track of in a list
    of pairs of de Bruijn indices and names.
    When the context changes, these indices need to be updated accordingly. *)

(* The definition of a fixpoint context which is a list of
   pairs of de Bruijn indices and names. *)
Definition t := list (nat * name).

(** Converts a fixpoint term (or more accurately it's list of mutual definitions) into a context. *)
Definition get_fixpoint_context (fps : mfixpoint term) : t :=
  let '(i,l) := fold_right (fun fp '(i,l) => (i+1, (i, fp.(dname).(binder_name))::l)) (0,[]) fps
  in l.

(** Increases all indices in the context by [b]. *)
Definition apply_offset (context : t) (offset : nat) : t :=
  map (fun '(i,n) => (i+offset,n)) context.

(** If the specified [index] corresponds to a fixpoint in the current context,
    return it's name. Otherwise return [None]. *)
Definition get_name_from_context (context : t) (index : nat) : option name :=
  SetoidList.findA (fun i => i =? index) context.
