(* Do the extraction first, as MetaRocq imports override Corelib. *)
From Corelib Require Extraction.
Set Extraction Output Directory "examples/evaluation_extracted_code".

(* Phase 1: Extract OCaml programs of the Corelib.
We can't use a fully qualified path here, so check that you have the correct library with About. *)
Recursive Extraction Library Nat. (* Corelib.Init.Nat *)



(* Phase 2: Cross check with our algorithm. *)
Require Import Commands.
From MetaRocq.Utils Require Import utils.

MetaRocq Run (check_tail_recursion_in_module "Corelib.Init.Nat" false false).