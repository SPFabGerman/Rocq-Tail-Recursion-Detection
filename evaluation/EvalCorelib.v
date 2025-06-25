(* Do the extraction first, as MetaRocq imports override Corelib. *)
From Corelib Require Extraction.
From Corelib Require Lists.ListDef Floats.SpecFloat BinNums.IntDef.

Set Extraction Output Directory "evaluation_out/EvalCorelib".

(* Phase 1: Extract OCaml programs of the Corelib.
We can't use a fully qualified path here, so check that you have the correct library with About. *)
Recursive Extraction Library Nat. (* Corelib.Init.{Logic,Datatypes,Specif,Decimal,Hexadecimal,Number,Nat} *)
Recursive Extraction Library ListDef. (* Corelib.Lists.ListDef *)
Recursive Extraction Library IntDef. (* Corelib.Numbers.BinNums, Corelib.BinNums.{PosDef,NatDef,IntDef} *)
Recursive Extraction Library SpecFloat. (* Corelib.Floats.{FloatClass,SpecFloat} *)

(* Phase 2: Cross check with our algorithm. *)
Require Import Commands.
From MetaRocq.Utils Require Import utils.

MetaRocq Run (list_all_rec_calls_in_module "Corelib.Init.Logic").
MetaRocq Run (list_all_rec_calls_in_module "Corelib.Init.Datatypes").
MetaRocq Run (list_all_rec_calls_in_module "Corelib.Init.Specif").
MetaRocq Run (list_all_rec_calls_in_module "Corelib.Init.Decimal").
MetaRocq Run (list_all_rec_calls_in_module "Corelib.Init.Hexadecimal").
MetaRocq Run (list_all_rec_calls_in_module "Corelib.Init.Number").
MetaRocq Run (list_all_rec_calls_in_module "Corelib.Init.Nat").
MetaRocq Run (list_all_rec_calls_in_module "Corelib.Lists.ListDef").
MetaRocq Run (list_all_rec_calls_in_module "Corelib.Numbers.BinNums").
MetaRocq Run (list_all_rec_calls_in_module "Corelib.BinNums.PosDef").
MetaRocq Run (list_all_rec_calls_in_module "Corelib.BinNums.NatDef").
MetaRocq Run (list_all_rec_calls_in_module "Corelib.BinNums.IntDef").
MetaRocq Run (list_all_rec_calls_in_module "Corelib.Floats.FloatClass").
MetaRocq Run (list_all_rec_calls_in_module "Corelib.Floats.SpecFloat").
