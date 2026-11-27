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
# Constructive Non-Vacuity Witnesses (`WeylMagic.NonVacuity`)

Explicitly constructs concrete instances satisfying the hypothesis bundles of every
universal theorem across all five pillars, ruling out vacuous truth.
-/

namespace WeylMagic

@[expose] public section

/-- Pillar 1 non-vacuity: `n = 1` satisfies `IsScaledPauliMUBSpectrum 1`, and `n = 3, 5`
    satisfy the hypotheses of `odd_two_adic_square_impossible` and `no_odd_pauli_mub_all_n`. -/
theorem nonvacuity_pillar1_odd_obstruction :
    (∃ s, IsScaledPauliMUBSpectrum 1 s) ∧
    (3 ≤ 3 ∧ 3 % 2 = 1) ∧
    (3 ≤ 5 ∧ 5 % 2 = 1) := by
  exact ⟨⟨n1MubSign, sharpness_n1_n2_witnesses.1⟩, by decide, by decide⟩

/-- Exact signed Hermitian 2-qubit Pauli expectation `⟨v|i^(wt(a∧b)) X^a Z^b|v⟩ ∈ ℤ[i]`. -/
def n2PauliExpectG (v : Nat → GaussInt) (a b : Nat) : GaussInt :=
  let c0 := GaussInt.mul (GaussInt.conj (v 0)) (v (0 ^^^ a))
  let s0 := if dotMod2 2 b 0 then GaussInt.neg c0 else c0
  let c1 := GaussInt.mul (GaussInt.conj (v 1)) (v (1 ^^^ a))
  let s1 := if dotMod2 2 b 1 then GaussInt.neg c1 else c1
  let c2 := GaussInt.mul (GaussInt.conj (v 2)) (v (2 ^^^ a))
  let s2 := if dotMod2 2 b 2 then GaussInt.neg c2 else c2
  let c3 := GaussInt.mul (GaussInt.conj (v 3)) (v (3 ^^^ a))
  let s3 := if dotMod2 2 b 3 then GaussInt.neg c3 else c3
  let raw := GaussInt.add (GaussInt.add s0 s1) (GaussInt.add s2 s3)
  GaussInt.mulPowI raw (popcount 2 (a &&& b))

/-- Exact scaled 2-qubit WH-MUB sign table `s(a,b) = 2 ⟨ψ|P(a,b)|ψ⟩ ∈ {0, 1, -1}`
    for non-identity Paulis `(a,b) ≠ (0,0)` (and `0` at `(0,0)` which `pauliIdempRHS` skips),
    derived directly from the `ℤ[i]⁴` fiducial `n2MubVec = (1, 1, 1, i)`. -/
def n2MubSign (a b : Nat) : Int :=
  if a == 0 && b == 0 then 0 else (n2PauliExpectG n2MubVec a b).re / 2

/-- Nontrivial `n = 2` non-vacuity of `IsScaledPauliMUBSpectrum`: unlike `n = 1` (where
    `2^1 - 2 = 0`), at `n = 2` we have `2^2 * (2^2 - 2)^2 = 16 ≠ 0`, and `n2MubSign`
    satisfies the full squared Pauli idempotence law with `pauliIdempRHS = ±4` on all
    12 non-vanishing Paulis — validating `pauliPhaseExp4` and `pauliCommSign` end-to-end. -/
theorem nonvacuity_pillar1_n2_mub_spectrum :
    (n2PauliExpectG n2MubVec 0 0 = ⟨4, 0⟩) ∧
    (∀ a b, a < 4 → b < 4 → (a ≠ 0 ∨ b ≠ 0) →
      (n2PauliExpectG n2MubVec a b).im = 0 ∧
      (n2PauliExpectG n2MubVec a b).re = 2 * n2MubSign a b) ∧
    IsScaledPauliMUBSpectrum 2 n2MubSign ∧
    (pauliIdempRHS 2 n2MubSign 1 0 = 4) := by
  refine ⟨by decide, ?_, ?_, by decide⟩
  · intro a b ha hb hne
    have ha' : a = 0 ∨ a = 1 ∨ a = 2 ∨ a = 3 := by omega
    have hb' : b = 0 ∨ b = 1 ∨ b = 2 ∨ b = 3 := by omega
    rcases ha' with rfl | rfl | rfl | rfl <;> rcases hb' with rfl | rfl | rfl | rfl
    · exfalso; omega
    all_goals decide
  · refine ⟨?_, ⟨1, 0, by decide, by decide, by decide, by decide⟩, ?_⟩
    · intro pa pb hpa hpb
      have ha' : pa = 0 ∨ pa = 1 ∨ pa = 2 ∨ pa = 3 := by omega
      have hb' : pb = 0 ∨ pb = 1 ∨ pb = 2 ∨ pb = 3 := by omega
      rcases ha' with rfl | rfl | rfl | rfl <;> rcases hb' with rfl | rfl | rfl | rfl <;> decide
    · intro ra rb hra hrb hne
      have ha' : ra = 0 ∨ ra = 1 ∨ ra = 2 ∨ ra = 3 := by omega
      have hb' : rb = 0 ∨ rb = 1 ∨ rb = 2 ∨ rb = 3 := by omega
      rcases ha' with rfl | rfl | rfl | rfl <;> rcases hb' with rfl | rfl | rfl | rfl
      · exfalso; omega
      all_goals decide

/-- Explicit computational `Z`-subgroup on `n = 2` qubits (`inH a b = (a == 0)`),
    satisfying `PauliSubgroup 2`, isotropy, and resolution of identity. -/
def zSubgroup2 : PauliSubgroup 2 where
  inH a _ := a == 0
  hasZero := rfl
  closedXor a1 _ a2 _ _ _ _ _ h1 h2 := by
    rw [beq_iff_eq] at h1 h2 ⊢
    subst h1; subst h2; rfl

/-- Pillar 2 non-vacuity:
    1. `zSubgroup2` is a concrete `PauliSubgroup 2` of size 4.
    2. `(R, I) = (4, 0)` satisfies `R^2 + I^2 = 2^(2*2)`.
    3. `quad4Eval 33` (`x₀x₁ ⊕ x₂x₃`) satisfies `IsBent 2` and `popcount 4 7 = 3 > 2`,
       confirming Rothaus's hypothesis bundle is inhabited! -/
theorem nonvacuity_pillar2_symplectic_and_bent :
    subgroupCard 2 zSubgroup2 = 4 ∧
    (4 * 4 + 0 * 0 = ((2 : Int) ^ 2) * ((2 : Int) ^ 2)) ∧
    IsBent 2 (quad4Eval 33) ∧
    (2 < popcount 4 7) := by
  refine ⟨by decide, by decide, ?_, by decide⟩
  intro u hu
  have hcheck : isBent4Bool (quad4Eval 33) = true := by decide
  have hmem : u ∈ List.range 16 := List.mem_range.mpr hu
  have hu' := (List.all_eq_true.mp hcheck) u hmem
  simp only [Bool.or_eq_true, beq_iff_eq] at hu'
  exact hu'

/-- Pillar 3 non-vacuity: both `W(4) ⊗ W(2)` and `W(4) ⊗ W(4)` simultaneously possess
    exact `ℤ[ζ₈]` WH-MUB fiducials AND exact `ℤ[i]` Super-MUB witnesses. -/
theorem nonvacuity_pillar3_dual_witnesses :
    (w42Z8SpectrumCounts psi42Z8 64 8 = (1, 7, 56, 0)) ∧
    (w44Z8SpectrumCounts psi44Z8 102400 6400 = (1, 15, 240, 0)) ∧
    (8 * (w42MomentsG v42SuperMub).1 < 15 * (1001 ^ 4)) ∧
    (16 * (w44MomentsG v44SuperMub).1 < 31 * (1596 ^ 4)) := by
  exact ⟨w42_z8_mub_fiducial_exact.2.2,
         w44_z8_mub_fiducial_exact.2.2,
         w42_super_mub_alpha_transition.2.2.2.2.1,
         w44_super_mub_alpha_transition.2.2.2.2.1⟩

/-- Pillar 4 non-vacuity: the `k`-uniform Parseval hypothesis is inhabited by an explicit
    uniform weight vector (`N = 9, S = 3, D - 1 = 3, w = const 1`), and `n4` convexity
    hypothesis is inhabited by `(p, q) = (3774568, 10000000)`. -/
theorem nonvacuity_pillar4_tower_and_ame :
    sumRange 9 (fun _ => (1 : Int)) = 3 * 3 ∧
    (0 < (10000000 : Int) ∧ 10 * (3774568 : Int) ≤ 4 * 10000000) ∧
    (n5NormSq n5RuptureVec = 254) := by
  exact ⟨by decide, by decide, n5_rupture_witness_beats_tower.1⟩

/-- Pillar 5 non-vacuity:
    1. The `universal_gauss_sum_flat_modulus` hypotheses are concretely inhabited at `D = 3`
       by `χ(x) = ζ₉^(3 x²)` (quadratic Gauss sum over `𝔽₃`) with `shift h y = (y + h) % 3`!
    2. The QGT algebraic identity hypotheses `D * s² = q²` and `c² + σ² = q²` are concretely
       inhabited by `(D, s, c, σ, q) = (4, 5, 6, 8, 10)`! -/
theorem nonvacuity_pillar5_gauss_and_qgt :
    (Zeta9.normSq (sumZ9 3 (fun x => Zeta9.pow (3 * x * x))) = Zeta9.ofInt 3) ∧
    ((4 : Int) * (5 * 5) = 10 * 10 ∧ (6 : Int) * 6 + 8 * 8 = 10 * 10) := by
  refine ⟨?_, by decide⟩
  apply universal_gauss_sum_flat_modulus 3 (by decide)
    (fun x => Zeta9.pow (3 * x * x))
    (fun h y => (y + h) % 3)
  · intro y hy
    have hy' : y = 0 ∨ y = 1 ∨ y = 2 := by omega
    rcases hy' with rfl | rfl | rfl <;> decide
  · decide
  · intro h hh hlt
    have hh' : h = 1 ∨ h = 2 := by omega
    rcases hh' with rfl | rfl <;> decide

end

end WeylMagic
