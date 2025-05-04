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

Fixpoint ack m n :=
  match m, n with
  | 0,    n'   => add n' 1
  | S m', 0    => ack m' 1
  | S m', S n' => let t := ack m' n'
                  in ack m' t
  end.

Fixpoint even n :=
  match n with
  | 0 => true
  | S n' => odd n'
  end
with odd n :=
  match n with
  | 0 => false
  | S n' => even n'
  end.

Fail MetaRocq Run (ensure_tail_recursion add).
MetaRocq Run (ensure_tail_recursion add2).
Fail MetaRocq Run (ensure_tail_recursion ack).
MetaRocq Run (ensure_tail_recursion even).