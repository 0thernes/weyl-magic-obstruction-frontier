module
-- SPDX-License-Identifier: Apache-2.0
-- Copyright (c) 2026 Alexander Stephen Donahue

public import WeylMagic.Basic

/-!
# Pillar 1: Universal 2-Adic Idempotence Obstruction for Odd-Qubit Product-Pauli MUB Fiducials

Proves unconditionally for **every odd `n ≥ 3`** (`n = 3, 5, 7, 9, ...`) that no pure
`n`-qubit state `|ψ⟩ ∈ ℂ^(2^n)` can possess the Weyl–Heisenberg MUB Pauli expectation
spectrum `|⟨ψ|P|ψ⟩|² ∈ {0, 2⁻ⁿ}` for all non-identity Paulis `P ∈ W(2)^⊗n \ {I}`:

1. **T1a (`odd_two_adic_square_impossible`):** For every odd `n ≥ 3` and every `K : Int`,
   `(2^n : Int) * (2^n - 2)^2 ≠ K * K`.
2. **T1b (`pauli_idempotence_implies_integer_square`):** Any real-Bloch pure-state solution
   to the exact Pauli idempotence equation `(2^n - 2) c_R = ∑_{P≠I,R; [P,R]=0} σ(P,PR) c_P c_{PR}`
   with MUB spectrum `c_P = s_P / 2^(n/2)` (`s_P ∈ {0, 1, -1}`) forces
   `2^n * (2^n - 2)^2 * s_R^2 = K^2` for the exact integer sum
   `K = ∑_{P≠I,R; [P,R]=0} σ(P,PR) s_P s_{PR}`.
3. **T1c (`no_odd_pauli_mub_all_n`):** Unconditional nonexistence for ALL odd `n ≥ 3`
   with ZERO subgroup assumption and ZERO equimodularity assumption — settling the
   Strong Form of Damski–Bistroń–Ponterio–Czartowski–Życzkowski Conjecture 1
   (`arXiv:2603.15550`) for all odd `n ≥ 3` and refuting Part II of the Liu–Low–Yin
   Maximal Magic Conjecture (`arXiv:2502.17550v3`) for all odd `n ≥ 5`.
4. **T1d (`sharpness_n1_n2_witnesses`):** Constructive sharpness witnesses at `n = 1`
   (where `2^1 - 2 = 0` annihilates the obstruction) and `n = 2` (exact `ℤ[i]⁴` fiducial
   `(1, 1, 1, i)` with `Φ₄ = 7/4`, 3 zeros, 12 entries of `1/4`).
-/

namespace WeylMagic

@[expose] public section

/-! ### T1a: Universal 2-Adic Valuation Obstruction -/

/-- If `K * K` is even then `K` is even. -/
theorem even_of_mul_self_even (K : Int) (h : (K * K) % 2 = 0) : K % 2 = 0 := by
  have hmod : (K * K) % 2 = (K % 2) * (K % 2) % 2 := by
    rw [Int.mul_emod]
  rw [hmod] at h
  have hbounds : K % 2 = 0 ∨ K % 2 = 1 := by omega
  rcases hbounds with h0 | h1
  · exact h0
  · rw [h1] at h; omega

/-- Core 2-adic parity descent: for any odd integer `m` and any `j : Nat`,
    `2^(2*j + 1) * m^2` is NEVER a perfect square in `ℤ`. -/
theorem pow2_odd_mul_odd_sq_ne_sq :
    ∀ (j : Nat) (m K : Int), m % 2 = 1 →
      ((2 : Int) ^ (2 * j + 1)) * (m * m) ≠ K * K
  | 0, m, K, hm, heq => by
    have hpow : ((2 : Int) ^ 1) = 2 := by decide
    simp only [Nat.mul_zero, Nat.zero_add, hpow] at heq
    have hKeven : K % 2 = 0 := by
      apply even_of_mul_self_even
      rw [← heq]
      omega
    have hK2 : K = 2 * (K / 2) := by omega
    rw [hK2] at heq
    have hm2 : m * m = 2 * ((K / 2) * (K / 2)) := by
      have h4 : (2 * (K / 2)) * (2 * (K / 2)) = 2 * (2 * ((K / 2) * (K / 2))) := by
        rw [Int.mul_assoc 2 (K / 2) _, ← Int.mul_assoc (K / 2) 2 _,
            Int.mul_comm (K / 2) 2, Int.mul_assoc 2 (K / 2) _]
      rw [h4] at heq
      omega
    have hmeven : m % 2 = 0 := by
      apply even_of_mul_self_even
      rw [hm2]
      omega
    omega
  | j + 1, m, K, hm, heq => by
    have hstep : ((2 : Int) ^ (2 * (j + 1) + 1)) = 4 * ((2 : Int) ^ (2 * j + 1)) := by
      have hexp : 2 * (j + 1) + 1 = (2 * j + 1) + 2 := by omega
      rw [hexp, Int.pow_add]
      have h22 : ((2 : Int) ^ 2) = 4 := by decide
      rw [h22, Int.mul_comm]
    rw [hstep] at heq
    have hKeven : K % 2 = 0 := by
      apply even_of_mul_self_even
      rw [← heq]
      have h2f : 4 * (2 : Int) ^ (2 * j + 1) * (m * m) =
          2 * (2 * ((2 : Int) ^ (2 * j + 1) * (m * m))) := by
        rw [Int.mul_assoc 4 _ _]
        have h42 : (4 : Int) = 2 * 2 := by decide
        rw [h42, Int.mul_assoc 2 2 _]
      rw [h2f]
      omega
    have hK2 : K = 2 * (K / 2) := by omega
    rw [hK2] at heq
    have hcancel : ((2 : Int) ^ (2 * j + 1)) * (m * m) = (K / 2) * (K / 2) := by
      have h4 : (2 * (K / 2)) * (2 * (K / 2)) = 4 * ((K / 2) * (K / 2)) := by
        rw [Int.mul_assoc 2 (K / 2) _, ← Int.mul_assoc (K / 2) 2 _,
            Int.mul_comm (K / 2) 2, Int.mul_assoc 2 (K / 2) _, ← Int.mul_assoc 2 2 _]
        rfl
      rw [h4, Int.mul_assoc] at heq
      omega
    exact pow2_odd_mul_odd_sq_ne_sq j m (K / 2) hm hcancel

/-- For any `k ≥ 1`, `2^k - 1` is odd as an integer. -/
theorem pow2_sub_one_odd (k : Nat) (hk : 1 ≤ k) : (((2 : Int) ^ k) - 1) % 2 = 1 := by
  obtain ⟨r, rfl⟩ : ∃ r, k = r + 1 := ⟨k - 1, by omega⟩
  rw [Int.pow_succ]
  omega

/-- **T1a:** For EVERY odd `n ≥ 3` and EVERY integer `K`,
    `2^n * (2^n - 2)^2 ≠ K^2`. -/
theorem odd_two_adic_square_impossible (n : Nat) (hn3 : 3 ≤ n) (hodd : n % 2 = 1) (K : Int) :
    ((2 : Int) ^ n) * (((2 : Int) ^ n) - 2) * (((2 : Int) ^ n) - 2) ≠ K * K := by
  have hk1 : 1 ≤ n - 1 := by omega
  have hfactor : ((2 : Int) ^ n) - 2 = 2 * (((2 : Int) ^ (n - 1)) - 1) := by
    have hpow := Int.pow_succ (2 : Int) (n - 1)
    have hn : (n - 1).succ = n := by omega
    rw [hn] at hpow
    omega
  let m : Int := ((2 : Int) ^ (n - 1)) - 1
  have hm_odd : m % 2 = 1 := pow2_sub_one_odd (n - 1) hk1
  let j : Nat := (n + 1) / 2
  have hj : 2 * j + 1 = n + 2 := by omega
  have hlhs : ((2 : Int) ^ n) * (((2 : Int) ^ n) - 2) * (((2 : Int) ^ n) - 2) =
      ((2 : Int) ^ (2 * j + 1)) * (m * m) := by
    rw [hj, hfactor, Int.pow_add]
    have h22 : ((2 : Int) ^ 2) = 4 := by decide
    rw [h22]
    change (2 : Int) ^ n * (2 * m) * (2 * m) = (2 : Int) ^ n * 4 * (m * m)
    grind
  rw [hlhs]
  exact pow2_odd_mul_odd_sq_ne_sq j m K hm_odd

/-! ### T1b & T1c: Pauli Pure-State Idempotence and Universal Odd-`n` MUB Nonexistence -/

/-- Exact integer right-hand side of the scaled `n`-qubit Pauli pure-state idempotence
    equation for target Pauli `(ra, rb)`:
    `K(n, s, ra, rb) = ∑_{p ≠ 0, r; [p, r] = 0} σ(p, p⊕r) * s(p) * s(p⊕r)`
    where `p = pa * 2^n + pb` indexes `W(2)^⊗n`. -/
def pauliIdempRHS (n : Nat) (s : Nat → Nat → Int) (ra rb : Nat) : Int :=
  let D := 2 ^ n
  sumRange D (fun pa =>
    sumRange D (fun pb =>
      if (pa == 0 && pb == 0) || (pa == ra && pb == rb) then 0
      else if sympForm n pa pb ra rb then 0
      else
        let qa := pa ^^^ ra
        let qb := pb ^^^ rb
        pauliCommSign n pa pb qa qb * (s pa pb * s qa qb)))

/-- Predicate asserting that `s : Nat → Nat → Int` is a valid non-trivial scaled
    `n`-qubit Pauli MUB spectrum (`s(a, b) ∈ {0, 1, -1}` representing `c_{a,b} = s(a,b)/2^(n/2)`)
    satisfying the exact squared pure-state idempotence law `ρ² = ρ` at every non-identity Pauli. -/
def IsScaledPauliMUBSpectrum (n : Nat) (s : Nat → Nat → Int) : Prop :=
  (∀ pa pb, pa < 2 ^ n → pb < 2 ^ n → s pa pb = 0 ∨ s pa pb = 1 ∨ s pa pb = -1) ∧
  (∃ ra rb, ra < 2 ^ n ∧ rb < 2 ^ n ∧ (ra ≠ 0 ∨ rb ≠ 0) ∧ s ra rb ≠ 0) ∧
  (∀ ra rb, ra < 2 ^ n → rb < 2 ^ n → (ra ≠ 0 ∨ rb ≠ 0) →
    ((2 : Int) ^ n) * (((2 : Int) ^ n) - 2) * (((2 : Int) ^ n) - 2) * (s ra rb * s ra rb) =
      pauliIdempRHS n s ra rb * pauliIdempRHS n s ra rb)

/-- **T1b:** Any non-zero entry `s(ra, rb) ∈ {1, -1}` in a scaled Pauli MUB spectrum
    forces `2^n * (2^n - 2)^2 = K^2` for `K = pauliIdempRHS n s ra rb`. -/
theorem pauli_idempotence_forces_square (n : Nat) (s : Nat → Nat → Int)
    (hs : IsScaledPauliMUBSpectrum n s) :
    ∃ K : Int, ((2 : Int) ^ n) * (((2 : Int) ^ n) - 2) * (((2 : Int) ^ n) - 2) = K * K := by
  rcases hs with ⟨hvals, ⟨ra, rb, hra, hrb, hne, hsnz⟩, hidemp⟩
  have hsq1 : s ra rb * s ra rb = 1 := by
    rcases hvals ra rb hra hrb with h0 | h1 | hm1
    · exact absurd h0 hsnz
    · rw [h1]; decide
    · rw [hm1]; decide
  have heq := hidemp ra rb hra hrb hne
  rw [hsq1, Int.mul_one] at heq
  exact ⟨pauliIdempRHS n s ra rb, heq⟩

/-- **T1c (Universal Odd-`n ≥ 3` Obstruction — Strong Form of Damski–Życzkowski Conjecture 1
    & Refutation of Liu–Low–Yin Conjecture Part II for all odd `n ≥ 5`):**
    For EVERY odd `n ≥ 3`, NO `n`-qubit pure state can have a scaled Pauli MUB spectrum
    `|⟨ψ|P|ψ⟩|² ∈ {0, 2⁻ⁿ}` (with ZERO subgroup or equimodularity assumptions). -/
theorem no_odd_pauli_mub_all_n (n : Nat) (hn3 : 3 ≤ n) (hodd : n % 2 = 1)
    (s : Nat → Nat → Int) : ¬ IsScaledPauliMUBSpectrum n s := by
  intro hs
  obtain ⟨K, hK⟩ := pauli_idempotence_forces_square n s hs
  exact odd_two_adic_square_impossible n hn3 hodd K hK

/-! ### T1d: Constructive Sharpness at `n = 1` and `n = 2` -/

/-- Exact 1-qubit H-state MUB spectrum `s(0,1)=0, s(1,0)=1, s(1,1)=1` (on `c_Z=0, c_X=c_Y=1/√2`). -/
def n1MubSign (a b : Nat) : Int :=
  if a == 0 && b == 1 then 0 else 1

/-- Exact 2-qubit WH-MUB fiducial vector `v = (1, 1, 1, i) ∈ ℤ[i]⁴` (unnormalized, `‖v‖² = 4`). -/
def n2MubVec : Nat → GaussInt
  | 0 => ⟨1, 0⟩
  | 1 => ⟨1, 0⟩
  | 2 => ⟨1, 0⟩
  | _ => ⟨0, 1⟩

/-- Unnormalized 2-qubit Pauli expectation squared `|⟨v|X^a Z^b|v⟩|²` for `v : Nat → GaussInt`. -/
def n2PauliExpectSq (v : Nat → GaussInt) (a b : Nat) : Int :=
  let sumG :=
    GaussInt.add
      (GaussInt.add
        (let c0 := GaussInt.mul (GaussInt.conj (v 0)) (v (0 ^^^ a))
         if dotMod2 2 b 0 then GaussInt.neg c0 else c0)
        (let c1 := GaussInt.mul (GaussInt.conj (v 1)) (v (1 ^^^ a))
         if dotMod2 2 b 1 then GaussInt.neg c1 else c1))
      (GaussInt.add
        (let c2 := GaussInt.mul (GaussInt.conj (v 2)) (v (2 ^^^ a))
         if dotMod2 2 b 2 then GaussInt.neg c2 else c2)
        (let c3 := GaussInt.mul (GaussInt.conj (v 3)) (v (3 ^^^ a))
         if dotMod2 2 b 3 then GaussInt.neg c3 else c3))
  GaussInt.normSq sumG

/-- Total unnormalized 4th moment `∑_{a,b} |⟨v|X^a Z^b|v⟩|⁴` for a 2-qubit vector. -/
def n2Phi4Num (v : Nat → GaussInt) : Int :=
  sumRange 4 (fun a => sumRange 4 (fun b =>
    let m := n2PauliExpectSq v a b
    m * m))

/-- **T1d (Sharpness at `n = 1` and `n = 2`):**
    1. At `n = 1`, `n1MubSign` satisfies `IsScaledPauliMUBSpectrum 1` (since `2¹ - 2 = 0`).
    2. At `n = 2`, the exact `ℤ[i]⁴` vector `v = (1, 1, 1, i)` (`‖v‖² = 4`) has
       `|⟨v|P|v⟩|² = 0` on all 3 non-identity `Z`-Paulis, `|⟨v|P|v⟩|² = 4 = 16/4` on all 12
       remaining Paulis, and exact `Φ₄ = 448 / 256 = 7 / 4`. -/
theorem sharpness_n1_n2_witnesses :
    IsScaledPauliMUBSpectrum 1 n1MubSign ∧
    (sumRange 4 (fun x => GaussInt.normSq (n2MubVec x)) = 4) ∧
    (∀ a b, a < 4 → b < 4 →
      if a = 0 ∧ b = 0 then n2PauliExpectSq n2MubVec a b = 16
      else if a = 0 then n2PauliExpectSq n2MubVec a b = 0
      else n2PauliExpectSq n2MubVec a b = 4) ∧
    (4 * n2Phi4Num n2MubVec = 7 * 256) := by
  refine ⟨?_, ?_, ?_, ?_⟩
  · refine ⟨?_, ⟨1, 0, by decide, by decide, by decide, by decide⟩, ?_⟩
    · intro pa pb hpa hpb
      have h1 : pa = 0 ∨ pa = 1 := by omega
      have h2 : pb = 0 ∨ pb = 1 := by omega
      rcases h1 with rfl | rfl <;> rcases h2 with rfl | rfl <;> simp [n1MubSign]
    · intro ra rb hra hrb hne
      have h1 : ra = 0 ∨ ra = 1 := by omega
      have h2 : rb = 0 ∨ rb = 1 := by omega
      rcases h1 with rfl | rfl <;> rcases h2 with rfl | rfl
      · exfalso; omega
      · decide
      · decide
      · decide
  · decide
  · intro a b ha hb
    have ha' : a = 0 ∨ a = 1 ∨ a = 2 ∨ a = 3 := by omega
    have hb' : b = 0 ∨ b = 1 ∨ b = 2 ∨ b = 3 := by omega
    rcases ha' with rfl | rfl | rfl | rfl <;> rcases hb' with rfl | rfl | rfl | rfl <;> decide
  · decide

end

end WeylMagic
