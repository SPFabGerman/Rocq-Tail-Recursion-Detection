(* Do the extraction first, as MetaRocq imports override Corelib. *)
From Corelib Require Extraction.

From Stdlib Require Import ZArith.


Set Extraction Output Directory "evaluation_out/Stdlib".

(* Phase 1: Extract OCaml programs of the Stdlib.
We can't use a fully qualified path here, so check that you have the correct library with About. *)
Recursive Extraction Library BinInt.
Recursive Extraction Library BinNat.

(* Phase 2: Cross check with our algorithm. *)
Require Import Commands.
From MetaRocq.Utils Require Import utils.

(* The following modules are dependencies of BinInt, BinNat or BinPos. Thus, we have to check them, too. *)
MetaRocq Run (list_all_rec_calls_in_module "Corelib.Init.Specif").
MetaRocq Run (list_all_rec_calls_in_module "Corelib.Init.Datatypes").
MetaRocq Run (list_all_rec_calls_in_module "Corelib.Init.Nat").
MetaRocq Run (list_all_rec_calls_in_module "Corelib.Init.Decimal").
MetaRocq Run (list_all_rec_calls_in_module "Corelib.Init.Hexadecimal").
MetaRocq Run (list_all_rec_calls_in_module "Corelib.BinNums.NatDef").
MetaRocq Run (list_all_rec_calls_in_module "Corelib.BinNums.PosDef").
MetaRocq Run (list_all_rec_calls_in_module "Corelib.Numbers.BinNums").

MetaRocq Run (list_all_rec_calls_in_module "Stdlib.ZArith.BinInt").
MetaRocq Run (list_all_rec_calls_in_module "Stdlib.NArith.BinNat").
MetaRocq Run (list_all_rec_calls_in_module "Stdlib.PArith.BinPos").
