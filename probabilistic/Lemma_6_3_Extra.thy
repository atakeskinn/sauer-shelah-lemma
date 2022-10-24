theory Lemma_6_3_Extra
  imports Main Vector "HOL-Probability.Probability_Mass_Function" "HOL-Probability.Product_PMF"
begin

fun rnd_sbst :: "'a set \<Rightarrow> real \<Rightarrow> ('a \<Rightarrow> bool) pmf" where
  "rnd_sbst V p = Pi_pmf V False (\<lambda>_. bernoulli_pmf p)"

fun vector_of :: "'a pmf \<Rightarrow> nat \<Rightarrow> 'a vector pmf" where
  "vector_of f n = Pi_pmf {i::nat. i < n} None (\<lambda>i. if i < n then map_pmf Some f else return_pmf None)"

fun intersect :: "'a set \<Rightarrow> ('a \<Rightarrow> bool) \<Rightarrow> nat" where
  "intersect U S = card {u\<in>U. S u}"

fun intersect2 :: "'a set \<Rightarrow> ('a \<Rightarrow> bool) vector \<Rightarrow> nat vector" where
  "intersect2 U = map_vector (intersect U)"

fun fset :: "'a set \<Rightarrow> 'a \<Rightarrow> bool" where
  "fset S x = (x \<in> S)"

fun subsetof :: "('a \<Rightarrow> bool) \<Rightarrow> 'a set \<Rightarrow> bool" (infixl "\<sqsubseteq>" 60) where
  "S \<sqsubseteq> V = (\<forall>u. S u \<longrightarrow> u \<in> V)"

fun subsetof2 :: "('a \<Rightarrow> bool) vector \<Rightarrow> 'a set \<Rightarrow> bool" where
  "subsetof2 Ss V = (\<forall>S\<in>range Ss. S \<sqsubseteq> V)"

lemma vector_pred: "(\<forall>x\<in>range v. P x) \<longleftrightarrow> (\<forall>i. case v i of Some x \<Rightarrow> P x | None \<Rightarrow> True)"
  unfolding range_def by (simp split: option.splits, fastforce)

lemma subsetof_iff_subset: "S \<sqsubseteq> X \<longleftrightarrow> {x. S x} \<subseteq> X" by fastforce
lemma subset_iff_fset_subsetof: "Y \<subseteq> X \<longleftrightarrow> fset Y \<sqsubseteq> X" by auto
lemma fset_to_set: "fset {x. S x} = S" by fastforce
lemma set_to_fset: "{x. fset S x} = S" by fastforce
lemma card_pred_set: "card {x\<in>X. S x} = k \<Longrightarrow> card ({x. S x} \<inter> X) = k" by (simp add: Collect_conj_eq inf_commute)
lemma subsetof_Pow: "{S. S \<sqsubseteq> X} = fset ` Pow X" by force

lemma finite_fPow: "finite X \<Longrightarrow> finite {S. S \<sqsubseteq> X}" by (metis subsetof_Pow finite_Pow_iff finite_imageI)

lemma measure_Pi_pmf_PiE_dflt_subset:
  assumes "U \<subseteq> V" and "finite V"
  shows "measure_pmf.prob (Pi_pmf V dflt p) (PiE_dflt V dflt (\<lambda>x. if x \<in> U then B x else UNIV)) = (\<Prod>x\<in>U. measure_pmf.prob (p x) (B x))" 
  by (simp add: measure_Pi_pmf_PiE_dflt[OF assms(2)] prod.subset_diff[OF assms])

end