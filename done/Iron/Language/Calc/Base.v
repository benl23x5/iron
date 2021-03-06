
Require Export Coq.Strings.String.
Require Export Coq.Arith.EqNat.

Require Export Iron.Hectic.Rip.
Require Export Iron.Hectic.Nope.


(* Less-than-equal for nats. *)
Fixpoint ble_nat (n m : nat): bool :=
 match n with
 | O => true
 | S n' =>
    match m with
    | O => false
    | S m' => ble_nat n' m'
    end
 end.


(* Greater-than-equal for nats. *)
Fixpoint bge_nat (n m : nat): bool :=
 match m with
 | O => true
 | S m' =>
    match n with
    | O => false
    | S n' => bge_nat n' m'
    end
 end.


(* Less-than for nats. *)
Definition blt_nat (n m: nat): bool :=
 (andb (negb (beq_nat n m)) (ble_nat n m)).


(* Greater-than for nats. *)
Definition bgt_nat (n m: nat): bool :=
 (andb (negb (beq_nat n m)) (bge_nat n m)).
