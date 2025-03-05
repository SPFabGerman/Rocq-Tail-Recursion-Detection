Require Import Commands.

(* This file defines some basic recursive functions and then tests the monadic programs on them. *)

Fixpoint add (a b : nat) : nat :=
  match a with
    | 0 => b
    | S a => S ((add a) b)
  end.

Fixpoint add2 (a b : nat) : nat :=
  match a with
    | 0 => b
    | S a => (add2 a) (S b)
  end.

Fixpoint tfunc1 (a : nat) : bool :=
  match a with
    | 0 => true
    | S a => tfunc2 a
  end
with tfunc2 (a : nat) : bool :=
  match a with
    | 0 => false
    | S a => tfunc3 a
  end
with tfunc3 (a : nat) : bool :=
  match a with
    | 0 => false
    | S a => if tfunc4 a then false else true
  end
with tfunc4 (a : nat) : bool :=
  match a with
    | 0 => true
    | S a => tfunc1 a
  end.

Fail MetaCoq Run (ensure_tail_recursion add).
MetaCoq Run (ensure_tail_recursion add2).
Fail MetaCoq Run (ensure_tail_recursion tfunc1).