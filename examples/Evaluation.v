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

(* MetaRocq Run (check_tail_recursion_in_module "Corelib.Init.Logic" true false). *)
MetaRocq Run (check_tail_recursion_in_module "Corelib.Init.Datatypes" true false).
(* MetaRocq Run (check_tail_recursion_in_module "Corelib.Init.Specif" true false). *)
MetaRocq Run (check_tail_recursion_in_module "Corelib.Init.Decimal" true false).
MetaRocq Run (check_tail_recursion_in_module "Corelib.Init.Hexadecimal" true false).
MetaRocq Run (check_tail_recursion_in_module "Corelib.Init.Number" true false).
MetaRocq Run (check_tail_recursion_in_module "Corelib.Init.Nat" true false).
MetaRocq Run (check_tail_recursion_in_module "Corelib.Lists.ListDef" true false).
MetaRocq Run (check_tail_recursion_in_module "Corelib.Numbers.BinNums" true false).
MetaRocq Run (check_tail_recursion_in_module "Corelib.BinNums.PosDef" true false).
MetaRocq Run (check_tail_recursion_in_module "Corelib.BinNums.NatDef" true false).
MetaRocq Run (check_tail_recursion_in_module "Corelib.BinNums.IntDef" true false).
MetaRocq Run (check_tail_recursion_in_module "Corelib.Floats.FloatClass" true false).
MetaRocq Run (check_tail_recursion_in_module "Corelib.Floats.SpecFloat" true false).
