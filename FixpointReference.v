From MetaCoq.Utils Require Import utils.
From MetaCoq.Template Require Import All.

(* This file contains the basic definitions of [FixpointReference]. *)

Variant FixpointReferenceKind :=
  | Tailcall : FixpointReferenceKind
  | NonTailcall : FixpointReferenceKind
  | StandaloneReference : FixpointReferenceKind.

Record FixpointReference := mkFixpointReference {
  caller : name; (* Which fixpoint calls? What contains the reference? *)
  callee : name; (* Which fixpoint is being called? Which fixpoint is being referenced? *)
  in_definition : kername;
  callterm : term;
  kind : FixpointReferenceKind;
}.

Definition string_of_FixpointReference (fpr : FixpointReference) : string :=
  match fpr.(kind) with
  | Tailcall => "Tail-Recursive Call of "
  | NonTailcall => "Non-Tail-Recursive Call of "
  | StandaloneReference => "Standalone reference to "
  end
  ^ (string_of_name fpr.(callee)) ^ " in "
  ^ (string_of_name fpr.(caller)) ^ " ("
  ^ (string_of_kername fpr.(in_definition)) ^ "): "
  ^ (string_of_term fpr.(callterm)). (* TODO: Maybe we can pretty print this instead? *)