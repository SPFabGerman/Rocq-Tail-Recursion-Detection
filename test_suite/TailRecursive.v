From TRchecker Require Import Commands.


(* Assert that the known tail-recursive function tail_add is recognised as such *)
MetaRocq Run (check_tail_recursion Nat.tail_add false true).

(* Assert that the known tail-recursive function tail_addmul is recognised as such *)
MetaRocq Run (check_tail_recursion Nat.tail_addmul false true).

(* Assert that the known tail-recursive function tail_mul is recognised as such *)
MetaRocq Run (check_tail_recursion Nat.tail_mul false true).