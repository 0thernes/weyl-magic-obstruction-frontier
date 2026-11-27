module
-- SPDX-License-Identifier: Apache-2.0
-- Copyright (c) 2026 Alexander Stephen Donahue

public import WeylMagic.Basic

/-!
# Pillar 2: Symplectic Rigidity, Fermat `ℤ₄`-Locking, Rothaus Degree Bound, and the `n = 4` Bent-Hyperplane Rupture

Establishes the complete even-`n` algebraic obstruction chain for `W(2)^⊗n`-covariant MUB
fiducials in zero-Mathlib Lean 4.35.0:

1. **T2a (`symplectic_lagrangian_rigidity`):** For EVERY `n`, any Pauli subgroup `H ≤ 𝔽₂^(2n)`
   (closed under XOR, containing `0`) satisfying the MUB basis resolution of identity
   `(∑_{h ∈ H} (-1)^{ω(h, r)}) * c_r = 0` with `c_r ≠ 0` for all `r ∉ H` satisfies `H^⊥ ⊆ H`.
   If `H` is isotropic (`H ⊆ H^⊥`), then `H = H^⊥` is maximal Lagrangian.
2. **T2b (`fermat_gaussian_pow2_locking`):** For EVERY `m : Nat` and ALL `R I : Int`,
   `R^2 + I^2 = 4^m → (R = ±2^m ∧ I = 0) ∨ (R = 0 ∧ I = ±2^m)`.
   Consequently, for every even `n = 2m`, every inverse Walsh amplitude `2^m conj(u_x) u_{x⊕a} ∈ ℤ[i]`
   of norm `2^m` locks to `{±1, ±i}`, eliminating `ℤ₈` and all higher roots of unity unconditionally.
3. **T2c (`poisson_anf_identity` & `rothaus_degree_bound_all_m`):** Exact Poisson summation on
   `𝔽₂^n` and Rothaus's 1976 Degree Bound proved universally for EVERY `m ≥ 2`: every Boolean bent
   function `f : 𝔽₂^(2m) → Bool` has ANF coefficient `0 (mod 2)` on every monomial `M` of Hamming
   weight `popcount(2m, M) > m`.
4. **T2d (`n4_quad_bent_count_and_triple`):** At `n = 4` (`m = 2`), exactly 28 of the 64
   homogeneous quadratic forms on `𝔽₂⁴` are bent (`28 × 32 = 896` bent functions), and every one
   admits a symplectic triple `(a, b, a ⊕ b)` with `1_{E_a} ⊕ 1_{E_b} ⊕ 1_{E_{a⊕b}} ≡ 0 (mod 2)`.
5. **T2e (`n4_z4_bent_hyperplane_rupture`):** For EVERY bent quadratic form `qMask < 64`, EVERY
   affine shift `(lin, c0)`, and EVERY second-bit lift `h : Nat → Bool`, the odd-parity law
   `∑_{x ∈ E_a} h(x) ≡ 1 (mod 2)` contradicts the 3-hyperplane zero-sum identity (`1+1+1 ≡ 0 (mod 2)`).
   Hence NO `ℤ₄`-phase state (and by T2a–T2b, NO Lagrangian/equimodular 4-qubit state over `ℂ¹⁶`)
   is a `W(2)^⊗4` MUB fiducial.
-/

namespace WeylMagic

@[expose] public section

/-! ### Clean `testBit`-Based Bitwise Lemmas on `Nat` -/

private theorem and_one_eq_mod2 (x : Nat) : x &&& 1 = x % 2 := by
  exact Nat.and_one_is_mod x

private theorem nat_xor_and_right (a b c : Nat) : (a ^^^ b) &&& c = (a &&& c) ^^^ (b &&& c) := by
  apply Nat.eq_of_testBit_eq; intro i
  simp [Nat.testBit_and, Nat.testBit_xor]
  cases a.testBit i <;> cases b.testBit i <;> cases c.testBit i <;> rfl

private theorem nat_shiftRight_xor (a b : Nat) : (a ^^^ b) >>> 1 = (a >>> 1) ^^^ (b >>> 1) := by
  apply Nat.eq_of_testBit_eq; intro i
  simp [Nat.testBit_shiftRight, Nat.testBit_xor]

private theorem testBit_two_mul_succ (x k : Nat) : (2 * x).testBit (k + 1) = x.testBit k := by
  rw [Nat.testBit_succ]; have : (2 * x) / 2 = x := by omega
  rw [this]

private theorem testBit_two_mul_add1_succ (x k : Nat) :
    (2 * x + 1).testBit (k + 1) = x.testBit k := by
  rw [Nat.testBit_succ]; have : (2 * x + 1) / 2 = x := by omega
  rw [this]

private theorem xor_two_mul_even (x a : Nat) : (2 * x) ^^^ (2 * a) = 2 * (x ^^^ a) := by
  apply Nat.eq_of_testBit_eq; intro i
  rw [Nat.testBit_xor]
  cases i with
  | zero => simp [Nat.testBit_zero]
  | succ k => rw [testBit_two_mul_succ, testBit_two_mul_succ, testBit_two_mul_succ, Nat.testBit_xor]

private theorem xor_two_mul_odd_even (x a : Nat) : (2 * x + 1) ^^^ (2 * a) = 2 * (x ^^^ a) + 1 := by
  apply Nat.eq_of_testBit_eq; intro i
  rw [Nat.testBit_xor]
  cases i with
  | zero => simp [Nat.testBit_zero]
  | succ k =>
    rw [testBit_two_mul_add1_succ, testBit_two_mul_succ, testBit_two_mul_add1_succ, Nat.testBit_xor]

private theorem xor_two_mul_even_odd (x a : Nat) : (2 * x) ^^^ (2 * a + 1) = 2 * (x ^^^ a) + 1 := by
  rw [Nat.xor_comm, xor_two_mul_odd_even, Nat.xor_comm]

private theorem xor_two_mul_odd_odd (x a : Nat) : (2 * x + 1) ^^^ (2 * a + 1) = 2 * (x ^^^ a) := by
  apply Nat.eq_of_testBit_eq; intro i
  rw [Nat.testBit_xor]
  cases i with
  | zero => simp [Nat.testBit_zero]
  | succ k =>
    rw [testBit_two_mul_add1_succ, testBit_two_mul_add1_succ, testBit_two_mul_succ, Nat.testBit_xor]

private theorem and_two_mul_even (x M : Nat) : (2 * x) &&& (2 * M) = 2 * (x &&& M) := by
  apply Nat.eq_of_testBit_eq; intro i
  rw [Nat.testBit_and]
  cases i with
  | zero => simp [Nat.testBit_zero]
  | succ k => rw [testBit_two_mul_succ, testBit_two_mul_succ, testBit_two_mul_succ, Nat.testBit_and]

private theorem and_two_mul_even_odd (x M : Nat) : (2 * x) &&& (2 * M + 1) = 2 * (x &&& M) := by
  apply Nat.eq_of_testBit_eq; intro i
  rw [Nat.testBit_and]
  cases i with
  | zero => simp [Nat.testBit_zero]
  | succ k =>
    rw [testBit_two_mul_succ, testBit_two_mul_add1_succ, testBit_two_mul_succ, Nat.testBit_and]

private theorem and_two_mul_odd_even (x M : Nat) : (2 * x + 1) &&& (2 * M) = 2 * (x &&& M) := by
  rw [Nat.and_comm, and_two_mul_even_odd, Nat.and_comm]

private theorem and_two_mul_odd_odd (x M : Nat) :
    (2 * x + 1) &&& (2 * M + 1) = 2 * (x &&& M) + 1 := by
  apply Nat.eq_of_testBit_eq; intro i
  rw [Nat.testBit_and]
  cases i with
  | zero => simp [Nat.testBit_zero]
  | succ k =>
    rw [testBit_two_mul_add1_succ, testBit_two_mul_add1_succ, testBit_two_mul_add1_succ, Nat.testBit_and]

theorem dotMod2_xor_left : ∀ (n a b c : Nat),
    dotMod2 n (a ^^^ b) c = xor (dotMod2 n a c) (dotMod2 n b c)
  | 0, _, _, _ => rfl
  | k + 1, a, b, c => by
    simp only [dotMod2]
    have hlow : ((((a ^^^ b) &&& c) &&& 1) == 1) =
        xor (((a &&& c) &&& 1) == 1) (((b &&& c) &&& 1) == 1) := by
      rw [nat_xor_and_right a b c, nat_xor_and_right (a &&& c) (b &&& c) 1]
      have hx : (a &&& c) &&& 1 = 0 ∨ (a &&& c) &&& 1 = 1 := by rw [and_one_eq_mod2]; omega
      have hy : (b &&& c) &&& 1 = 0 ∨ (b &&& c) &&& 1 = 1 := by rw [and_one_eq_mod2]; omega
      rcases hx with h1 | h1 <;> rcases hy with h2 | h2 <;> rw [h1, h2] <;> decide
    rw [hlow, nat_shiftRight_xor a b, dotMod2_xor_left k (a >>> 1) (b >>> 1) (c >>> 1)]
    cases (((a &&& c) &&& 1) == 1) <;> cases (((b &&& c) &&& 1) == 1) <;>
      cases dotMod2 k (a >>> 1) (c >>> 1) <;> cases dotMod2 k (b >>> 1) (c >>> 1) <;> rfl

theorem dotMod2_comm : ∀ (n a b : Nat), dotMod2 n a b = dotMod2 n b a
  | 0, _, _ => rfl
  | k + 1, a, b => by
    simp only [dotMod2, Nat.and_comm a b, dotMod2_comm k (a >>> 1) (b >>> 1)]

theorem dotMod2_xor_right (n a b c : Nat) :
    dotMod2 n a (b ^^^ c) = xor (dotMod2 n a b) (dotMod2 n a c) := by
  rw [dotMod2_comm, dotMod2_xor_left, dotMod2_comm n b a, dotMod2_comm n c a]

theorem paritySign_xor (b1 b2 : Bool) :
    paritySign (xor b1 b2) = paritySign b1 * paritySign b2 := by
  cases b1 <;> cases b2 <;> decide

theorem sympForm_xor_left (n a1 b1 a2 b2 ra rb : Nat) :
    sympForm n (a1 ^^^ a2) (b1 ^^^ b2) ra rb =
      xor (sympForm n a1 b1 ra rb) (sympForm n a2 b2 ra rb) := by
  simp only [sympForm, dotMod2_xor_left]
  cases dotMod2 n a1 rb <;> cases dotMod2 n a2 rb <;>
    cases dotMod2 n b1 ra <;> cases dotMod2 n b2 ra <;> rfl

/-! ### Sum Over `𝔽₂^n` and XOR-Shift Invariance -/

/-- Exact integer sum of `f` over all `x < 2^n` via recursive bit splitting. -/
def sumBits : Nat → (Nat → Int) → Int
  | 0, f => f 0
  | n + 1, f => sumBits n (fun x => f (2 * x)) + sumBits n (fun x => f (2 * x + 1))

theorem sumBits_add : ∀ (n : Nat) (f g : Nat → Int),
    sumBits n (fun x => f x + g x) = sumBits n f + sumBits n g
  | 0, _, _ => rfl
  | k + 1, f, g => by simp only [sumBits, sumBits_add k]; omega

theorem sumBits_sub : ∀ (n : Nat) (f g : Nat → Int),
    sumBits n (fun x => f x - g x) = sumBits n f - sumBits n g
  | 0, _, _ => rfl
  | k + 1, f, g => by simp only [sumBits, sumBits_sub k]; omega

theorem sumBits_neg : ∀ (n : Nat) (f : Nat → Int),
    sumBits n (fun x => -f x) = -sumBits n f
  | 0, _ => rfl
  | k + 1, f => by simp only [sumBits, sumBits_neg k]; omega

theorem sumBits_mul_left : ∀ (n : Nat) (c : Int) (f : Nat → Int),
    sumBits n (fun x => c * f x) = c * sumBits n f
  | 0, _, _ => rfl
  | k + 1, c, f => by simp only [sumBits, sumBits_mul_left k, Int.mul_add]

theorem sumBits_const : ∀ (n : Nat) (c : Int),
    sumBits n (fun _ => c) = ((2 : Int) ^ n) * c
  | 0, c => by simp [sumBits]
  | k + 1, c => by
    simp only [sumBits, sumBits_const k, Int.pow_succ]
    grind

theorem sumBits_congr : ∀ (n : Nat) (f g : Nat → Int),
    (∀ x, x < 2 ^ n → f x = g x) → sumBits n f = sumBits n g
  | 0, f, g, h => h 0 (by decide)
  | k + 1, f, g, h => by
    simp only [sumBits]
    have h0 := sumBits_congr k (fun x => f (2 * x)) (fun x => g (2 * x))
      (fun x hx => h (2 * x) (by rw [Nat.pow_succ]; omega))
    have h1 := sumBits_congr k (fun x => f (2 * x + 1)) (fun x => g (2 * x + 1))
      (fun x hx => h (2 * x + 1) (by rw [Nat.pow_succ]; omega))
    rw [h0, h1]

theorem sumBits_nonneg : ∀ (n : Nat) (f : Nat → Int),
    (∀ x, x < 2 ^ n → 0 ≤ f x) → 0 ≤ sumBits n f
  | 0, f, h => h 0 (by decide)
  | k + 1, f, h => by
    simp only [sumBits]
    have h0 := sumBits_nonneg k (fun x => f (2 * x))
      (fun x hx => h (2 * x) (by rw [Nat.pow_succ]; omega))
    have h1 := sumBits_nonneg k (fun x => f (2 * x + 1))
      (fun x hx => h (2 * x + 1) (by rw [Nat.pow_succ]; omega))
    omega

theorem sumBits_swap : ∀ (n m : Nat) (f : Nat → Nat → Int),
    sumBits n (fun x => sumBits m (fun y => f x y)) =
      sumBits m (fun y => sumBits n (fun x => f x y))
  | 0, m, f => by simp [sumBits]
  | k + 1, m, f => by
    simp only [sumBits]
    rw [sumBits_swap k m (fun x y => f (2 * x) y),
        sumBits_swap k m (fun x y => f (2 * x + 1) y),
        ← sumBits_add]

/-- Exact XOR-shift invariance of `sumBits`: for ANY `a < 2^n`,
    `∑_{x < 2^n} f(x ⊕ a) = ∑_{x < 2^n} f(x)`. -/
theorem sumBits_xor_shift : ∀ (n : Nat) (a : Nat) (f : Nat → Int),
    a < 2 ^ n → sumBits n (fun x => f (x ^^^ a)) = sumBits n f
  | 0, a, f, ha => by
    have : a = 0 := by omega
    subst this; simp [sumBits]
  | k + 1, a, f, ha => by
    simp only [sumBits]
    have hsplit : (∃ q, a = 2 * q ∧ q < 2 ^ k) ∨ (∃ q, a = 2 * q + 1 ∧ q < 2 ^ k) := by
      rw [Nat.pow_succ] at ha
      by_cases hmod : a % 2 = 0
      · left; exact ⟨a / 2, by omega, by omega⟩
      · right; exact ⟨a / 2, by omega, by omega⟩
    rcases hsplit with ⟨q, rfl, hq⟩ | ⟨q, rfl, hq⟩
    · have hL : sumBits k (fun x => f ((2 * x) ^^^ (2 * q))) = sumBits k (fun x => f (2 * x)) := by
        rw [sumBits_congr k _ (fun x => f (2 * (x ^^^ q))) (fun x _ => by rw [xor_two_mul_even])]
        exact sumBits_xor_shift k q (fun y => f (2 * y)) hq
      have hR : sumBits k (fun x => f ((2 * x + 1) ^^^ (2 * q))) = sumBits k (fun x => f (2 * x + 1)) := by
        rw [sumBits_congr k _ (fun x => f (2 * (x ^^^ q) + 1)) (fun x _ => by rw [xor_two_mul_odd_even])]
        exact sumBits_xor_shift k q (fun y => f (2 * y + 1)) hq
      rw [hL, hR]
    · have hL : sumBits k (fun x => f ((2 * x) ^^^ (2 * q + 1))) = sumBits k (fun x => f (2 * x + 1)) := by
        rw [sumBits_congr k _ (fun x => f (2 * (x ^^^ q) + 1)) (fun x _ => by rw [xor_two_mul_even_odd])]
        exact sumBits_xor_shift k q (fun y => f (2 * y + 1)) hq
      have hR : sumBits k (fun x => f ((2 * x + 1) ^^^ (2 * q + 1))) = sumBits k (fun x => f (2 * x)) := by
        rw [sumBits_congr k _ (fun x => f (2 * (x ^^^ q))) (fun x _ => by rw [xor_two_mul_odd_odd])]
        exact sumBits_xor_shift k q (fun y => f (2 * y)) hq
      rw [hL, hR]; omega

/-! ### T2a: Universal Symplectic Lagrangian Rigidity (ALL `n`) -/

/-- A subgroup `H ≤ 𝔽₂^(2n)` represented by its membership predicate `inH : Nat → Nat → Bool`. -/
structure PauliSubgroup (n : Nat) where
  inH : Nat → Nat → Bool
  hasZero : inH 0 0 = true
  closedXor : ∀ a1 b1 a2 b2, a1 < 2 ^ n → b1 < 2 ^ n → a2 < 2 ^ n → b2 < 2 ^ n →
    inH a1 b1 = true → inH a2 b2 = true → inH (a1 ^^^ a2) (b1 ^^^ b2) = true

/-- Exact symplectic character sum `∑_{(pa,pb) ∈ H} (-1)^{ω((pa,pb),(ra,rb))}`. -/
def subgroupCharSum (n : Nat) (H : PauliSubgroup n) (ra rb : Nat) : Int :=
  sumBits n (fun pa =>
    sumBits n (fun pb =>
      if H.inH pa pb then paritySign (sympForm n pa pb ra rb) else 0))

/-- Size `|H|` of a Pauli subgroup. -/
def subgroupCard (n : Nat) (H : PauliSubgroup n) : Int :=
  sumBits n (fun pa => sumBits n (fun pb => if H.inH pa pb then 1 else 0))

theorem subgroupCard_pos (n : Nat) (H : PauliSubgroup n) : 0 < subgroupCard n H := by
  have hge : ∀ (k : Nat) (g : Nat → Int), (∀ x, x < 2 ^ k → 0 ≤ g x) → g 0 ≤ sumBits k g := by
    intro k
    induction k with
    | zero => intro g _; exact Int.le_refl (g 0)
    | succ j ih =>
      intro g hg
      simp only [sumBits]
      have hL := ih (fun x => g (2 * x)) (fun x hx => hg (2 * x) (by rw [Nat.pow_succ]; omega))
      have hR := sumBits_nonneg j (fun x => g (2 * x + 1))
        (fun x hx => hg (2 * x + 1) (by rw [Nat.pow_succ]; omega))
      change g 0 ≤ _ at hL
      omega
  unfold subgroupCard
  have houter := hge n (fun pa => sumBits n (fun pb => if H.inH pa pb then 1 else 0))
    (fun pa _ => sumBits_nonneg n _ (fun pb _ => by split <;> omega))
  have hinner := hge n (fun pb => if H.inH 0 pb then 1 else 0)
    (fun pb _ => by split <;> omega)
  simp only [H.hasZero, ite_true] at hinner
  omega

/-- If `(ra, rb) ∈ H^⊥`, then `subgroupCharSum n H ra rb = subgroupCard n H > 0`. -/
theorem subgroupCharSum_of_perp (n : Nat) (H : PauliSubgroup n) (ra rb : Nat)
    (hperp : ∀ pa pb, pa < 2 ^ n → pb < 2 ^ n → H.inH pa pb = true →
      sympForm n pa pb ra rb = false) :
    subgroupCharSum n H ra rb = subgroupCard n H := by
  simp only [subgroupCharSum, subgroupCard]
  apply sumBits_congr; intro pa hpa
  apply sumBits_congr; intro pb hpb
  cases hmem : H.inH pa pb
  · rfl
  · simp [hperp pa pb hpa hpb hmem, paritySign]

/-- If `(ra, rb) ∉ H^⊥`, then `subgroupCharSum n H ra rb = 0` by XOR-shift sign negation. -/
theorem subgroupCharSum_eq_zero_of_not_perp (n : Nat) (H : PauliSubgroup n) (ra rb : Nat)
    (ha : ∃ h1 h2, h1 < 2 ^ n ∧ h2 < 2 ^ n ∧ H.inH h1 h2 = true ∧
      sympForm n h1 h2 ra rb = true) :
    subgroupCharSum n H ra rb = 0 := by
  rcases ha with ⟨h1, h2, hh1, hh2, hmem, hanti⟩
  have hinner : ∀ pa, pa < 2 ^ n →
      sumBits n (fun pb => if H.inH (pa ^^^ h1) pb then paritySign (sympForm n (pa ^^^ h1) pb ra rb) else 0) =
      -sumBits n (fun pb => if H.inH pa pb then paritySign (sympForm n pa pb ra rb) else 0) := by
    intro pa hpa
    rw [← sumBits_xor_shift n h2 _ hh2, ← sumBits_neg]
    apply sumBits_congr; intro pb hpb
    have hiff : H.inH (pa ^^^ h1) (pb ^^^ h2) = H.inH pa pb := by
      cases hm : H.inH pa pb
      · cases hm2 : H.inH (pa ^^^ h1) (pb ^^^ h2)
        · rfl
        · have hback := H.closedXor (pa ^^^ h1) (pb ^^^ h2) h1 h2
            (Nat.xor_lt_two_pow hpa hh1) (Nat.xor_lt_two_pow hpb hh2) hh1 hh2 hm2 hmem
          rw [Nat.xor_assoc, Nat.xor_self, Nat.xor_zero,
              Nat.xor_assoc, Nat.xor_self, Nat.xor_zero] at hback
          rw [hm] at hback; contradiction
      · exact H.closedXor pa pb h1 h2 hpa hpb hh1 hh2 hm hmem
    rw [hiff]
    cases H.inH pa pb
    · simp
    · simp only [ite_true, sympForm_xor_left, hanti, paritySign_xor]
      have : paritySign true = -1 := rfl
      rw [this]; omega
  have hshift : subgroupCharSum n H ra rb = -subgroupCharSum n H ra rb := by
    calc subgroupCharSum n H ra rb
        = sumBits n (fun pa => sumBits n (fun pb => if H.inH (pa ^^^ h1) pb then paritySign (sympForm n (pa ^^^ h1) pb ra rb) else 0)) :=
          (sumBits_xor_shift n h1 _ hh1).symm
      _ = sumBits n (fun pa => -sumBits n (fun pb => if H.inH pa pb then paritySign (sympForm n pa pb ra rb) else 0)) :=
          sumBits_congr n _ _ hinner
      _ = -subgroupCharSum n H ra rb := sumBits_neg n _
  omega

/-- **T2a (Universal Symplectic Lagrangian Rigidity — ALL `n`):**
    If a basis stabilizer subgroup `H ≤ 𝔽₂^(2n)` satisfies the MUB resolution of identity
    `subgroupCharSum n H ra rb * c(ra, rb) = 0` for all non-identity `(ra, rb)`, and the
    fiducial has `c(ra, rb) ≠ 0` on all `(ra, rb) ∉ H`, then `H^⊥ ⊆ H`. -/
theorem symplectic_lagrangian_rigidity (n : Nat) (H : PauliSubgroup n)
    (c : Nat → Nat → Int)
    (hsupp : ∀ ra rb, ra < 2 ^ n → rb < 2 ^ n → H.inH ra rb = false → c ra rb ≠ 0)
    (hres : ∀ ra rb, ra < 2 ^ n → rb < 2 ^ n → (ra ≠ 0 ∨ rb ≠ 0) →
      subgroupCharSum n H ra rb * c ra rb = 0) :
    ∀ ra rb, ra < 2 ^ n → rb < 2 ^ n →
      (∀ pa pb, pa < 2 ^ n → pb < 2 ^ n → H.inH pa pb = true →
        sympForm n pa pb ra rb = false) →
      H.inH ra rb = true := by
  intro ra rb hra hrb hperp
  cases hmem : H.inH ra rb
  · exfalso
    have hne : ra ≠ 0 ∨ rb ≠ 0 := by
      cases ra with
      | zero =>
        cases rb with
        | zero => rw [H.hasZero] at hmem; contradiction
        | succ _ => right; omega
      | succ _ => left; omega
    have hcs := subgroupCharSum_of_perp n H ra rb hperp
    have hpos := subgroupCard_pos n H
    have hcz := hres ra rb hra hrb hne
    rw [hcs] at hcz
    have hcnz := hsupp ra rb hra hrb hmem
    rcases Int.mul_eq_zero.mp hcz with h1 | h2
    · omega
    · exact hcnz h2
  · rfl

/-! ### T2b: Universal Fermat Gaussian-Square Locking (ALL Even `n = 2m`) -/

private theorem sq_mod4_cases (x : Int) : (x * x) % 4 = 0 ∨ (x * x) % 4 = 1 := by
  have hmod : (x * x) % 4 = ((x % 4) * (x % 4)) % 4 := by rw [Int.mul_emod]
  rw [hmod]
  have hr : x % 4 = 0 ∨ x % 4 = 1 ∨ x % 4 = 2 ∨ x % 4 = 3 := by omega
  rcases hr with h | h | h | h <;> rw [h] <;> decide

private theorem even_of_sq_mod4_zero (x : Int) (h : (x * x) % 4 = 0) : x % 2 = 0 := by
  have hmod : (x * x) % 4 = ((x % 4) * (x % 4)) % 4 := by rw [Int.mul_emod]
  rw [hmod] at h
  have hr : x % 4 = 0 ∨ x % 4 = 1 ∨ x % 4 = 2 ∨ x % 4 = 3 := by omega
  rcases hr with h0 | h1 | h2 | h3
  · omega
  · rw [h1] at h; omega
  · omega
  · rw [h3] at h; omega

private theorem abs_le_one_of_sq_le_one (x : Int) (hle : x * x ≤ 1) :
    x = -1 ∨ x = 0 ∨ x = 1 := by
  if h : x = -1 ∨ x = 0 ∨ x = 1 then
    exact h
  else
    exfalso
    have hge2 : x ≥ 2 ∨ x ≤ -2 := by omega
    rcases hge2 with hpos | hneg
    · have : x * x ≥ 4 := Int.mul_le_mul hpos hpos (by decide) (by omega)
      omega
    · have hnp : -x ≥ 2 := by omega
      have : (-x) * (-x) ≥ 4 := Int.mul_le_mul hnp hnp (by decide) (by omega)
      rw [Int.neg_mul_neg] at this; omega

/-- **T2b (Universal Fermat Gaussian-Square Locking — ALL `m : Nat`):**
    The ONLY integer solutions to `R^2 + I^2 = 2^(2m)` are the four axis points
    `(±2^m, 0)` and `(0, ±2^m)`. -/
theorem fermat_gaussian_pow2_locking :
    ∀ (m : Nat) (R I : Int),
      R * R + I * I = ((2 : Int) ^ m) * ((2 : Int) ^ m) →
      ((R = (2 : Int) ^ m ∨ R = -((2 : Int) ^ m)) ∧ I = 0) ∨
      (R = 0 ∧ (I = (2 : Int) ^ m ∨ I = -((2 : Int) ^ m)))
  | 0, R, I, heq => by
    have h1 : ((2 : Int) ^ 0) = 1 := rfl
    rw [h1] at heq ⊢
    have hR0 : 0 ≤ R * R := int_sq_nonneg R
    have hI0 : 0 ≤ I * I := int_sq_nonneg I
    have hRbound := abs_le_one_of_sq_le_one R (by omega)
    have hIbound := abs_le_one_of_sq_le_one I (by omega)
    rcases hRbound with rfl | rfl | rfl <;> rcases hIbound with rfl | rfl | rfl <;> simp at heq ⊢
  | k + 1, R, I, heq => by
    have hpow : ((2 : Int) ^ (k + 1)) * ((2 : Int) ^ (k + 1)) =
        4 * (((2 : Int) ^ k) * ((2 : Int) ^ k)) := by
      rw [Int.pow_succ]; grind
    rw [hpow] at heq
    have hmod4 : (R * R + I * I) % 4 = 0 := by rw [heq]; omega
    have hR4 := sq_mod4_cases R
    have hI4 := sq_mod4_cases I
    have hR0 : (R * R) % 4 = 0 := by omega
    have hI0 : (I * I) % 4 = 0 := by omega
    have hReven : R % 2 = 0 := even_of_sq_mod4_zero R hR0
    have hIeven : I % 2 = 0 := even_of_sq_mod4_zero I hI0
    have hR2 : R = 2 * (R / 2) := by omega
    have hI2 : I = 2 * (I / 2) := by omega
    have hred : (R / 2) * (R / 2) + (I / 2) * (I / 2) =
        ((2 : Int) ^ k) * ((2 : Int) ^ k) := by
      have hRsq : R * R = 4 * ((R / 2) * (R / 2)) := by grind
      have hIsq : I * I = 4 * ((I / 2) * (I / 2)) := by grind
      omega
    have ih := fermat_gaussian_pow2_locking k (R / 2) (I / 2) hred
    have h2s : (2 : Int) ^ (k + 1) = 2 * ((2 : Int) ^ k) := by rw [Int.pow_succ]; omega
    rw [h2s]
    rcases ih with ⟨hR | hR, hI⟩ | ⟨hR, hI | hI⟩
    · left; exact ⟨Or.inl (by omega), by omega⟩
    · left; exact ⟨Or.inr (by omega), by omega⟩
    · right; exact ⟨by omega, Or.inl (by omega)⟩
    · right; exact ⟨by omega, Or.inr (by omega)⟩

/-! ### T2c: Exact Poisson Summation & Universal Rothaus Degree Bound (ALL `m ≥ 2`) -/

/-- Exact integer Walsh–Hadamard transform `W_f(u) = ∑_{x < 2^n} (-1)^{f(x) ⊕ (u · x)}`. -/
def walshTransform (n : Nat) (f : Nat → Bool) (u : Nat) : Int :=
  sumBits n (fun x => paritySign (xor (f x) (dotMod2 n u x)))

/-- Exact Boolean bent predicate on `𝔽₂^(2m)`: `W_f(u) ∈ {+2^m, -2^m}` for every `u < 2^(2m)`. -/
def IsBent (m : Nat) (f : Nat → Bool) : Prop :=
  ∀ u, u < 2 ^ (2 * m) →
    walshTransform (2 * m) f u = (2 : Int) ^ m ∨ walshTransform (2 * m) f u = -((2 : Int) ^ m)

/-- Exact integer sum over subcube `V_M = {x < 2^n : (x &&& M) = x}`. -/
def sumSubcube (n M : Nat) (g : Nat → Int) : Int :=
  sumBits n (fun x => if (x &&& M) == x then g x else 0)

/-- Exact integer sum over orthogonal subspace `V_M^⊥ = {u < 2^n : (u &&& M) = 0}`. -/
def sumPerpSubcube (n M : Nat) (g : Nat → Int) : Int :=
  sumBits n (fun u => if (u &&& M) == 0 then g u else 0)

/-- Exact ANF (Möbius) sum of monomial `M` in `f`: monomial `x^M` appears iff `anfSum n f M % 2 = 1`. -/
def anfSum (n : Nat) (f : Nat → Bool) (M : Nat) : Int :=
  sumSubcube n M (fun x => if f x then 1 else 0)

private theorem dotMod2_two_step (k u x : Nat) :
    dotMod2 (k + 1) (2 * u) (2 * x) = dotMod2 k u x ∧
    dotMod2 (k + 1) (2 * u) (2 * x + 1) = dotMod2 k u x ∧
    dotMod2 (k + 1) (2 * u + 1) (2 * x) = dotMod2 k u x ∧
    dotMod2 (k + 1) (2 * u + 1) (2 * x + 1) = !(dotMod2 k u x) := by
  have hsr : ∀ y, (2 * y) >>> 1 = y ∧ (2 * y + 1) >>> 1 = y := by
    intro y; simp [Nat.shiftRight_eq_div_pow]; omega
  refine ⟨?_, ?_, ?_, ?_⟩
  · simp only [dotMod2, and_two_mul_even, (hsr u).1, (hsr x).1, and_one_eq_mod2]
    have : (2 * (u &&& x)) % 2 = 0 := by omega
    simp [this]
  · simp only [dotMod2, and_two_mul_even_odd, (hsr u).1, (hsr x).2, and_one_eq_mod2]
    have : (2 * (u &&& x)) % 2 = 0 := by omega
    simp [this]
  · simp only [dotMod2, and_two_mul_odd_even, (hsr u).2, (hsr x).1, and_one_eq_mod2]
    have : (2 * (u &&& x)) % 2 = 0 := by omega
    simp [this]
  · simp only [dotMod2, and_two_mul_odd_odd, (hsr u).2, (hsr x).2, and_one_eq_mod2]
    have : (2 * (u &&& x) + 1) % 2 = 1 := by omega
    simp [this]

private theorem beq_two_mul (a b : Nat) : (2 * a == 2 * b) = (a == b) := by
  by_cases h : a = b
  · subst h; simp
  · have h2 : 2 * a ≠ 2 * b := by omega
    rw [beq_eq_false_iff_ne.mpr h, beq_eq_false_iff_ne.mpr h2]

private theorem beq_two_mul_add1 (a b : Nat) : (2 * a + 1 == 2 * b + 1) = (a == b) := by
  by_cases h : a = b
  · subst h; simp
  · have h2 : 2 * a + 1 ≠ 2 * b + 1 := by omega
    rw [beq_eq_false_iff_ne.mpr h, beq_eq_false_iff_ne.mpr h2]

/-- Exact cardinality of subcube `V_M`: `∑_{x ⊆ M} 1 = 2^(popcount n M)`. -/
theorem sumSubcube_ones : ∀ (n M : Nat),
    sumSubcube n M (fun _ => 1) = (2 : Int) ^ (popcount n M)
  | 0, _ => by simp [sumSubcube, sumBits, popcount]
  | k + 1, M => by
    have hsplitM : (∃ q, M = 2 * q) ∨ (∃ q, M = 2 * q + 1) := by
      by_cases h : M % 2 = 0
      · left; exact ⟨M / 2, by omega⟩
      · right; exact ⟨M / 2, by omega⟩
    rcases hsplitM with ⟨q, rfl⟩ | ⟨q, rfl⟩
    · unfold sumSubcube
      simp only [sumBits, popcount]
      have hbit : (2 * q) &&& 1 = 0 := by rw [and_one_eq_mod2]; omega
      have hsr : (2 * q) >>> 1 = q := by simp [Nat.shiftRight_eq_div_pow]
      rw [hbit, hsr, Nat.zero_add]
      have hL : sumBits k (fun x => if ((2 * x) &&& (2 * q)) == 2 * x then (1 : Int) else 0) =
          sumSubcube k q (fun _ => 1) := by
        unfold sumSubcube; apply sumBits_congr; intro x _
        rw [and_two_mul_even, beq_two_mul]
      have hR : sumBits k (fun x => if ((2 * x + 1) &&& (2 * q)) == 2 * x + 1 then (1 : Int) else 0) = 0 := by
        have hz : ∀ x, (((2 * x + 1) &&& (2 * q)) == 2 * x + 1) = false := by
          intro x; rw [and_two_mul_odd_even, beq_eq_false_iff_ne]; omega
        rw [sumBits_congr k _ (fun _ => 0) (fun x _ => by rw [hz x]; rfl)]
        rw [sumBits_const, Int.mul_zero]
      rw [hL, hR, Int.add_zero, sumSubcube_ones k q]
    · unfold sumSubcube
      simp only [sumBits, popcount]
      have hbit : (2 * q + 1) &&& 1 = 1 := by rw [and_one_eq_mod2]; omega
      have hsr : (2 * q + 1) >>> 1 = q := by simp [Nat.shiftRight_eq_div_pow]; omega
      rw [hbit, hsr]
      have hL : sumBits k (fun x => if ((2 * x) &&& (2 * q + 1)) == 2 * x then (1 : Int) else 0) =
          sumSubcube k q (fun _ => 1) := by
        unfold sumSubcube; apply sumBits_congr; intro x _
        rw [and_two_mul_even_odd, beq_two_mul]
      have hR : sumBits k (fun x => if ((2 * x + 1) &&& (2 * q + 1)) == 2 * x + 1 then (1 : Int) else 0) =
          sumSubcube k q (fun _ => 1) := by
        unfold sumSubcube; apply sumBits_congr; intro x _
        rw [and_two_mul_odd_odd, beq_two_mul_add1]
      rw [hL, hR, sumSubcube_ones k q]
      have hexp : 1 + popcount k q = popcount k q + 1 := by omega
      rw [hexp, Int.pow_succ]; omega

theorem popcount_le : ∀ (n M : Nat), popcount n M ≤ n
  | 0, _ => Nat.le_refl 0
  | k + 1, M => by
    simp only [popcount]
    have hbit : M &&& 1 ≤ 1 := by rw [and_one_eq_mod2]; omega
    have ih := popcount_le k (M >>> 1)
    omega

/-- Exact orthogonal character sum over `V_M^⊥`:
    `∑_{u ∈ V_M^⊥} (-1)^{u · x} = 2^(n - popcount n M)` if `x ∈ V_M`, and `0` otherwise. -/
theorem perpSubcube_char_sum : ∀ (n M x : Nat), x < 2 ^ n →
    sumPerpSubcube n M (fun u => paritySign (dotMod2 n u x)) =
      if (x &&& M) == x then (2 : Int) ^ (n - popcount n M) else 0
  | 0, _, x, hx => by
    have hx0 : x = 0 := by omega
    subst hx0
    simp [sumPerpSubcube, sumBits, popcount, dotMod2, paritySign]
  | k + 1, M, x, hx => by
    have hsplitM : (∃ q, M = 2 * q) ∨ (∃ q, M = 2 * q + 1) := by
      by_cases h : M % 2 = 0
      · left; exact ⟨M / 2, by omega⟩
      · right; exact ⟨M / 2, by omega⟩
    have hsplitX : (∃ y, x = 2 * y ∧ y < 2 ^ k) ∨ (∃ y, x = 2 * y + 1 ∧ y < 2 ^ k) := by
      rw [Nat.pow_succ] at hx
      by_cases h : x % 2 = 0
      · left; exact ⟨x / 2, by omega, by omega⟩
      · right; exact ⟨x / 2, by omega, by omega⟩
    have h2eq0 : ∀ z : Nat, (2 * z == 0) = (z == 0) :=
      fun z => beq_two_mul z 0
    rcases hsplitM with ⟨q, rfl⟩ | ⟨q, rfl⟩
    · have hle := popcount_le k q
      have hbit : (2 * q) &&& 1 = 0 := by rw [and_one_eq_mod2]; omega
      have hsr : (2 * q) >>> 1 = q := by simp [Nat.shiftRight_eq_div_pow]
      rcases hsplitX with ⟨y, rfl, hy⟩ | ⟨y, rfl, hy⟩
      · unfold sumPerpSubcube
        simp only [sumBits, popcount, hbit, hsr, Nat.zero_add]
        have hL : sumBits k (fun u => if ((2 * u) &&& (2 * q)) == 0 then paritySign (dotMod2 (k + 1) (2 * u) (2 * y)) else 0) =
            sumPerpSubcube k q (fun u => paritySign (dotMod2 k u y)) := by
          unfold sumPerpSubcube; apply sumBits_congr; intro u _
          rw [and_two_mul_even, h2eq0, (dotMod2_two_step k u y).1]
        have hR : sumBits k (fun u => if ((2 * u + 1) &&& (2 * q)) == 0 then paritySign (dotMod2 (k + 1) (2 * u + 1) (2 * y)) else 0) =
            sumPerpSubcube k q (fun u => paritySign (dotMod2 k u y)) := by
          unfold sumPerpSubcube; apply sumBits_congr; intro u _
          rw [and_two_mul_odd_even, h2eq0, (dotMod2_two_step k u y).2.2.1]
        rw [hL, hR, perpSubcube_char_sum k q y hy, and_two_mul_even, beq_two_mul]
        cases ((y &&& q) == y)
        · simp
        · simp only [ite_true]
          have hexp : k + 1 - popcount k q = (k - popcount k q) + 1 := by omega
          rw [hexp, Int.pow_succ]; omega
      · unfold sumPerpSubcube
        simp only [sumBits, popcount, hbit, hsr, Nat.zero_add]
        have hL : sumBits k (fun u => if ((2 * u) &&& (2 * q)) == 0 then paritySign (dotMod2 (k + 1) (2 * u) (2 * y + 1)) else 0) =
            sumPerpSubcube k q (fun u => paritySign (dotMod2 k u y)) := by
          unfold sumPerpSubcube; apply sumBits_congr; intro u _
          rw [and_two_mul_even, h2eq0, (dotMod2_two_step k u y).2.1]
        have hR : sumBits k (fun u => if ((2 * u + 1) &&& (2 * q)) == 0 then paritySign (dotMod2 (k + 1) (2 * u + 1) (2 * y + 1)) else 0) =
            -sumPerpSubcube k q (fun u => paritySign (dotMod2 k u y)) := by
          unfold sumPerpSubcube; rw [← sumBits_neg]
          apply sumBits_congr; intro u _
          rw [and_two_mul_odd_even, h2eq0, (dotMod2_two_step k u y).2.2.2]
          cases (u &&& q == 0)
          · simp
          · simp only [ite_true]; cases dotMod2 k u y <;> decide
        have hne : (((2 * y + 1) &&& (2 * q)) == 2 * y + 1) = false := by
          rw [and_two_mul_odd_even, beq_eq_false_iff_ne]; omega
        rw [hL, hR, hne]; simp; omega
    · have hle := popcount_le k q
      have hbit : (2 * q + 1) &&& 1 = 1 := by rw [and_one_eq_mod2]; omega
      have hsr : (2 * q + 1) >>> 1 = q := by simp [Nat.shiftRight_eq_div_pow]; omega
      rcases hsplitX with ⟨y, rfl, hy⟩ | ⟨y, rfl, hy⟩
      · unfold sumPerpSubcube
        simp only [sumBits, popcount, hbit, hsr]
        have hR : sumBits k (fun u => if ((2 * u + 1) &&& (2 * q + 1)) == 0 then paritySign (dotMod2 (k + 1) (2 * u + 1) (2 * y)) else 0) = 0 := by
          have hz : ∀ u, (((2 * u + 1) &&& (2 * q + 1)) == 0) = false := by
            intro u; rw [and_two_mul_odd_odd, beq_eq_false_iff_ne]; omega
          rw [sumBits_congr k _ (fun _ => 0) (fun u _ => by rw [hz u]; rfl)]
          rw [sumBits_const, Int.mul_zero]
        have hL : sumBits k (fun u => if ((2 * u) &&& (2 * q + 1)) == 0 then paritySign (dotMod2 (k + 1) (2 * u) (2 * y)) else 0) =
            sumPerpSubcube k q (fun u => paritySign (dotMod2 k u y)) := by
          unfold sumPerpSubcube; apply sumBits_congr; intro u _
          rw [and_two_mul_even_odd, h2eq0, (dotMod2_two_step k u y).1]
        rw [hL, hR, Int.add_zero, perpSubcube_char_sum k q y hy, and_two_mul_even_odd, beq_two_mul]
        have hexp : k + 1 - (1 + popcount k q) = k - popcount k q := by omega
        rw [hexp]
      · unfold sumPerpSubcube
        simp only [sumBits, popcount, hbit, hsr]
        have hR : sumBits k (fun u => if ((2 * u + 1) &&& (2 * q + 1)) == 0 then paritySign (dotMod2 (k + 1) (2 * u + 1) (2 * y + 1)) else 0) = 0 := by
          have hz : ∀ u, (((2 * u + 1) &&& (2 * q + 1)) == 0) = false := by
            intro u; rw [and_two_mul_odd_odd, beq_eq_false_iff_ne]; omega
          rw [sumBits_congr k _ (fun _ => 0) (fun u _ => by rw [hz u]; rfl)]
          rw [sumBits_const, Int.mul_zero]
        have hL : sumBits k (fun u => if ((2 * u) &&& (2 * q + 1)) == 0 then paritySign (dotMod2 (k + 1) (2 * u) (2 * y + 1)) else 0) =
            sumPerpSubcube k q (fun u => paritySign (dotMod2 k u y)) := by
          unfold sumPerpSubcube; apply sumBits_congr; intro u _
          rw [and_two_mul_even_odd, h2eq0, (dotMod2_two_step k u y).2.1]
        rw [hL, hR, Int.add_zero, perpSubcube_char_sum k q y hy, and_two_mul_odd_odd, beq_two_mul_add1]
        have hexp : k + 1 - (1 + popcount k q) = k - popcount k q := by omega
        rw [hexp]

/-- Exact Poisson summation on `𝔽₂^n` linking the Walsh transform to the Möbius ANF sum. -/
theorem poisson_anf_identity (n M : Nat) (f : Nat → Bool) :
    sumPerpSubcube n M (fun u => walshTransform n f u) =
      ((2 : Int) ^ (n - popcount n M)) *
        (((2 : Int) ^ (popcount n M)) - 2 * anfSum n f M) := by
  have h1 : sumPerpSubcube n M (fun u => walshTransform n f u) =
      sumBits n (fun x => paritySign (f x) * sumPerpSubcube n M (fun u => paritySign (dotMod2 n u x))) := by
    unfold sumPerpSubcube walshTransform
    have hsplit : ∀ u, (if (u &&& M) == 0 then sumBits n (fun x => paritySign (xor (f x) (dotMod2 n u x))) else 0) =
        sumBits n (fun x => paritySign (f x) * (if (u &&& M) == 0 then paritySign (dotMod2 n u x) else 0)) := by
      intro u
      cases (u &&& M) == 0
      · simp only [Bool.false_eq_true, ite_false, Int.mul_zero]
        rw [sumBits_const]; simp
      · simp only [ite_true]
        apply sumBits_congr; intro x _
        exact paritySign_xor (f x) (dotMod2 n u x)
    rw [sumBits_congr n _ _ (fun u _ => hsplit u), sumBits_swap]
    apply sumBits_congr; intro x _; rw [sumBits_mul_left]
  rw [h1]
  have h2 : sumBits n (fun x => paritySign (f x) * sumPerpSubcube n M (fun u => paritySign (dotMod2 n u x))) =
      ((2 : Int) ^ (n - popcount n M)) * sumSubcube n M (fun x => paritySign (f x)) := by
    unfold sumSubcube
    rw [← sumBits_mul_left]
    apply sumBits_congr; intro x hx
    rw [perpSubcube_char_sum n M x hx]
    cases ((x &&& M) == x) <;> simp [Int.mul_comm]
  rw [h2]
  have h3 : sumSubcube n M (fun x => paritySign (f x)) =
      ((2 : Int) ^ (popcount n M)) - 2 * anfSum n f M := by
    have hstep : ∀ x, paritySign (f x) = 1 - 2 * (if f x then (1 : Int) else 0) := by
      intro x; cases f x <;> decide
    unfold sumSubcube anfSum
    have heq : sumBits n (fun x => if (x &&& M) == x then paritySign (f x) else 0) =
        sumBits n (fun x => (if (x &&& M) == x then (1 : Int) else 0) -
          2 * (if (x &&& M) == x then (if f x then (1 : Int) else 0) else 0)) := by
      apply sumBits_congr; intro x _
      cases ((x &&& M) == x)
      · simp
      · simp only [ite_true]; exact hstep x
    rw [heq, sumBits_sub, sumBits_mul_left]
    have hones := sumSubcube_ones n M
    unfold sumSubcube at hones
    rw [hones]
    rfl
  rw [h3]

private theorem sumPerp_pm1_mod2 (n M : Nat) (eps : Nat → Int)
    (heps : ∀ u, u < 2 ^ n → eps u = 1 ∨ eps u = -1) :
    (sumPerpSubcube n M eps) % 2 = (sumPerpSubcube n M (fun _ => 1)) % 2 := by
  have hdiff : sumPerpSubcube n M (fun u => 1 - eps u) =
      2 * sumPerpSubcube n M (fun u => if eps u == -1 then 1 else 0) := by
    unfold sumPerpSubcube
    rw [← sumBits_mul_left]
    apply sumBits_congr; intro u hu
    cases ((u &&& M) == 0)
    · simp
    · simp only [ite_true]
      rcases heps u hu with h1 | hm1
      · rw [h1]; decide
      · rw [hm1]; decide
  have hsub : sumPerpSubcube n M (fun u => 1 - eps u) =
      sumPerpSubcube n M (fun _ => 1) - sumPerpSubcube n M eps := by
    unfold sumPerpSubcube
    rw [← sumBits_sub]
    apply sumBits_congr; intro u _
    cases ((u &&& M) == 0) <;> simp
  omega

/-- **T2c (Rothaus's 1976 Degree Bound — Universal for ALL `m ≥ 2`):**
    For EVERY `m ≥ 2`, EVERY Boolean bent function `f : 𝔽₂^(2m) → Bool`, and EVERY
    monomial mask `M` with Hamming weight `popcount (2 * m) M > m`, the ANF coefficient
    `anfSum (2 * m) f M` is EVEN (i.e., `anf(f, M) = 0` in `𝔽₂`). -/
theorem rothaus_degree_bound_all_m (m : Nat) (hm : 2 ≤ m) (f : Nat → Bool)
    (hbent : IsBent m f) (M : Nat) (hdeg : m < popcount (2 * m) M) :
    (anfSum (2 * m) f M) % 2 = 0 := by
  let d := popcount (2 * m) M
  have hd_eq : d = popcount (2 * m) M := rfl
  have hd_le : d ≤ 2 * m := popcount_le (2 * m) M
  have hd_gt : m < d := hdeg
  have hpois := poisson_anf_identity (2 * m) M f
  let eps : Nat → Int := fun u => if walshTransform (2 * m) f u == (2 : Int) ^ m then 1 else -1
  have heps_val : ∀ u, u < 2 ^ (2 * m) → eps u = 1 ∨ eps u = -1 := by
    intro u _; dsimp [eps]; split <;> simp
  have hpos_pow : ∀ k : Nat, (0 : Int) < (2 : Int) ^ k := by
    intro k; induction k with | zero => decide | succ j ih => rw [Int.pow_succ]; omega
  have hW_eq : sumPerpSubcube (2 * m) M (fun u => walshTransform (2 * m) f u) =
      ((2 : Int) ^ m) * sumPerpSubcube (2 * m) M eps := by
    unfold sumPerpSubcube
    rw [← sumBits_mul_left]
    apply sumBits_congr; intro u hu
    cases ((u &&& M) == 0)
    · simp
    · simp only [ite_true]
      rcases hbent u hu with hpos | hneg
      · dsimp [eps]; simp [hpos]
      · dsimp [eps]
        have hgt := hpos_pow m
        have hne : (-((2 : Int) ^ m) == (2 : Int) ^ m) = false := by
          simp; omega
        rw [hneg, hne]; simp
  rw [hW_eq] at hpois
  have hpow_split : (2 : Int) ^ m = ((2 : Int) ^ (2 * m - d)) * ((2 : Int) ^ (d - m)) := by
    rw [← Int.pow_add]
    have : (2 * m - d) + (d - m) = m := by omega
    rw [this]
  rw [← hd_eq] at hpois
  rw [hpow_split, Int.mul_assoc] at hpois
  have hdiv : ((2 : Int) ^ d) - 2 * anfSum (2 * m) f M =
      ((2 : Int) ^ (d - m)) * sumPerpSubcube (2 * m) M eps := by
    have hgt := hpos_pow (2 * m - d)
    have hsub : ((2 : Int) ^ (2 * m - d)) *
        ((((2 : Int) ^ d) - 2 * anfSum (2 * m) f M) -
         ((2 : Int) ^ (d - m)) * sumPerpSubcube (2 * m) M eps) = 0 := by
      rw [Int.mul_sub]; omega
    rcases Int.mul_eq_zero.mp hsub with hz | hEq
    · omega
    · omega
  have hpow_mod4 : ∀ k : Nat, 2 ≤ k → ((2 : Int) ^ k) % 4 = 0 := by
    intro k hk
    have hsplit : (k - 2) + 2 = k := by omega
    have hadd := Int.pow_add (2 : Int) (k - 2) 2
    rw [hsplit] at hadd
    have h22 : (2 : Int) ^ 2 = 4 := by decide
    rw [hadd, h22]; omega
  have hpow_mod2 : ∀ k : Nat, 1 ≤ k → ((2 : Int) ^ k) % 2 = 0 := by
    intro k hk
    have hsplit : (k - 1).succ = k := by omega
    have hsucc := Int.pow_succ (2 : Int) (k - 1)
    rw [hsplit] at hsucc
    omega
  have h2d_mod4 : ((2 : Int) ^ d) % 4 = 0 := hpow_mod4 d (by omega)
  have hrhs_mod4 : (((2 : Int) ^ (d - m)) * sumPerpSubcube (2 * m) M eps) % 4 = 0 := by
    by_cases hdm1 : d - m = 1
    · rw [hdm1]
      have h21 : (2 : Int) ^ 1 = 2 := by decide
      rw [h21]
      have hpos_nat : 0 < 2 ^ (2 * m) := by
        induction (2 * m) with | zero => decide | succ j ih => rw [Nat.pow_succ]; omega
      have hcard := perpSubcube_char_sum (2 * m) M 0 hpos_nat
      have hdot0 : ∀ k u, dotMod2 k u 0 = false := by
        intro k; induction k with
        | zero => intro _; rfl
        | succ j ih => intro u; simp [dotMod2, ih]
      have hones : sumPerpSubcube (2 * m) M (fun _ => 1) = (2 : Int) ^ (2 * m - d) := by
        have hcon : sumPerpSubcube (2 * m) M (fun u => paritySign (dotMod2 (2 * m) u 0)) =
            sumPerpSubcube (2 * m) M (fun _ => 1) := by
          unfold sumPerpSubcube; apply sumBits_congr; intro u _
          dsimp only; rw [hdot0 (2 * m) u]; rfl
        rw [hcon] at hcard
        simp at hcard
        exact hcard
      have hpar := sumPerp_pm1_mod2 (2 * m) M eps heps_val
      rw [hones] at hpar
      have heven_pow : ((2 : Int) ^ (2 * m - d)) % 2 = 0 := hpow_mod2 (2 * m - d) (by omega)
      omega
    · have h4d : ((2 : Int) ^ (d - m)) % 4 = 0 := hpow_mod4 (d - m) (by omega)
      have hmul : (((2 : Int) ^ (d - m)) * sumPerpSubcube (2 * m) M eps) % 4 =
          ((((2 : Int) ^ (d - m)) % 4) * (sumPerpSubcube (2 * m) M eps % 4)) % 4 := by
        rw [Int.mul_emod]
      rw [hmul, h4d]; simp
  omega

/-! ### T2d & T2e: Complete `n = 4` Bent-Hyperplane Rupture (All 896 Bent Functions & All `ℤ₄` States) -/

/-- Evaluates the homogeneous degree-2 quadratic form on `𝔽₂⁴` encoded by 6-bit `qMask < 64`. -/
def quad4Eval (qMask x : Nat) : Bool :=
  let x0 := (x &&& 1) == 1
  let x1 := ((x >>> 1) &&& 1) == 1
  let x2 := ((x >>> 2) &&& 1) == 1
  let x3 := ((x >>> 3) &&& 1) == 1
  let t0 := ((qMask &&& 1) == 1) && x0 && x1
  let t1 := (((qMask >>> 1) &&& 1) == 1) && x0 && x2
  let t2 := (((qMask >>> 2) &&& 1) == 1) && x0 && x3
  let t3 := (((qMask >>> 3) &&& 1) == 1) && x1 && x2
  let t4 := (((qMask >>> 4) &&& 1) == 1) && x1 && x3
  let t5 := (((qMask >>> 5) &&& 1) == 1) && x2 && x3
  xor (xor (xor t0 t1) (xor t2 t3)) (xor t4 t5)

/-- Evaluates an arbitrary degree-≤2 Boolean function on `𝔽₂⁴`. -/
def deg2Eval4 (qMask lin : Nat) (c0 : Bool) (x : Nat) : Bool :=
  xor (xor (quad4Eval qMask x) (dotMod2 4 lin x)) c0

/-- Decidable check that `f : Nat → Bool` on `𝔽₂⁴` is bent (`|W_f(u)| = 4` for all `u < 16`). -/
def isBent4Bool (f : Nat → Bool) : Bool :=
  (List.range 16).all fun u =>
    let w := walshTransform 4 f u
    w == 4 || w == -4

/-- Exact count of nondegenerate quadratic forms on `𝔽₂⁴` (out of 64). -/
def countNondegenQuad4 : Nat :=
  ((List.range 64).filter fun q => isBent4Bool (quad4Eval q)).length

/-- Indicator of the derivative zero-set `E_a(f) = {x ∈ 𝔽₂⁴ : f(x) = f(x ⊕ a)}`. -/
def inEa (f : Nat → Bool) (a x : Nat) : Bool :=
  f x == f (x ^^^ a)

/-- Exact real part of `16 * ⟨u|X^a|u⟩` for `u_x = i^(f(x) + 2*h(x))`. -/
def z4RealExpect4 (f h : Nat → Bool) (a : Nat) : Int :=
  sumBits 4 (fun x => if inEa f a x then paritySign (xor (h x) (h (x ^^^ a))) else 0)

/-- Exact parity of `h` summed over `E_a(f)`. -/
def eaParity (f h : Nat → Bool) (a : Nat) : Int :=
  sumBits 4 (fun x => if inEa f a x && h x then 1 else 0)

/-- Checks that `qMask` admits a nonzero triple `(a, b, a ⊕ b)` with
    `1_{E_a} ⊕ 1_{E_b} ⊕ 1_{E_{a⊕b}} ≡ 0 (mod 2)` identically on `𝔽₂⁴`. -/
def hasZeroTripleQuad4 (qMask : Nat) : Bool :=
  (List.range 15).any fun a0 =>
    let a := a0 + 1
    (List.range 15).any fun b0 =>
      let b := b0 + 1
      let c := a ^^^ b
      (c != 0) &&
      (List.range 16).all fun x =>
        xor (xor (inEa (quad4Eval qMask) a x) (inEa (quad4Eval qMask) b x))
            (inEa (quad4Eval qMask) c x) == false

/-- **T2d (Exact 28-Form Classification & Universal Zero-Sum Hyperplane Triple):**
    1. Exactly **28** of the 64 homogeneous quadratic forms on `𝔽₂⁴` are bent (`28 × 32 = 896`).
    2. Every bent quadratic form admits a nonzero triple `(a, b, a ⊕ b)` with
       `1_{E_a}(x) ⊕ 1_{E_b}(x) ⊕ 1_{E_{a⊕b}}(x) = 0` for all `x ∈ 𝔽₂⁴`. -/
theorem n4_quad_bent_count_and_triple :
    countNondegenQuad4 = 28 ∧
    ((List.range 64).all fun q => !isBent4Bool (quad4Eval q) || hasZeroTripleQuad4 q) = true := by
  decide

/-- Affine invariance of the 3-hyperplane indicator XOR. -/
theorem triple_indicator_affine_invariant (f : Nat → Bool) (lin : Nat) (c0 : Bool)
    (a b x : Nat) :
    xor (xor (inEa (fun y => xor (xor (f y) (dotMod2 4 lin y)) c0) a x)
             (inEa (fun y => xor (xor (f y) (dotMod2 4 lin y)) c0) b x))
        (inEa (fun y => xor (xor (f y) (dotMod2 4 lin y)) c0) (a ^^^ b) x) =
    xor (xor (inEa f a x) (inEa f b x)) (inEa f (a ^^^ b) x) := by
  have hstep : ∀ d,
      inEa (fun y => xor (xor (f y) (dotMod2 4 lin y)) c0) d x =
        xor (inEa f d x) (dotMod2 4 lin d) := by
    intro d
    simp only [inEa, dotMod2_xor_right]
    cases f x <;> cases f (x ^^^ d) <;> cases dotMod2 4 lin x <;>
      cases dotMod2 4 lin d <;> cases c0 <;> rfl
  rw [hstep a, hstep b, hstep (a ^^^ b), dotMod2_xor_right]
  cases inEa f a x <;> cases inEa f b x <;> cases inEa f (a ^^^ b) x <;>
    cases dotMod2 4 lin a <;> cases dotMod2 4 lin b <;> rfl

/-- Core 4-pair parity lemma: `|z4RealExpect4 f h a| = 4` (with `|E_a| = 8`) forces
    `eaParity f h a % 2 = 1`. -/
theorem z4_expect4_forces_odd_parity (f h : Nat → Bool) (a : Nat)
    (ha_pos : 0 < a) (ha_lt : a < 16)
    (hsize : sumBits 4 (fun x => if inEa f a x then 1 else 0) = 8)
    (hmag : z4RealExpect4 f h a = 4 ∨ z4RealExpect4 f h a = -4) :
    (eaParity f h a) % 2 = 1 := by
  have h1 : z4RealExpect4 f h a =
      8 - 2 * sumBits 4 (fun x => if inEa f a x then (if xor (h x) (h (x ^^^ a)) then 1 else 0) else 0) := by
    unfold z4RealExpect4
    rw [← hsize, ← sumBits_mul_left, ← sumBits_sub]
    apply sumBits_congr; intro x _
    cases inEa f a x
    · simp
    · cases h x <;> cases h (x ^^^ a) <;> decide
  have hbool_eq_comm : ∀ b1 b2 : Bool, (b1 == b2) = (b2 == b1) := by
    intro b1 b2; cases b1 <;> cases b2 <;> rfl
  have hshift_ea : sumBits 4 (fun x => if inEa f a x && h (x ^^^ a) then 1 else 0) = eaParity f h a := by
    unfold eaParity
    rw [← sumBits_xor_shift 4 a _ ha_lt]
    apply sumBits_congr; intro x _
    have hinv : (x ^^^ a) ^^^ a = x := by rw [Nat.xor_assoc, Nat.xor_self, Nat.xor_zero]
    have hea_sym : inEa f a (x ^^^ a) = inEa f a x := by
      simp only [inEa, hinv]; exact hbool_eq_comm _ _
    rw [hinv, hea_sym]
  have h2 : sumBits 4 (fun x => if inEa f a x then (if xor (h x) (h (x ^^^ a)) then 1 else 0) else 0) =
      2 * eaParity f h a - 2 * sumBits 4 (fun x => if inEa f a x && h x && h (x ^^^ a) then 1 else 0) := by
    have hsum : sumBits 4 (fun x => if inEa f a x then (if xor (h x) (h (x ^^^ a)) then 1 else 0) else 0) =
        sumBits 4 (fun x => (if inEa f a x && h x then 1 else 0) +
          (if inEa f a x && h (x ^^^ a) then 1 else 0) -
          2 * (if inEa f a x && h x && h (x ^^^ a) then 1 else 0)) := by
      apply sumBits_congr; intro x _
      cases inEa f a x <;> cases h x <;> cases h (x ^^^ a) <;> decide
    rw [hsum, sumBits_sub, sumBits_add, sumBits_mul_left, hshift_ea]
    unfold eaParity; omega
  have hpair_even :
      (sumBits 4 (fun x => if inEa f a x && h x && h (x ^^^ a) then 1 else 0)) % 2 = 0 := by
    let P : Nat → Bool := fun x => inEa f a x && h x && h (x ^^^ a)
    have hPsym : ∀ x, P (x ^^^ a) = P x := by
      intro x; dsimp [P]
      have hinv : (x ^^^ a) ^^^ a = x := by rw [Nat.xor_assoc, Nat.xor_self, Nat.xor_zero]
      have hea_sym : inEa f a (x ^^^ a) = inEa f a x := by
        simp only [inEa, hinv]; exact hbool_eq_comm _ _
      rw [hinv, hea_sym]
      cases inEa f a x <;> cases h x <;> cases h (x ^^^ a) <;> rfl
    have hne : ∀ x, x ^^^ a ≠ x := by
      intro x heq
      have h0 : (x ^^^ a) ^^^ x = 0 := by rw [heq, Nat.xor_self]
      rw [Nat.xor_comm x a, Nat.xor_assoc, Nat.xor_self, Nat.xor_zero] at h0
      omega
    have hsplit : sumBits 4 (fun x => if P x then 1 else 0) =
        sumBits 4 (fun x => if P x && decide (x < x ^^^ a) then 1 else 0) +
        sumBits 4 (fun x => if P x && decide (x ^^^ a < x) then 1 else 0) := by
      rw [← sumBits_add]
      apply sumBits_congr; intro x _
      have hlt_or : x < x ^^^ a ∨ x ^^^ a < x := Nat.lt_or_gt_of_ne (Ne.symm (hne x))
      rcases hlt_or with hlt | hgt
      · have hnot : ¬ (x ^^^ a < x) := by omega
        cases P x <;> simp [hlt, hnot]
      · have hnot : ¬ (x < x ^^^ a) := by omega
        cases P x <;> simp [hgt, hnot]
    have heq_halves :
        sumBits 4 (fun x => if P x && decide (x ^^^ a < x) then 1 else 0) =
        sumBits 4 (fun x => if P x && decide (x < x ^^^ a) then 1 else 0) := by
      rw [← sumBits_xor_shift 4 a _ ha_lt]
      apply sumBits_congr; intro x _
      have hinv : (x ^^^ a) ^^^ a = x := by rw [Nat.xor_assoc, Nat.xor_self, Nat.xor_zero]
      rw [hPsym x, hinv]
    change (sumBits 4 (fun x => if P x then 1 else 0)) % 2 = 0
    rw [hsplit, heq_halves]
    omega
  rw [h2] at h1
  omega

/-- **T2e.1 (Universal 3-Hyperplane Parity Contradiction):**
    Any Boolean `f` on `𝔽₂⁴` admitting a zero-sum triple `(a, b, a ⊕ b)` with
    `|E_a| = |E_b| = |E_{a⊕b}| = 8` forbids ANY lift `h` satisfying `|z4RealExpect4 f h d| = 4`. -/
theorem three_hyperplane_parity_contradiction (f h : Nat → Bool) (a b : Nat)
    (ha_pos : 0 < a) (ha_lt : a < 16)
    (hb_pos : 0 < b) (hb_lt : b < 16)
    (hc_pos : 0 < a ^^^ b)
    (htriple : ∀ x, x < 16 → xor (xor (inEa f a x) (inEa f b x)) (inEa f (a ^^^ b) x) = false)
    (hsz_a : sumBits 4 (fun x => if inEa f a x then 1 else 0) = 8)
    (hsz_b : sumBits 4 (fun x => if inEa f b x then 1 else 0) = 8)
    (hsz_c : sumBits 4 (fun x => if inEa f (a ^^^ b) x then 1 else 0) = 8)
    (hma : z4RealExpect4 f h a = 4 ∨ z4RealExpect4 f h a = -4)
    (hmb : z4RealExpect4 f h b = 4 ∨ z4RealExpect4 f h b = -4)
    (hmc : z4RealExpect4 f h (a ^^^ b) = 4 ∨ z4RealExpect4 f h (a ^^^ b) = -4) : False := by
  have hc_lt : a ^^^ b < 16 := Nat.xor_lt_two_pow (n := 4) ha_lt hb_lt
  have hpa := z4_expect4_forces_odd_parity f h a ha_pos ha_lt hsz_a hma
  have hpb := z4_expect4_forces_odd_parity f h b hb_pos hb_lt hsz_b hmb
  have hpc := z4_expect4_forces_odd_parity f h (a ^^^ b) hc_pos hc_lt hsz_c hmc
  have hsum_even : (eaParity f h a + eaParity f h b + eaParity f h (a ^^^ b)) % 2 = 0 := by
    unfold eaParity
    rw [← sumBits_add, ← sumBits_add]
    have hpt : ∀ x, x < 16 →
        ((if inEa f a x && h x then (1 : Int) else 0) +
         (if inEa f b x && h x then (1 : Int) else 0) +
         (if inEa f (a ^^^ b) x && h x then (1 : Int) else 0)) =
        2 * (if h x && ((inEa f a x && inEa f b x) || (inEa f a x && inEa f (a ^^^ b) x) ||
                         (inEa f b x && inEa f (a ^^^ b) x)) then 1 else 0) := by
      intro x hx
      have ht := htriple x hx
      cases ha1 : inEa f a x <;> cases hb1 : inEa f b x <;> cases hc1 : inEa f (a ^^^ b) x <;>
        cases h x <;> simp [ha1, hb1, hc1] at ht ⊢
    rw [sumBits_congr 4 _ _ hpt, sumBits_mul_left]
    omega
  omega

/-- **T2e.2 (Complete `n = 4` Rupture Over ALL 896 Bent Functions & ALL `h : 𝔽₂⁴ → 𝔽₂`):**
    For EVERY bent quadratic mask `qMask < 64`, EVERY affine shift `(lin, c0)`, and
    EVERY lift `h : Nat → Bool`, NO `ℤ₄` phase state `u_x = i^(f(x) + 2*h(x))` satisfies
    `|z4RealExpect4 f h d| = 4` for all nonzero `d < 16`. -/
theorem n4_z4_bent_hyperplane_rupture (qMask lin : Nat) (c0 : Bool)
    (hq_lt : qMask < 64)
    (hbent : isBent4Bool (quad4Eval qMask) = true)
    (h : Nat → Bool)
    (hall : ∀ d, 0 < d → d < 16 →
      z4RealExpect4 (deg2Eval4 qMask lin c0) h d = 4 ∨
      z4RealExpect4 (deg2Eval4 qMask lin c0) h d = -4) : False := by
  have hcheck :
      ((List.range 64).all fun q =>
        !isBent4Bool (quad4Eval q) ||
        (((List.range 15).all fun d0 =>
            sumBits 4 (fun x => if inEa (quad4Eval q) (d0 + 1) x then 1 else 0) == 8) &&
         hasZeroTripleQuad4 q)) = true := by
    decide
  have hmem : qMask ∈ List.range 64 := List.mem_range.mpr hq_lt
  have hq := (List.all_eq_true.mp hcheck) qMask hmem
  simp only [hbent, Bool.not_true, Bool.false_or, Bool.and_eq_true] at hq
  rcases hq with ⟨hsz_all, htr⟩
  unfold hasZeroTripleQuad4 at htr
  rcases List.any_eq_true.mp htr with ⟨a0, ha0_mem, htr_b⟩
  rcases List.any_eq_true.mp htr_b with ⟨b0, hb0_mem, htr_c⟩
  have ha0_lt : a0 < 15 := List.mem_range.mp ha0_mem
  have hb0_lt : b0 < 15 := List.mem_range.mp hb0_mem
  let a := a0 + 1
  let b := b0 + 1
  have htr_c' : ((a ^^^ b != 0) &&
      (List.range 16).all fun x =>
        xor (xor (inEa (quad4Eval qMask) a x) (inEa (quad4Eval qMask) b x))
            (inEa (quad4Eval qMask) (a ^^^ b) x) == false) = true := htr_c
  simp only [Bool.and_eq_true, bne_iff_ne, ne_eq] at htr_c'
  rcases htr_c' with ⟨hc_ne, htr_x⟩
  have ha_pos : 0 < a := by omega
  have ha_lt : a < 16 := by omega
  have hb_pos : 0 < b := by omega
  have hb_lt : b < 16 := by omega
  have hc_pos : 0 < a ^^^ b := by omega
  have hc_lt : a ^^^ b < 16 := Nat.xor_lt_two_pow (n := 4) ha_lt hb_lt
  have hsz_shift : ∀ d, 0 < d → d < 16 →
      sumBits 4 (fun x => if inEa (deg2Eval4 qMask lin c0) d x then 1 else 0) = 8 := by
    intro d hd_pos hd_lt
    have hq_sz := (List.all_eq_true.mp hsz_all) (d - 1) (List.mem_range.mpr (by omega))
    have hd1 : d - 1 + 1 = d := by omega
    rw [hd1, beq_iff_eq] at hq_sz
    have hrel : ∀ x, inEa (deg2Eval4 qMask lin c0) d x =
        xor (inEa (quad4Eval qMask) d x) (dotMod2 4 lin d) := by
      intro x
      simp only [deg2Eval4, inEa, dotMod2_xor_right]
      cases quad4Eval qMask x <;> cases quad4Eval qMask (x ^^^ d) <;>
        cases dotMod2 4 lin x <;> cases dotMod2 4 lin d <;> cases c0 <;> rfl
    cases hld : dotMod2 4 lin d
    · rw [sumBits_congr 4 _ (fun x => if inEa (quad4Eval qMask) d x then 1 else 0)
        (fun x _ => by rw [hrel x, hld]; simp)]
      exact hq_sz
    · have hcomp : sumBits 4 (fun x => if inEa (deg2Eval4 qMask lin c0) d x then 1 else 0) +
          sumBits 4 (fun x => if inEa (quad4Eval qMask) d x then 1 else 0) = 16 := by
        rw [← sumBits_add]
        have h1 : sumBits 4 (fun x => (if inEa (deg2Eval4 qMask lin c0) d x then (1 : Int) else 0) +
            (if inEa (quad4Eval qMask) d x then 1 else 0)) = sumBits 4 (fun _ => 1) := by
          apply sumBits_congr; intro x _
          rw [hrel x, hld]
          cases inEa (quad4Eval qMask) d x <;> decide
        rw [h1, sumBits_const]; decide
      omega
  apply three_hyperplane_parity_contradiction (deg2Eval4 qMask lin c0) h a b
    ha_pos ha_lt hb_pos hb_lt hc_pos
  · intro x hx
    have hbase := (List.all_eq_true.mp htr_x) x (List.mem_range.mpr hx)
    rw [beq_iff_eq] at hbase
    have hinv := triple_indicator_affine_invariant (quad4Eval qMask) lin c0 a b x
    exact hinv.trans hbase
  · exact hsz_shift a ha_pos ha_lt
  · exact hsz_shift b hb_pos hb_lt
  · exact hsz_shift (a ^^^ b) hc_pos hc_lt
  · exact hall a ha_pos ha_lt
  · exact hall b hb_pos hb_lt
  · exact hall (a ^^^ b) hc_pos hc_lt

/-! ### Kernel Bridge: Direct `IsBent 2 f → False` (Closing `T2c → T2d → T2e` Inside Lean) -/

/-- Boolean ANF coefficient of monomial `M` in `f` on `𝔽₂⁴`. -/
def anfBit4 (f : Nat → Bool) (M : Nat) : Bool :=
  (anfSum 4 f M) % 2 == 1

/-- Extracts the 4-bit linear ANF mask of `f : 𝔽₂⁴ → Bool`. -/
def extractLin4 (f : Nat → Bool) : Nat :=
  (if anfBit4 f 1 then 1 else 0) +
  (if anfBit4 f 2 then 2 else 0) +
  (if anfBit4 f 4 then 4 else 0) +
  (if anfBit4 f 8 then 8 else 0)

/-- Extracts the 6-bit homogeneous quadratic ANF mask of `f : 𝔽₂⁴ → Bool`. -/
def extractQuad4 (f : Nat → Bool) : Nat :=
  (if anfBit4 f 3  then 1  else 0) +
  (if anfBit4 f 5  then 2  else 0) +
  (if anfBit4 f 9  then 4  else 0) +
  (if anfBit4 f 6  then 8  else 0) +
  (if anfBit4 f 10 then 16 else 0) +
  (if anfBit4 f 12 then 32 else 0)

private def b2i (b : Bool) : Int :=
  if b then 1 else 0

private theorem b2i_xor_eq (a b : Bool) :
    b2i (xor a b) = (b2i a + b2i b) % 2 := by
  cases a <;> cases b <;> decide

private theorem b2i_eq_of_mod2 (a b : Bool) (h : b2i a % 2 = b2i b % 2) : a = b := by
  cases a <;> cases b <;> simp [b2i] at h ⊢

private theorem b2i_anfBit4_eq (f : Nat → Bool) (M : Nat) :
    b2i (anfBit4 f M) = (anfSum 4 f M) % 2 := by
  unfold anfBit4 b2i
  have h01 : (anfSum 4 f M) % 2 = 0 ∨ (anfSum 4 f M) % 2 = 1 := by omega
  rcases h01 with h0 | h1
  · simp [h0]
  · simp [h1]

private theorem extractQuad4_lt_64 (f : Nat → Bool) : extractQuad4 f < 64 := by
  unfold extractQuad4
  cases anfBit4 f 3 <;> cases anfBit4 f 5 <;> cases anfBit4 f 9 <;>
    cases anfBit4 f 6 <;> cases anfBit4 f 10 <;> cases anfBit4 f 12 <;> decide

private theorem extractLin4_lt_16 (f : Nat → Bool) : extractLin4 f < 16 := by
  unfold extractLin4
  cases anfBit4 f 1 <;> cases anfBit4 f 2 <;> cases anfBit4 f 4 <;> cases anfBit4 f 8 <;> decide

private theorem extractQuad4_bits (f : Nat → Bool) :
    ((extractQuad4 f &&& 1) == 1) = anfBit4 f 3 ∧
    (((extractQuad4 f >>> 1) &&& 1) == 1) = anfBit4 f 5 ∧
    (((extractQuad4 f >>> 2) &&& 1) == 1) = anfBit4 f 9 ∧
    (((extractQuad4 f >>> 3) &&& 1) == 1) = anfBit4 f 6 ∧
    (((extractQuad4 f >>> 4) &&& 1) == 1) = anfBit4 f 10 ∧
    (((extractQuad4 f >>> 5) &&& 1) == 1) = anfBit4 f 12 := by
  unfold extractQuad4
  cases anfBit4 f 3 <;> cases anfBit4 f 5 <;> cases anfBit4 f 9 <;>
    cases anfBit4 f 6 <;> cases anfBit4 f 10 <;> cases anfBit4 f 12 <;> decide

private theorem extractLin4_bits (f : Nat → Bool) :
    ((extractLin4 f &&& 1) == 1) = anfBit4 f 1 ∧
    (((extractLin4 f >>> 1) &&& 1) == 1) = anfBit4 f 2 ∧
    (((extractLin4 f >>> 2) &&& 1) == 1) = anfBit4 f 4 ∧
    (((extractLin4 f >>> 3) &&& 1) == 1) = anfBit4 f 8 := by
  unfold extractLin4
  cases anfBit4 f 1 <;> cases anfBit4 f 2 <;> cases anfBit4 f 4 <;> cases anfBit4 f 8 <;> decide

private theorem dotMod2_4_eq (l x : Nat) (hl : l < 16) (hx : x < 16) :
    dotMod2 4 l x =
      xor (xor (((l &&& 1) == 1) && ((x &&& 1) == 1))
               ((((l >>> 1) &&& 1) == 1) && (((x >>> 1) &&& 1) == 1)))
          (xor ((((l >>> 2) &&& 1) == 1) && (((x >>> 2) &&& 1) == 1))
               ((((l >>> 3) &&& 1) == 1) && (((x >>> 3) &&& 1) == 1))) := by
  have hcheck :
      ((List.range 16).all fun a =>
        (List.range 16).all fun b =>
          dotMod2 4 a b ==
            xor (xor (((a &&& 1) == 1) && ((b &&& 1) == 1))
                     ((((a >>> 1) &&& 1) == 1) && (((b >>> 1) &&& 1) == 1)))
                (xor ((((a >>> 2) &&& 1) == 1) && (((b >>> 2) &&& 1) == 1))
                     ((((a >>> 3) &&& 1) == 1) && (((b >>> 3) &&& 1) == 1)))) = true := by
    decide
  have h1 := (List.all_eq_true.mp hcheck) l (List.mem_range.mpr hl)
  have h2 := (List.all_eq_true.mp h1) x (List.mem_range.mpr hx)
  exact beq_iff_eq.mp h2

private theorem deg2Eval4_eq_of_high_anf_zero (f : Nat → Bool)
    (h7  : anfSum 4 f 7  % 2 = 0)
    (h11 : anfSum 4 f 11 % 2 = 0)
    (h13 : anfSum 4 f 13 % 2 = 0)
    (h14 : anfSum 4 f 14 % 2 = 0)
    (h15 : anfSum 4 f 15 % 2 = 0) :
    ∀ x, x < 16 → f x = deg2Eval4 (extractQuad4 f) (extractLin4 f) (f 0) x := by
  obtain ⟨hq0, hq1, hq2, hq3, hq4, hq5⟩ := extractQuad4_bits f
  obtain ⟨hl0, hl1, hl2, hl3⟩ := extractLin4_bits f
  have hl_lt : extractLin4 f < 16 := extractLin4_lt_16 f
  have ha0 : ∀ M, b2i (anfBit4 f M) = anfSum 4 f M % 2 := b2i_anfBit4_eq f
  intro x hx
  apply b2i_eq_of_mod2
  rw [deg2Eval4, dotMod2_4_eq (extractLin4 f) x hl_lt hx]
  dsimp only [quad4Eval]
  rw [hq0, hq1, hq2, hq3, hq4, hq5, hl0, hl1, hl2, hl3]
  have hx' : x = 0 ∨ x = 1 ∨ x = 2 ∨ x = 3 ∨ x = 4 ∨ x = 5 ∨ x = 6 ∨ x = 7 ∨
             x = 8 ∨ x = 9 ∨ x = 10 ∨ x = 11 ∨ x = 12 ∨ x = 13 ∨ x = 14 ∨ x = 15 := by omega
  rcases hx' with rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl |
                  rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl
  · simp [b2i]
  all_goals
    · simp [b2i_xor_eq, ha0]
      simp [anfSum, sumSubcube, sumBits, b2i] at h7 h11 h13 h14 h15 ⊢
      omega

private theorem walsh_deg2Eval4_shift (qMask lin : Nat) (c0 : Bool) (u : Nat) :
    walshTransform 4 (deg2Eval4 qMask lin c0) (u ^^^ lin) =
      paritySign c0 * walshTransform 4 (quad4Eval qMask) u := by
  unfold walshTransform
  rw [← sumBits_mul_left]
  apply sumBits_congr
  intro x _
  rw [← paritySign_xor]
  congr 1
  simp only [deg2Eval4, dotMod2_xor_left]
  cases quad4Eval qMask x <;> cases dotMod2 4 lin x <;> cases c0 <;> cases dotMod2 4 u x <;> rfl

/-- **T2e.3 (Unconditional Arbitrary-Bent `n = 4` Rupture Bridge):**
    Directly combines Rothaus's universal degree bound (`T2c`) with the exhaustive 28-form
    hyperplane-triple classification (`T2d`) and parity contradiction (`T2e`) INSIDE the
    Lean 4 kernel: for EVERY arbitrary Boolean function `f : Nat → Bool` satisfying `IsBent 2 f`
    and EVERY lift `h : Nat → Bool`, NO `ℤ₄` phase state satisfies `|z4RealExpect4 f h d| = 4`
    for all nonzero `d < 16`. -/
theorem n4_z4_bent_hyperplane_rupture_arbitrary_bent (f h : Nat → Bool)
    (hbent : IsBent 2 f)
    (hall : ∀ d, 0 < d → d < 16 →
      z4RealExpect4 f h d = 4 ∨ z4RealExpect4 f h d = -4) : False := by
  have h7  : anfSum 4 f 7  % 2 = 0 := rothaus_degree_bound_all_m 2 (by omega) f hbent 7  (by decide)
  have h11 : anfSum 4 f 11 % 2 = 0 := rothaus_degree_bound_all_m 2 (by omega) f hbent 11 (by decide)
  have h13 : anfSum 4 f 13 % 2 = 0 := rothaus_degree_bound_all_m 2 (by omega) f hbent 13 (by decide)
  have h14 : anfSum 4 f 14 % 2 = 0 := rothaus_degree_bound_all_m 2 (by omega) f hbent 14 (by decide)
  have h15 : anfSum 4 f 15 % 2 = 0 := rothaus_degree_bound_all_m 2 (by omega) f hbent 15 (by decide)
  let q := extractQuad4 f
  let l := extractLin4 f
  let c0 := f 0
  have hfg : ∀ x, x < 16 → f x = deg2Eval4 q l c0 x :=
    deg2Eval4_eq_of_high_anf_zero f h7 h11 h13 h14 h15
  have hq_lt : q < 64 := extractQuad4_lt_64 f
  have hl_lt : l < 16 := extractLin4_lt_16 f
  have hbent_q : isBent4Bool (quad4Eval q) = true := by
    unfold isBent4Bool
    rw [List.all_eq_true]
    intro u hu
    have hu_lt : u < 16 := List.mem_range.mp hu
    have hul_lt : u ^^^ l < 16 := Nat.xor_lt_two_pow (n := 4) hu_lt hl_lt
    have hwf := hbent (u ^^^ l) hul_lt
    have hcongr : walshTransform 4 f (u ^^^ l) = walshTransform 4 (deg2Eval4 q l c0) (u ^^^ l) := by
      unfold walshTransform
      apply sumBits_congr
      intro x hx
      rw [hfg x hx]
    rw [hcongr, walsh_deg2Eval4_shift q l c0 u] at hwf
    have h22 : ((2 : Int) ^ 2) = 4 := by decide
    rw [h22] at hwf
    simp only [Bool.or_eq_true, beq_iff_eq]
    rcases hwf with hpos | hneg
    · rcases Bool.eq_false_or_eq_true c0 with hc0 | hc0
      · rw [hc0] at hpos; simp [paritySign] at hpos; right; omega
      · rw [hc0] at hpos; simp [paritySign] at hpos; left; exact hpos
    · rcases Bool.eq_false_or_eq_true c0 with hc0 | hc0
      · rw [hc0] at hneg; simp [paritySign] at hneg; left; omega
      · rw [hc0] at hneg; simp [paritySign] at hneg; right; exact hneg
  have hall_g : ∀ d, 0 < d → d < 16 →
      z4RealExpect4 (deg2Eval4 q l c0) h d = 4 ∨
      z4RealExpect4 (deg2Eval4 q l c0) h d = -4 := by
    intro d hd_pos hd_lt
    have hcongr : z4RealExpect4 (deg2Eval4 q l c0) h d = z4RealExpect4 f h d := by
      unfold z4RealExpect4
      apply sumBits_congr
      intro x hx
      have hxd : x ^^^ d < 16 := Nat.xor_lt_two_pow (n := 4) hx hd_lt
      simp only [inEa, ← hfg x hx, ← hfg (x ^^^ d) hxd]
      rfl
    rw [hcongr]
    exact hall d hd_pos hd_lt
  exact n4_z4_bent_hyperplane_rupture q l c0 hq_lt hbent_q h hall_g

end

end WeylMagic
