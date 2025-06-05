(* Do the extraction first, as MetaRocq imports override Corelib. *)
From Corelib Require Extraction.
From Corelib Require Lists.ListDef Floats.SpecFloat BinNums.IntDef.
Set Extraction Output Directory "evaluation_out".

(* Phase 1: Extract OCaml programs of the Corelib.
We can't use a fully qualified path here, so check that you have the correct library with About. *)
Recursive Extraction Library Nat. (* Corelib.Init.{Logic,Datatypes,Specif,Decimal,Hexadecimal,Number,Nat} *)
Recursive Extraction Library ListDef. (* Corelib.Lists.ListDef *)
Recursive Extraction Library IntDef. (* Corelib.Numbers.BinNums, Corelib.BinNums.{PosDef,NatDef,IntDef} *)
Recursive Extraction Library SpecFloat. (* Corelib.Floats.{FloatClass,SpecFloat} *)



(* Phase 2: Cross check with our algorithm. *)
Require Import Commands.
From MetaRocq.Utils Require Import utils.

MetaRocq Run (check_tail_recursion_in_module "Corelib.Init.Logic" false false).
MetaRocq Run (check_tail_recursion_in_module "Corelib.Init.Datatypes" false false).
MetaRocq Run (check_tail_recursion_in_module "Corelib.Init.Specif" false false).
MetaRocq Run (check_tail_recursion_in_module "Corelib.Init.Decimal" false false).
MetaRocq Run (check_tail_recursion_in_module "Corelib.Init.Hexadecimal" false false).
MetaRocq Run (check_tail_recursion_in_module "Corelib.Init.Number" false false).
MetaRocq Run (check_tail_recursion_in_module "Corelib.Init.Nat" false false).
MetaRocq Run (check_tail_recursion_in_module "Corelib.Lists.ListDef" false false).
MetaRocq Run (check_tail_recursion_in_module "Corelib.Numbers.BinNums" false false).
MetaRocq Run (check_tail_recursion_in_module "Corelib.BinNums.PosDef" false false).
MetaRocq Run (check_tail_recursion_in_module "Corelib.BinNums.NatDef" false false).
MetaRocq Run (check_tail_recursion_in_module "Corelib.BinNums.IntDef" false false).
MetaRocq Run (check_tail_recursion_in_module "Corelib.Floats.FloatClass" false false).
MetaRocq Run (check_tail_recursion_in_module "Corelib.Floats.SpecFloat" false false).