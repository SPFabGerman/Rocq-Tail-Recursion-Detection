From MetaRocq.Utils Require Import utils.
From MetaRocq.Template Require Import All.

(* This file contains the basic definitions of [FixpointReference].
These are mainly produced in TailRecursionDetection.v and used in Commands.v. *)

Variant FixpointReferenceKind :=
  | Tailcall : FixpointReferenceKind
  | NonTailcall : FixpointReferenceKind
  | StandaloneReference : FixpointReferenceKind
  | UnsupportedTerm : FixpointReferenceKind. (* Used mainly to indicate nested functions and fixpoints. *)

(** This is the main construct to record all important informationen
of recursive calls.
If [callterm] is [UnsupportedTerm], then [callee] is irrelevant and assumed to be [nAnon].
(This should probably be solved with a Variant, not a Record, but for now it's fine.) *)
Record FixpointReference := mkFixpointReference {
  caller : name; (* Which fixpoint calls? What contains the reference? *)
  callee : name; (* Which fixpoint is being called? Which fixpoint is being referenced? *)
  in_definition : kername;
  callterm : term;
  kind : FixpointReferenceKind;
}.

Definition string_of_FixpointReference (fpr : FixpointReference) : string :=
  match fpr.(kind) with
  | Tailcall => "Tail-Recursive Call of " ^ (string_of_name fpr.(callee))
  | NonTailcall => "Non-Tail-Recursive Call of " ^ (string_of_name fpr.(callee))
  | StandaloneReference => "Standalone reference to " ^ (string_of_name fpr.(callee))
  | UnsupportedTerm => "Unsupported term found" (* [callee] is ignored, if we have an unsupported term. *)
  end ^ " in "
  ^ (string_of_name fpr.(caller)) ^ " ("
  ^ (string_of_kername fpr.(in_definition)) ^ "): "
  ^ (string_of_term fpr.(callterm)). (* TODO: Maybe we can pretty print this instead? *)