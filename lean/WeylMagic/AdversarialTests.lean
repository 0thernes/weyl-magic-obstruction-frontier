module
-- SPDX-License-Identifier: Apache-2.0
-- Copyright (c) 2026 Alexander Stephen Donahue

public import WeylMagic.Basic
public import WeylMagic.TwoAdicObstruction
public import WeylMagic.BentHyperplaneRupture
public import WeylMagic.SuperMubAnomalies
public import WeylMagic.TwoStabilizerTower
public import WeylMagic.Char3AlltopAndQGT

/-!
# Adversarial Boundary Refutations (`WeylMagic.AdversarialTests`)

Formally disproves eight deliberately false over-claims / boundary mutations across
all five pillars to prove the exact sharpness of every theorem hypothesis.
-/

namespace WeylMagic

@[expose] public section

/-- Adversarial 1 (Pillar 1 boundary): `2^n * (2^n - 2)^2 ≠ K^2` is FALSE at `n = 1`
    (where `K = 0` solves it) and FALSE at `n = 2` (where `K = 4` solves it!). -/
theorem refute_two_adic_obstruction_at_n1_and_n2 :
    (∃ K : Int, ((2 : Int) ^ 1) * (((2 : Int) ^ 1) - 2) * (((2 : Int) ^ 1) - 2) = K * K) ∧
    (∃ K : Int, ((2 : Int) ^ 2) * (((2 : Int) ^ 2) - 2) * (((2 : Int) ^ 2) - 2) = K * K) := by
  exact ⟨⟨0, by decide⟩, ⟨4, by decide⟩⟩

/-- Adversarial 2 (Pillar 2 Rothaus sharpness at `m = 1`): Rothaus's bound `deg ≤ m`
    is FALSE for `m = 1` (`n = 2`), because `f(x₀, x₁) = x₀ x₁` is bent on `𝔽₂²`
    with degree `2 > 1` (`anfSum 2 (x₀x₁) 3 = 1 ≡ 1 (mod 2)`). -/
theorem refute_rothaus_at_m1 :
    IsBent 1 (fun x => (x &&& 3) == 3) ∧
    (1 < popcount 2 3) ∧
    ((anfSum 2 (fun x => (x &&& 3) == 3) 3) % 2 = 1) := by
  refine ⟨?_, by decide, by decide⟩
  intro u hu
  have hu' : u = 0 ∨ u = 1 ∨ u = 2 ∨ u = 3 := by omega
  rcases hu' with rfl | rfl | rfl | rfl <;> decide

/-- Adversarial 3 (Pillar 2 Fermat locking): `R^2 + I^2 = 2^(2m+1)` (odd exponent!)
    admits NON-AXIS diagonal solutions `(±2^m, ±2^m)`, showing why even `n = 2m` is
    essential for `ℤ₄` locking (`ℤ₈` diagonal phases appear only for odd powers of 2). -/
theorem refute_fermat_axis_locking_for_odd_pow2 :
    ∃ R I : Int, R * R + I * I = (2 : Int) ^ 3 ∧ R ≠ 0 ∧ I ≠ 0 := by
  exact ⟨2, 2, by decide, by decide, by decide⟩

/-- Adversarial 4 (Pillar 3 `α`-dependence / crossover of fixed witness `v42`):
    It is FALSE that the fixed `α=2,3`-beating witness `v42SuperMub` beats the `W(4) ⊗ W(2)`
    WH-MUB fiducial for all `α ≥ 2` — at `α = 4`, `Φ₈(v42)` strictly exceeds `519/512`. -/
theorem refute_w42_super_mub_at_alpha4 :
    ¬ (512 * (w42MomentsG v42SuperMub).2.2 ≤ 519 * (1001 ^ 8)) := by
  exact Int.not_le.mpr w42_super_mub_alpha_transition.2.2.2.2.2.2

/-- Adversarial 5 (Pillar 3 `α`-dependence / crossover of fixed witness `v44`):
    It is FALSE that the fixed `α=2,3`-beating witness `v44SuperMub` beats the `W(4) ⊗ W(4)`
    WH-MUB fiducial at `α = 4`. -/
theorem refute_w44_super_mub_at_alpha4 :
    ¬ (4096 * (w44MomentsG v44SuperMub).2.2 ≤ 4111 * (1596 ^ 8)) := by
  exact Int.not_le.mpr w44_super_mub_alpha_transition.2.2.2.2.2.2

/-- Adversarial 6 (Pillar 4 two-stabilizer optimality fails at `n = 5`): It is FALSE that
    the two-stabilizer tower `|Ψ₅(θ)⟩` achieves `Φ₄ < 3` at ANY parameter `p/q`, whereas
    `n5RuptureVec` strictly breaks below `3`. -/
theorem refute_two_stab_optimal_at_n5 :
    (∀ p q : Int, ¬ (twoStabPhi4Num 16 p q < 3 * (1024 * (q * q * q * q)))) ∧
    (n5Phi4Num n5RuptureVec < 3 * (254 ^ 4)) := by
  refine ⟨fun p q hlt => ?_, n5_rupture_witness_beats_tower.2.2⟩
  have hge := n5_two_stab_sos_floor p q
  omega

/-- Adversarial 7 (Pillar 4 `n = 4` cubic root location): `t*` does NOT equal `1/2` or `1/3`,
    and the 4-qubit two-stabilizer state does NOT reach the WH-MUB value `31/16 = 1.9375`. -/
theorem refute_n4_tower_reaches_mub :
    n4StationaryCubic 1 2 ≠ 0 ∧
    n4StationaryCubic 1 3 ≠ 0 ∧
    (31 * (2 * (10000000 ^ 4)) < 16 * n4Phi4Scaled2 3774568 10000000) := by
  decide

/-- Adversarial 8 (Pillar 5 irreducibility necessity): Using the REDUCIBLE cubic
    `t³ - 2t - 1 = 0` (`t = 2` is a root in `𝔽₃`) in the divided-power formula FAILS to
    produce a `W(3)^⊗3` MUB fiducial (`cZero = 218 ≠ 26`). -/
theorem refute_reducible_char3_poly :
    let gBad : Array Nat :=
      #[0, 0, 0, 0, 3, 6, 0, 3, 6,
        1, 1, 7, 1, 4, 4, 4, 7, 7,
        2, 5, 2, 8, 5, 5, 2, 8, 8]
    w3SpectrumCounts 3 gBad ≠ (1, 26, 702, 0) := by
  decide

end

end WeylMagic
