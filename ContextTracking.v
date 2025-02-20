From MetaCoq.Utils Require Import utils.
From MetaCoq.Template Require Import All.

(* Context Tracking *)
(* All relevant fixpoints in the current context are kept track of in a list of pairs of deBrujin indices and names.
When the context changes, these indices need to be updated accordingly. *)

Definition fixpointcontext := list (nat * name).

(** Converts a fixpoint term (or more accurately it's list of mutual definitions) into a context. *)
Definition get_fixpoint_context (fps : mfixpoint term) : fixpointcontext :=
  let '(i,l) := fold_right (fun fp '(i,l) => (i+1, (i, fp.(dname).(binder_name))::l)) (0,[]) fps
  in l.

(** Increases all indices in the context by [b]. *)
Definition increase_context (cur : fixpointcontext) (b : nat) : fixpointcontext :=
  map (fun '(i,n) => (i+b,n)) cur.

(** If the specified [index] corresponds to a fixpoint in the current context, return it's name.
Otherwise return [None]. *)
Fixpoint get_name_from_context (context : fixpointcontext) (index : nat) : option name :=
  match context with
  | [] => None
  | (i,n)::c => if i =? index then Some n else get_name_from_context c index
  end.
