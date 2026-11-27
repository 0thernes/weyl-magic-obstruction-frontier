module
-- SPDX-License-Identifier: Apache-2.0
-- Copyright (c) 2026 Alexander Stephen Donahue

public import Challenge
public import WeylMagic

/-!
# Complete Machine-Checked Solution (`Solution.lean`)

Discharges all 22 numbered theorem targets (`T1a`–`T5d`) and the master conjunction
with zero `sorry`, zero `admit`, zero `native_decide`, and zero custom axioms.
-/

namespace WeylMagic.Solution

@[expose] public section

theorem prove_t1a : WeylMagic.Spec.stmt_t1a :=
  fun n hn3 hodd K => WeylMagic.odd_two_adic_square_impossible n hn3 hodd K

theorem prove_t1b : WeylMagic.Spec.stmt_t1b :=
  fun n s hs => WeylMagic.pauli_idempotence_forces_square n s hs

theorem prove_t1c : WeylMagic.Spec.stmt_t1c :=
  fun n hn3 hodd s => WeylMagic.no_odd_pauli_mub_all_n n hn3 hodd s

theorem prove_t1d : WeylMagic.Spec.stmt_t1d :=
  WeylMagic.sharpness_n1_n2_witnesses

theorem prove_t2a : WeylMagic.Spec.stmt_t2a :=
  fun n H c hsupp hres => WeylMagic.symplectic_lagrangian_rigidity n H c hsupp hres

theorem prove_t2b : WeylMagic.Spec.stmt_t2b :=
  fun m R I heq => WeylMagic.fermat_gaussian_pow2_locking m R I heq

theorem prove_t2c : WeylMagic.Spec.stmt_t2c :=
  fun m hm f hbent M hdeg => WeylMagic.rothaus_degree_bound_all_m m hm f hbent M hdeg

theorem prove_t2d : WeylMagic.Spec.stmt_t2d :=
  WeylMagic.n4_quad_bent_count_and_triple

theorem prove_t2e : WeylMagic.Spec.stmt_t2e :=
  fun qMask lin c0 hq hbent h hall =>
    WeylMagic.n4_z4_bent_hyperplane_rupture qMask lin c0 hq hbent h hall

theorem prove_t3a : WeylMagic.Spec.stmt_t3a :=
  WeylMagic.w42_z8_mub_fiducial_exact

theorem prove_t3b : WeylMagic.Spec.stmt_t3b :=
  WeylMagic.w44_z8_mub_fiducial_exact

theorem prove_t3c : WeylMagic.Spec.stmt_t3c :=
  WeylMagic.w42_super_mub_alpha_transition

theorem prove_t3d : WeylMagic.Spec.stmt_t3d :=
  WeylMagic.w44_super_mub_alpha_transition

theorem prove_t3e : WeylMagic.Spec.stmt_t3e :=
  WeylMagic.order16_magic_phase_hierarchy

theorem prove_t4a : WeylMagic.Spec.stmt_t4a :=
  ⟨WeylMagic.two_stab_parseval_universal,
   WeylMagic.two_stab_unifies_n1_n2_n3.1,
   WeylMagic.two_stab_unifies_n1_n2_n3.2.1,
   WeylMagic.two_stab_unifies_n1_n2_n3.2.2⟩

theorem prove_t4b : WeylMagic.Spec.stmt_t4b :=
  ⟨WeylMagic.n4_two_stab_cubic_exact.1,
   WeylMagic.n4_two_stab_cubic_exact.2.1,
   WeylMagic.n4_two_stab_cubic_exact.2.2.1,
   WeylMagic.n4_two_stab_cubic_exact.2.2.2.1,
   WeylMagic.n4_two_stab_cubic_exact.2.2.2.2,
   fun p q hq hp4 => WeylMagic.n4_cubic_strictly_monotone_on_interval p q hq hp4⟩

theorem prove_t4c : WeylMagic.Spec.stmt_t4c :=
  ⟨WeylMagic.n5_two_stab_sos_floor,
   WeylMagic.n5_rupture_witness_beats_tower.1,
   WeylMagic.n5_rupture_witness_beats_tower.2.1,
   WeylMagic.n5_rupture_witness_beats_tower.2.2⟩

theorem prove_t4d : WeylMagic.Spec.stmt_t4d :=
  ⟨WeylMagic.k_uniform_magic_ceiling,
   WeylMagic.ame_magic_ceiling_corollaries.1,
   WeylMagic.ame_magic_ceiling_corollaries.2.1,
   WeylMagic.ame_magic_ceiling_corollaries.2.2⟩

theorem prove_t5a : WeylMagic.Spec.stmt_t5a :=
  ⟨WeylMagic.f3_carry_quadratic_identity, WeylMagic.divided_power_cross_terms_exact⟩

theorem prove_t5b : WeylMagic.Spec.stmt_t5b :=
  fun D hD χ shift hreindex hdiag hoff =>
    WeylMagic.universal_gauss_sum_flat_modulus D hD χ shift hreindex hdiag hoff

theorem prove_t5c : WeylMagic.Spec.stmt_t5c :=
  ⟨WeylMagic.char3_alltop_n1_n2_n3_exact.1,
   WeylMagic.char3_alltop_n1_n2_n3_exact.2.1,
   WeylMagic.char3_alltop_n1_n2_n3_exact.2.2,
   WeylMagic.char5_alltop_n1_n2_exact.1,
   WeylMagic.char5_alltop_n1_n2_exact.2⟩

theorem prove_t5d : WeylMagic.Spec.stmt_t5d :=
  fun D s c σ q hs htrig => WeylMagic.two_stab_qgt_metric_exact D s c σ q hs htrig

theorem prove_all_weyl_magic_theorems : WeylMagic.Spec.stmt_all_weyl_magic_theorems :=
  ⟨prove_t1a, prove_t1b, prove_t1c, prove_t1d,
   prove_t2a, prove_t2b, prove_t2c, prove_t2d, prove_t2e,
   prove_t3a, prove_t3b, prove_t3c, prove_t3d, prove_t3e,
   prove_t4a, prove_t4b, prove_t4c, prove_t4d,
   prove_t5a, prove_t5b, prove_t5c, prove_t5d⟩

end

end WeylMagic.Solution
