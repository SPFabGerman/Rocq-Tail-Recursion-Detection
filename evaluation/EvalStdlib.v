(* Do the extraction first, as MetaRocq imports override Corelib. *)
From Corelib Require Extraction.
From Corelib Require Lists.ListDef Floats.SpecFloat BinNums.IntDef.

From Stdlib Require Import ZArith.

Set Extraction Output Directory "evaluation_out/EvalStdlib".

(* Phase 1: Extract OCaml programs of the Corelib.
We can't use a fully qualified path here, so check that you have the correct library with About. *)
Recursive Extraction Library Nat. (* Corelib.Init.{Logic,Datatypes,Specif,Decimal,Hexadecimal,Number,Nat} *)
Recursive Extraction Library ListDef. (* Corelib.Lists.ListDef *)
Recursive Extraction Library IntDef. (* Corelib.Numbers.BinNums, Corelib.BinNums.{PosDef,NatDef,IntDef} *)
Recursive Extraction Library SpecFloat. (* Corelib.Floats.{FloatClass,SpecFloat} *)

Recursive Extraction Library BinInt.
Recursive Extraction Library BinNat.

Definition show_all := true.

(* Phase 2: Cross check with our algorithm. *)
Require Import Commands.
From MetaRocq.Utils Require Import utils.

Definition evaluate_module := if show_all then list_reccalls_in_module else list_nontail_calls_in_module.


MetaRocq Run (evaluate_module "Corelib.Init.Logic").
MetaRocq Run (evaluate_module "Corelib.Init.Datatypes").
MetaRocq Run (evaluate_module "Corelib.Init.Specif").
MetaRocq Run (evaluate_module "Corelib.Init.Decimal").
MetaRocq Run (evaluate_module "Corelib.Init.Hexadecimal").
MetaRocq Run (evaluate_module "Corelib.Init.Number").
MetaRocq Run (evaluate_module "Corelib.Init.Nat").
MetaRocq Run (evaluate_module "Corelib.Lists.ListDef").
MetaRocq Run (evaluate_module "Corelib.Numbers.BinNums").
MetaRocq Run (evaluate_module "Corelib.BinNums.PosDef").
MetaRocq Run (evaluate_module "Corelib.BinNums.NatDef").
MetaRocq Run (evaluate_module "Corelib.BinNums.IntDef").
MetaRocq Run (evaluate_module "Corelib.Floats.FloatClass").
MetaRocq Run (evaluate_module "Corelib.Floats.SpecFloat").

MetaRocq Run (evaluate_module "Stdlib.ZArith.BinInt").
MetaRocq Run (evaluate_module "Stdlib.NArith.BinNat").
MetaRocq Run (evaluate_module "Stdlib.PArith.BinPos").
