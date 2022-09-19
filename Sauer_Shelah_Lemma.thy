(*  Title:      Sauer_Shelah_Lemma.thy
    Author:     Ata Keskin, TU München
*)

theory Sauer_Shelah_Lemma
  imports Main Shattering Card_Lemmas Binomial_Lemmas
begin

text \<open>Generalized Sauer-Shelah Lemma\<close>
lemma sauer_shelah_0:
  fixes F :: "'a set set"
  shows "finite (\<Union> F) \<Longrightarrow> card F \<le> card (shattered_by F)"
proof (induction F rule: measure_induct_rule[of "card"])
  case (less F)
  note finite_F = finite_UnionD[OF less(2)]
  note finite_shF = finite_shattered_by[OF less(2)]
  show ?case
  proof (cases "2 \<le> card F")
    case True
    from difference_element_exists[OF True] obtain x :: 'a where x_in_Union_F: "x \<in> \<Union>F" and x_not_in_Int_F: "x \<notin> \<Inter>F" by blast

    \<comment> \<open>Define F0 as the subfamily of F containing those sets that don't contain x\<close>
    let ?F0 = "{S \<in> F. x \<notin> S}"
    from x_in_Union_F have F0_psubset_F: "?F0 \<subset> F" by blast
    from F0_psubset_F have F0_in_F: "?F0 \<subseteq> F" by blast
    from subset_shattered_by[OF F0_in_F] have shF0_subset_shF: "shattered_by ?F0 \<subseteq> shattered_by F" .
    from F0_in_F have Un_F0_in_Un_F:"\<Union> ?F0 \<subseteq> \<Union> F" by blast

    \<comment> \<open>F0 shatters at least as many sets as |F0| by the induction hypothesis\<close>
    note IH_F0 = less(1)[OF psubset_card_mono[OF finite_F F0_psubset_F] rev_finite_subset[OF less(2) Un_F0_in_Un_F]]

    \<comment> \<open>Define F1 as the subfamily of F containing those sets that contain x\<close>
    let ?F1 = "{S \<in> F. x \<in> S}"
    from x_not_in_Int_F have F1_psubset_F: "?F1 \<subset> F" by blast
    from F1_psubset_F have F1_in_F: "?F1 \<subseteq> F" by blast
    from subset_shattered_by[OF F1_in_F] have shF1_subset_shF: "shattered_by ?F1 \<subseteq> shattered_by F" .
    from F1_in_F have Un_F1_in_Un_F:"\<Union> ?F1 \<subseteq> \<Union> F" by blast

    \<comment> \<open>F1 shatters at least as many sets as |F1| by the induction hypothesis\<close>
    note IH_F1 = less(1)[OF psubset_card_mono[OF finite_F F1_psubset_F] rev_finite_subset[OF less(2) Un_F1_in_Un_F]]

    from shF0_subset_shF shF1_subset_shF have shattered_subset: "(shattered_by ?F0) \<union> (shattered_by ?F1) \<subseteq> shattered_by F" by simp
    
    have f_copies_the_intersection:
      "\<exists>f. inj_on f (shattered_by ?F0 \<inter> shattered_by ?F1) \<and>
       (shattered_by ?F0 \<union> shattered_by ?F1) \<inter> (f ` (shattered_by ?F0 \<inter> shattered_by ?F1)) = {} \<and>
       f ` (shattered_by ?F0 \<inter> shattered_by ?F1) \<subseteq> shattered_by F"
    proof
      have x_not_in_shattered: "\<forall>S\<in>(shattered_by ?F0) \<union> (shattered_by ?F1). x \<notin> S" unfolding shattered_by_def by blast
      
      let ?f = "\<lambda>S. S \<union> {x}"
      have 0: "inj_on ?f (shattered_by ?F0 \<inter> shattered_by ?F1)"
      proof
        fix X Y
        assume x0: "X \<in> (shattered_by ?F0 \<inter> shattered_by ?F1)" and y0: "Y \<in> (shattered_by ?F0 \<inter> shattered_by ?F1)"
               and 0: "X \<union> {x} = Y \<union> {x}"
        from x_not_in_shattered x0 have "X = X \<union> {x} - {x}" by blast
        also from 0 have "... = Y \<union> {x} - {x}" by argo
        also from x_not_in_shattered y0 have "... = Y" by blast
        finally show "X = Y" .
      qed

      have 1: "(shattered_by ?F0 \<union> shattered_by ?F1) \<inter> ?f ` (shattered_by ?F0 \<inter> shattered_by ?F1) = {}"
      proof (rule ccontr)
        assume "(shattered_by ?F0 \<union> shattered_by ?F1) \<inter> ?f ` (shattered_by ?F0 \<inter> shattered_by ?F1) \<noteq> {}"
        then obtain S where 10: "S \<in> (shattered_by ?F0 \<union> shattered_by ?F1)" and 11: "S \<in> ?f ` (shattered_by ?F0 \<inter> shattered_by ?F1)" by auto
        from 10 x_not_in_shattered have "x \<notin> S" by blast
        with 11 show "False" by blast
      qed

      have 2: "?f ` (shattered_by ?F0 \<inter> shattered_by ?F1) \<subseteq> shattered_by F"
      proof 
        fix S_x
        assume "S_x \<in> ?f ` (shattered_by ?F0 \<inter> shattered_by ?F1)"
        then obtain S where 20: "S \<in> shattered_by ?F0" and 21: "S \<in> shattered_by ?F1" and 22: "S_x = insert x S" by blast
        from x_not_in_shattered 20 have x_not_in_S: "x \<notin> S" by blast

        from 22 Pow_insert[of x S] have "Pow S_x = Pow S \<union> insert x ` Pow S" by fast
        also from 20 have "... = ?F0 \<inter>* S \<union> insert x ` Pow S" unfolding shattered_by_def by blast
        also from 21 have "... = ?F0 \<inter>* S \<union> insert x ` (?F1 \<inter>* S)" unfolding shattered_by_def by force
        also from insert_IntF[of x S ?F1] have "... = ?F0 \<inter>* S \<union> (insert x ` ?F1 \<inter>* (insert x S))" by argo
        also from 22 have "... = ?F0 \<inter>* S \<union> ?F1 \<inter>* S_x" by blast
        also from 22 have "... = ?F0 \<inter>* S_x \<union> ?F1 \<inter>* S_x" by blast
        also from subset_IntF[OF F0_in_F, of S_x] subset_IntF[OF F1_in_F, of S_x] have "... \<subseteq> F \<inter>* S_x" by blast
        finally have "Pow S_x \<subseteq> F \<inter>* S_x" .
        thus "S_x \<in> shattered_by F" unfolding shattered_by_def by blast
      qed

      from 0 1 2 show "inj_on ?f (shattered_by ?F0 \<inter> shattered_by ?F1) \<and>
        (shattered_by ?F0 \<union> shattered_by ?F1) \<inter> (?f ` (shattered_by ?F0 \<inter> shattered_by ?F1)) = {} \<and>
        ?f ` (shattered_by ?F0 \<inter> shattered_by ?F1) \<subseteq> shattered_by F" by blast
    qed

    have F0_union_F1_is_F: "?F0 \<union> ?F1 = F" by fastforce
    from finite_F have finite_F0: "finite ?F0" and finite_F1: "finite ?F1" by fastforce+
    have disjoint_F0_F1: "?F0 \<inter> ?F1 = {}" by fastforce
    
    from F0_union_F1_is_F card_Un_disjoint[OF finite_F0 finite_F1 disjoint_F0_F1] 
    have "card F = card ?F0 + card ?F1" by argo
    also from IH_F0
    have "... \<le> card (shattered_by ?F0) + card ?F1" by linarith
    also from IH_F1
    have "... \<le> card (shattered_by ?F0) + card (shattered_by ?F1)" by linarith
    also from card_Int_copy[OF finite_shF shattered_subset f_copies_the_intersection]
    have "... \<le> card (shattered_by F)" by argo
    finally show ?thesis .
  next
    case False
    hence "card F = 0 \<or> card F = 1" by force
    thus ?thesis
    proof
      assume "card F = 0"
      thus ?thesis by auto
    next
      assume asm: "card F = 1"
      hence F_not_empty: "F \<noteq> {}" by fastforce
      from shatters_empty[OF F_not_empty] have "{{}} \<subseteq> shattered_by F" unfolding shattered_by_def by fastforce
      from card_mono[OF finite_shF this] asm show ?thesis by fastforce
    qed
  qed
qed

text \<open>Sauer-Shelah Lemma\<close>
corollary sauer_shelah:
  fixes F :: "'a set set"
  assumes "finite (\<Union>F)" and "(\<Sum>i\<le>k. card (\<Union>F) choose i) < card F"
  shows "\<exists>S. (F shatters S \<and> card S = k + 1)"
proof -
  let ?K = "{S. S \<subseteq> \<Union>F \<and> card S \<le> k}"
  from finite_Pow_iff[of F] assms(1) have finite_Pow_Un: "finite (Pow (\<Union>F))" by fast

  from sauer_shelah_0[OF assms(1)] assms(2) have "(\<Sum>i\<le>k. card (\<Union>F) choose i) < card (shattered_by F)" by linarith
  with choose_row_sum_set[OF assms(1), of k] have "card ?K < card (shattered_by F)" by presburger

  from finite_diff_not_empty[OF finite_subset[OF _ finite_Pow_Un] this]
  have "shattered_by F - ?K \<noteq> {}" by blast
  then obtain S where "S \<in> shattered_by F - ?K" by blast
  then have F_shatters_S: "F shatters S" and "S \<subseteq> \<Union>F" and "\<not>(S \<subseteq> \<Union>F \<and> card S \<le> k)" unfolding shattered_by_def by blast+
  then have card_S_ge_Suc_k: "k + 1 \<le> card S" by simp
  with card_ge_0_finite have "finite S" by force
  from finite_subset_exists[OF this card_S_ge_Suc_k] obtain S' where "card S' = k + 1" and "S' \<subseteq> S" by blast
  from this(1) supset_shatters[OF this(2) F_shatters_S] show ?thesis by blast
qed

text \<open>Sauer-Shelah Lemma for hypergraphs\<close>
corollary sauer_shelah_2:
  fixes X :: "'a set set" and S :: "'a set"
  assumes "finite S" and "X \<subseteq> Pow S" and "(\<Sum>i\<le>k. card S choose i) < card X"
  shows "\<exists>Y. (X shatters Y \<and> card Y = k + 1)"
proof -
  from assms(2) have 0: "\<Union>X \<subseteq> S" by blast
  from sum_mono[OF choose_mono[OF card_mono[OF assms(1) 0]]] have "(\<Sum>i\<le>k. card (\<Union>X) choose i) \<le> (\<Sum>i\<le>k. card S choose i)" by fast
  with sauer_shelah[OF finite_subset[OF 0 assms(1)]] assms(3) show ?thesis by simp
qed

text \<open>Alternative statement of the Sauer-Shelah Lemma\<close>
corollary sauer_shelah_alt:
  assumes "finite (\<Union>F)" and "VC_dim F = k"
  shows "card F \<le> (\<Sum>i\<le>k. card (\<Union>F) choose i)"
proof (rule ccontr)
  assume "\<not> card F \<le> (\<Sum>i\<le>k. card (\<Union>F) choose i)" hence "(\<Sum>i\<le>k. card (\<Union>F) choose i) < card F" by linarith
  from sauer_shelah[OF assms(1) this] obtain S where "F shatters S" and "card S = k + 1" by blast
  from this(1) this(2)[symmetric] have "k + 1 \<in> {card S | S. F shatters S}" by blast
  from cSup_upper[OF this bdd_above_finite[OF finite_image_set[OF finite_shattered_by[unfolded shattered_by_def, OF assms(1)]]], folded VC_dim_def] 
       assms(2) show False by force
qed

end