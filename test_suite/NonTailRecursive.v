From TRchecker Require Import Commands.


(* Assert that the known non tail-recursive function add is recognised as such *)
Fail MetaRocq Run (check_tail_recursion Nat.add false true).

(* Assert that the known non tail-recursive function mul is recognised as such *)
Fail MetaRocq Run (check_tail_recursion Nat.mul false true).
