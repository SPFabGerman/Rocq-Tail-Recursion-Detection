(** This file contains the basic definitions of [FixpointReference]
    that models the relation between the calling and called function
    that has a [FixpointReferenceKind].
    Checking whether the function is a tailcall can be done using
    [is_tailcall] and the information about a FixpointReference can
    be represented as string using [string_of_FixpointReference]

    Note: These are mainly produced in TailRecursionDetection.v and
    used in Commands.v. *)

From MetaRocq.Utils Require Import utils.
From MetaRocq.Template Require Import All.

Import IfNotations.


(** The FixpointReferenceKind differentiates between a [Tailcall] and
    [NonTailcall] with the expected semantics.
    Also, it may be a [StandaloneReference], i.e. a reference to a regular
    function.
    And finally, it can be an [UnsupportedTerm] which is mainly used to
    indicate nested functions and fixpoints.*)
Variant FixpointReferenceKind :=
  | Tailcall            : FixpointReferenceKind
  | NonTailcall         : FixpointReferenceKind
  | StandaloneReference : FixpointReferenceKind
  | UnsupportedTerm     : FixpointReferenceKind.


(** This is the main construct to record all important informationen of
    recursive calls which are

    - the calling or referencing function [caller],
    - the called/referenced function [callterm] and function name [callee].
    - the definition in which the call is done and
    - the [FixpointReferenceKind] [kind]

    If [callterm] has kind [UnsupportedTerm], then [callee] is irrelevant and
    assumed to be [nAnon].
    (This should probably be solved with a Variant, not a Record, but for now
    it's fine.) *)
Record FixpointReference := mkFixpointReference {
  caller        : name;
  callee        : name;
  in_definition : kername;
  callterm      : term;
  kind          : FixpointReferenceKind;
}.


(** Returns [true], iff the fixpoint reference [fpr] is a [Tailcall].*)
Definition is_tailcall (fpr : FixpointReference) : bool :=
  if fpr.(kind) is Tailcall then true else false.


(** Creates a string representation of the FixpointReference [fpr]. *)
Definition string_of_FixpointReference (fpr : FixpointReference) : string :=
  match fpr.(kind) with
  | Tailcall            => "Tail-Recursive Call of " ^ (string_of_name fpr.(callee))
  | NonTailcall         => "Non-Tail-Recursive Call of " ^ (string_of_name fpr.(callee))
  | StandaloneReference => "Standalone reference to " ^ (string_of_name fpr.(callee))
  | UnsupportedTerm     => "Unsupported term found" 
  end ^ " in "
  ^ (string_of_name fpr.(caller)) ^ " ("
  ^ (string_of_kername fpr.(in_definition)) ^ "): "
  ^ (string_of_term fpr.(callterm)). (* TODO: Maybe we can pretty print this instead? *)