(** This file contains the definition of a fixpoint context [t].
    All relevant fixpoints in the current context are kept track of in a list
    of pairs of de Bruijn indices and names.
    A context is created by [of_fix_term] and the name of a fixpoint can be
    fetched using [find_fix_term].
    When the context changes, these indices need to be updated accordingly,
    which is done by [apply_offset]. *)

From MetaRocq.Utils Require Import utils.
From MetaRocq.Template Require Import All.

(** The definition of a fixpoint context which is a list of
   pairs of de Bruijn indices and names. *)
Definition t := list (nat * name).

(** Converts a fixpoint term [fps] (or more accurately the list of mutual
    definitions) into a context. *)
Definition of_fix_term (fps : mfixpoint term) : t :=
  let '(i,context) :=
    fold_right (fun fp '(i,context') =>
      let fix_name := fp.(dname).(binder_name)
      in (i+1, (i, fix_name)::context')
    ) (0,[]) fps
  in context.

(** Increases all indices in the context by [offset]. *)
Definition apply_offset (context : t) (offset : nat) : t :=
  map (fun '(i,n) => (i+offset,n)) context.

(** Returns the [name] of the fixpoint at [index] in the current context
    if it exists an [None], otherwise. *)
Definition find_fixpoint_name (context : t) (index : nat) : option name :=
  SetoidList.findA (fun i => i =? index) context.
