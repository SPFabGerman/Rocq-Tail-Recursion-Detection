From Corelib Require Extraction.
From Corelib Require Lists.ListDef Floats.SpecFloat BinNums.IntDef.

Set Extraction Output Directory "evaluation_out/Corelib".

(* Extract OCaml programs of the Corelib.
We can't use a fully qualified path here, so check that you have the correct library with About. *)
Recursive Extraction Library Nat.       (* Corelib.Init.{Logic,Datatypes,Specif,Decimal,Hexadecimal,Number,Nat} *)
Recursive Extraction Library ListDef.   (* Corelib.Lists.ListDef *)
Recursive Extraction Library IntDef.    (* Corelib.Numbers.BinNums, Corelib.BinNums.{PosDef,NatDef,IntDef} *)
Recursive Extraction Library SpecFloat. (* Corelib.Floats.{FloatClass,SpecFloat} *)