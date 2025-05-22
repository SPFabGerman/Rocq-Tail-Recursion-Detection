From MetaRocq.Utils Require Import utils.
From MetaRocq.Template Require Import All.

Import IfNotations.
Import MRMonadNotation.

Require Import FixpointReference.
Require Import TailRecursionDetection.

(* This file contains all Monadic MetaRocq Programs and associated code.
It build on the low level functions from TailRecursionDetection.v and
wraps them in higher level constructs and monads. *)

(** Checks the provided global declaration for all recursive references.
Ignores all inductive types and declarations without a defined constant (like Axioms, external functions, ...). *)
Definition find_all_rec_references_global (gds : global_declarations) : list FixpointReference :=
  flat_map
    (fun '(kn, gd) => if gd is ConstantDecl {| cst_body := Some(t) |} then find_all_rec_references t kn else [])
    gds.

(** MetaRocq Program: Expects a term (generally a previously defined function).
Checks all the recursive references (in the global environment) that this term depends on.
Fails if at least one such reference is a Non-Tail-Recursive Call. *)
Definition ensure_tail_recursion {A} (t : A) : TemplateMonad unit :=
  '( {| declarations := d |}, tsyntax) <- tmQuoteRec t ;;
  match tsyntax with
  | tConst _ _ => tmReturn tt
  | _ => tmMsg "Provided term is not a defined object. Be aware that the term itself will not be checked."
  end ;;
  
  let fprs := find_all_rec_references_global d in
  monad_iter (tmMsg ∘ string_of_FixpointReference) fprs ;;
  (if all_tailcalls fprs
    then tmMsg "Program contains only Tail-recursive calls."
    else tmFail "Program contains Non-Tail-recursive calls.") ;;
  ret tt.

(** Extracts the definition of every transparent constant in the list of global references from the current environment.
Silently ignores all constants marked as opaque (typically Axioms, Lemmas, ...).
Also ignores everything that isn't a constant (Inductive types, constructors and variables). *)
Definition get_all_definitions_from_references (grs : list global_reference) : TemplateMonad (list (kername * term)) :=
  (* We use a fold to ignore certain elements of the list. Otherwise this is just a normal map.
  This could have also been done with a flat_map, but a fold is more elegant. *)
  monad_fold_right (fun l gr =>
    match gr with
    | ConstRef kn =>
        cb <- tmQuoteConstant kn false ;;
        if cb is {| cst_body := Some(t) |} then ret ((kn, t) :: l) else ret l
    | _ => ret l
    end
  ) grs [].

(** MetaRocq Program: Expects a module name. Checks all the recursive references
of functions that are defined in that module.
If the module name is ambiguous, checks only the first one found.
Does not check dependencies, either of the module or of the definitions in it.
Always succeeds. *)
Definition check_tail_recursion_in_module (q: string) : TemplateMonad unit :=
  grs <- tmQuoteModule q ;;
  d <- get_all_definitions_from_references grs ;;
  let fprs := flat_map (fun '(kn, t) => find_all_rec_references t kn) d in
  monad_iter (tmMsg ∘ string_of_FixpointReference) fprs ;;
  (if all_tailcalls fprs
    then tmMsg "Module contains only Tail-recursive calls."
    else tmMsg "Module contains Non-Tail-recursive calls.") ;;
  ret tt.
