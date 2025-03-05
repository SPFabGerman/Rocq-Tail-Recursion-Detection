From MetaCoq.Utils Require Import utils.
From MetaCoq.Template Require Import All.

Import IfNotations.
Import MCMonadNotation.

Require Import FixpointReference.
Require Import TailRecursionDetection.

(* This file contains all Monadic MetaCoq Programs and associated code. *)

(** Expects a term (generally a previously defined function).
Checks all the recursive references (in the global environment) that this term depends on.
Fails if at least one such reference is a Non-Tail-Recursive Call. *)
Definition ensure_tail_recursion {A} (t : A) : TemplateMonad unit :=
  '( {| declarations := d |}, tsyntax) <- tmQuoteRec t ;;
  match tsyntax with
  | tConst _ _ => tmReturn tt
  | _ => tmMsg "Provided term is not a defined object. Be aware that the term itself will not be checked."
  end ;;
  
  let fprs := find_all_rec_references_global d in
  monad_iter (fun fpr => tmMsg (string_of_FixpointReference fpr)) fprs ;;
  let alltailcall := forallb (fun fpr => if fpr.(kind) is NonTailcall then false else true) fprs in
  (if alltailcall then tmMsg "Program contains only Tail-recursive calls." else tmFail "Program contains Non-Tail-recursive calls.") ;;
  ret tt.
