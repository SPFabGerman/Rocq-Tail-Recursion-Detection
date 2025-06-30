From Corelib Require Extraction.
From Stdlib Require Import ZArith.

Set Extraction Output Directory "evaluation_out/Stdlib".

(* Extract OCaml programs of the Stdlib.
We can't use a fully qualified path here, so check that you have the correct library with About. *)
Recursive Extraction Library BinInt.
Recursive Extraction Library BinNat.
