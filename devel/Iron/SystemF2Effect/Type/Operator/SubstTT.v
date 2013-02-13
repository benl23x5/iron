
Require Export Iron.SystemF2Effect.Type.KiJudge.
Require Export Iron.SystemF2Effect.Type.Operator.LiftTT.
Require Export Iron.SystemF2Effect.Type.Operator.SubstTT.Base.
Require Export Iron.SystemF2Effect.Type.Operator.SubstTT.LemLiftTT.
Require Export Iron.SystemF2Effect.Type.Operator.SubstTT.LemLowerTT.
Require Export Iron.SystemF2Effect.Type.Operator.SubstTT.LemEquivT.


(********************************************************************)
(* Commuting substitutions. *)
Lemma substTT_substTT
 :  forall n m t1 t2 t3
 ,  substTT (n + m) t3 (substTT n t2 t1)
 =  substTT n (substTT (n + m) t3 t2)
              (substTT (1 + n + m) (liftTT 1 n t3) t1).
Proof.
 intros. gen n m t2 t3.
 induction t1; intros;
  try (solve [simpl; f_equal; rewritess; norm]).

 Case "TVar".
  repeat (simpl; split_match; repeat norm_nat_compare);
   first [omega | burn].

 Case "TForall".
  simpl.
  rewrite (IHt1 (S n) m). 
  rewrite (liftTT_substTT_1 0 (n + m)).
  rewrite (liftTT_liftTT_11 0 n).
  burn.
Qed.


(********************************************************************)
(* Substitution of types in types preserves kinding.
   Must also subst new new type into types in env higher than ix
   otherwise indices that reference subst type are broken, and 
   the resulting type env would not be well formed *)
Theorem subst_type_type_ix
 :  forall ix ke sp t1 k1 t2 k2
 ,  get ix ke = Some k2
 -> KIND ke sp t1 k1
 -> KIND (delete ix ke) sp t2 k2
 -> KIND (delete ix ke) sp (substTT ix t2 t1) k1.
Proof.
 intros. gen ix ke sp t2 k1 k2.
 induction t1; intros; simpl; inverts_kind; eauto.

 Case "TVar".
  fbreak_nat_compare.
  SCase "n = ix".
   rewrite H in H5.
   inverts H5. auto.

  SCase "n < ix".
   apply KiVar. rewrite <- H5.
   apply get_delete_above; auto.

  SCase "n > ix".
   apply KiVar. rewrite <- H5.
   destruct n.
    burn.
    simpl. nnat. apply get_delete_below. omega.

 Case "TForall".
  apply KiForall.
  rewrite delete_rewind.
  eapply IHt1; eauto.
   apply kind_kienv_weaken; auto.

 Case "TCon2".
  eapply KiCon2.
  destruct tc. simpl in *. inverts H4.
  destruct t.  simpl in *. eauto.
  eauto.
  destruct tc. simpl in *. inverts H4.
  eauto.
Qed.


Theorem subst_type_type
 :  forall ke sp t1 k1 t2 k2
 ,  KIND (ke :> k2) sp t1 k1
 -> KIND ke         sp t2 k2
 -> KIND ke sp (substTT 0 t2 t1) k1.
Proof.
 intros.
 unfold substTT.
 rrwrite (ke = delete 0 (ke :> k2)).
 eapply subst_type_type_ix; burn.
Qed.


(********************************************************************)
(* If we can lower a particular index then the term does not use it, 
   so we can delete the corresponding slot from the enviornment. *)
Theorem lower_type_type_ix
 :  forall ix ke sp t1 k1 t2
 ,  lowerTT ix t1 = Some t2
 -> KIND ke sp t1 k1
 -> KIND (delete ix ke) sp t2 k1.
Proof.
 intros. gen ix ke sp k1 t2.
 induction t1; intros; simpl;
  try (solve [inverts_kind; snorm; eauto; nope]).

 Case "TVar".
  inverts_kind. snorm.
   SCase "n > ix".
    eapply KiVar.
    rewrite <- H4.
    destruct n.
     simpl. burn.
     simpl. norm. eapply get_delete_below. omega.

 Case "TForall".
  inverts_kind. snorm. 
   eapply KiForall.
   rewrite delete_rewind.
   eauto. nope.

 Case "TCon2".
  inverts_kind. snorm.
  eapply KiCon2; eauto.
   destruct tc; destruct t; eauto.
   nope. nope.
Qed.


Theorem lower_type_type
 :  forall t1 t2 ke sp k1 k2
 ,  lowerTT 0 t1 = Some t2
 -> KIND (ke :> k1) sp t1 k2 
 -> KIND ke         sp t2 k2.
Proof.
 intros.
 lets D: lower_type_type_ix H H0.
 simpl in D. auto.
Qed.
