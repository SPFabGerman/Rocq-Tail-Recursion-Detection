From Corelib Require Lists.ListDef
                     Floats.SpecFloat
                     BinNums.IntDef.

(* Check with our algorithm. *)
Require Import Commands.
From MetaRocq.Utils Require Import utils.

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
