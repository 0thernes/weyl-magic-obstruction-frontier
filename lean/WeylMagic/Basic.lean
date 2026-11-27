module
-- SPDX-License-Identifier: Apache-2.0
-- Copyright (c) 2026 Alexander Stephen Donahue

/-!
# Core Algebraic Primitives (`WeylMagic.Basic`)

Zero-Mathlib exact integer, bitwise symplectic, Gaussian-integer (`ℤ[i]`),
and 8th-cyclotomic (`ℤ[ζ₈]`) primitives used across all five pillars of the
Weyl–Heisenberg Magic Obstruction Frontier.
-/

namespace WeylMagic

@[expose] public section

/-! ### Bitwise Dot Product, Symplectic Form, and Pauli Multiplication Signs -/

/-- Bitwise inner product `a · b (mod 2)` over `n` bits. -/
def dotMod2 : Nat → Nat → Nat → Bool
  | 0, _, _ => false
  | k + 1, a, b => xor (((a &&& b) &&& 1) == 1) (dotMod2 k (a >>> 1) (b >>> 1))

/-- Sign `(-1)^(dotMod2 n a b)` as an integer in `{1, -1}`. -/
def paritySign (b : Bool) : Int :=
  if b then -1 else 1

/-- Standard symplectic form `ω((a₁,b₁), (a₂,b₂)) = a₁·b₂ ⊕ b₁·a₂ (mod 2)`. -/
def sympForm (n a1 b1 a2 b2 : Nat) : Bool :=
  xor (dotMod2 n a1 b2) (dotMod2 n b1 a2)

/-- Count of shared set bits `popcount(x)` in the lowest `n` bits. -/
def popcount : Nat → Nat → Nat
  | 0, _ => 0
  | k + 1, x => (x &&& 1) + popcount k (x >>> 1)

/-- Phase exponent `(mod 4)` for multiplying two Hermitian `n`-qubit Pauli operators
    `P(a₁, b₁) = i^(a₁·b₁) X^{a₁} Z^{b₁}` and `P(a₂, b₂) = i^(a₂·b₂) X^{a₂} Z^{b₂}`:
    `P(a₁,b₁) P(a₂,b₂) = i^(e) P(a₁⊕a₂, b₁⊕b₂)` where
    `e ≡ pop(a₁&b₁) + pop(a₂&b₂) - pop((a₁⊕a₂)&(b₁⊕b₂)) + 2*pop(b₁&a₂) (mod 4)`.
    When `sympForm n a1 b1 a2 b2 = false` (commuting pair), `e` is even and
    `i^e ∈ {+1, -1}`. -/
def pauliPhaseExp4 (n a1 b1 a2 b2 : Nat) : Nat :=
  let c1 := popcount n (a1 &&& b1)
  let c2 := popcount n (a2 &&& b2)
  let c3 := popcount n ((a1 ^^^ a2) &&& (b1 ^^^ b2))
  let sw := 2 * popcount n (b1 &&& a2)
  (c1 + c2 + sw + 3 * c3) % 4

/-- Real sign `σ(P₁, P₂) ∈ {+1, -1}` for commuting Hermitian `n`-qubit Paulis. -/
def pauliCommSign (n a1 b1 a2 b2 : Nat) : Int :=
  if pauliPhaseExp4 n a1 b1 a2 b2 == 2 then -1 else 1

/-! ### Exact Finite Sums Over `0, ..., N-1` -/

/-- Exact integer sum `∑_{k=0}^{N-1} f k`. -/
def sumRange : Nat → (Nat → Int) → Int
  | 0, _ => 0
  | k + 1, f => sumRange k f + f k

theorem sumRange_add (N : Nat) (f g : Nat → Int) :
    sumRange N (fun k => f k + g k) = sumRange N f + sumRange N g := by
  induction N with
  | zero => rfl
  | succ k ih =>
    simp only [sumRange, ih]
    omega

theorem sumRange_mul_left (N : Nat) (c : Int) (f : Nat → Int) :
    sumRange N (fun k => c * f k) = c * sumRange N f := by
  induction N with
  | zero => simp [sumRange]
  | succ k ih =>
    simp only [sumRange, ih, Int.mul_add]

theorem sumRange_zero (N : Nat) : sumRange N (fun _ => 0) = 0 := by
  induction N with
  | zero => rfl
  | succ k ih => simp [sumRange, ih]

theorem sumRange_congr (N : Nat) (f g : Nat → Int)
    (h : ∀ k, k < N → f k = g k) : sumRange N f = sumRange N g := by
  induction N with
  | zero => rfl
  | succ k ih =>
    simp only [sumRange]
    rw [ih (fun j hj => h j (Nat.lt_succ_of_lt hj)), h k (Nat.lt_succ_self k)]

theorem sumRange_nonneg (N : Nat) (f : Nat → Int)
    (h : ∀ k, k < N → 0 ≤ f k) : 0 ≤ sumRange N f := by
  induction N with
  | zero => exact Int.le_refl 0
  | succ k ih =>
    simp only [sumRange]
    have h1 := ih (fun j hj => h j (Nat.lt_succ_of_lt hj))
    have h2 := h k (Nat.lt_succ_self k)
    omega

theorem sumRange_const (N : Nat) (c : Int) : sumRange N (fun _ => c) = (N : Int) * c := by
  induction N with
  | zero => simp [sumRange]
  | succ k ih =>
    simp only [sumRange, ih]
    have hnat : ((k + 1 : Nat) : Int) = (k : Int) + 1 := by omega
    rw [hnat, Int.add_mul, Int.one_mul]

/-- Every integer square is non-negative. -/
theorem int_sq_nonneg (x : Int) : 0 ≤ x * x := by
  rcases Int.le_total 0 x with hx | hx
  · exact Int.mul_nonneg hx hx
  · have hneg : 0 ≤ -x := by omega
    have heq : x * x = (-x) * (-x) := by rw [Int.neg_mul_neg]
    rw [heq]
    exact Int.mul_nonneg hneg hneg

/-- Exact discrete Cauchy–Schwarz inequality over `Int`:
    `(∑_{i=0}^{N-1} f i)^2 ≤ N * ∑_{i=0}^{N-1} (f i)^2`. -/
theorem sumRange_cauchy_schwarz (N : Nat) (f : Nat → Int) :
    (sumRange N f) * (sumRange N f) ≤ (N : Int) * sumRange N (fun i => f i * f i) := by
  have hdouble :
      0 ≤ sumRange N (fun i => sumRange N (fun j => (f i - f j) * (f i - f j))) := by
    apply sumRange_nonneg
    intro i _
    apply sumRange_nonneg
    intro j _
    exact int_sq_nonneg (f i - f j)
  have hexpand :
      sumRange N (fun i => sumRange N (fun j => (f i - f j) * (f i - f j))) =
        2 * ((N : Int) * sumRange N (fun i => f i * f i) - sumRange N f * sumRange N f) := by
    have hinner : ∀ i,
        sumRange N (fun j => (f i - f j) * (f i - f j)) =
          (N : Int) * (f i * f i) + sumRange N (fun j => f j * f j) - 2 * (f i * sumRange N f) := by
      intro i
      have hsq : ∀ j, (f i - f j) * (f i - f j) =
          (f i * f i + f j * f j) + (-(2 * f i)) * f j := by
        intro j
        have h1 : (f i - f j) * (f i - f j) = f i * f i - f i * f j - f i * f j + f j * f j := by
          rw [Int.sub_mul, Int.mul_sub, Int.mul_sub, Int.mul_comm (f j) (f i)]
          omega
        have h2 : (-(2 * f i)) * f j = -(2 * (f i * f j)) := by
          rw [Int.neg_mul, Int.mul_assoc]
        rw [h1, h2]
        omega
      rw [sumRange_congr N _ _ (fun j _ => hsq j)]
      rw [sumRange_add, sumRange_add, sumRange_const, sumRange_mul_left]
      rw [Int.neg_mul, Int.mul_assoc]
      omega
    rw [sumRange_congr N _ _ (fun i _ => hinner i)]
    have hstep : ∀ i,
        (N : Int) * (f i * f i) + sumRange N (fun j => f j * f j) - 2 * (f i * sumRange N f) =
          ((N : Int) * (f i * f i) + sumRange N (fun j => f j * f j)) + (-(2 * sumRange N f)) * f i := by
      intro i
      rw [Int.neg_mul, Int.mul_assoc, Int.mul_comm (sumRange N f) (f i)]
      omega
    rw [sumRange_congr N _ _ (fun i _ => hstep i)]
    rw [sumRange_add, sumRange_add, sumRange_mul_left, sumRange_const, sumRange_mul_left]
    rw [Int.neg_mul, Int.mul_assoc]
    omega
  rw [hexpand] at hdouble
  omega

/-! ### Exact Gaussian Integers `ℤ[i]` -/

/-- Exact Gaussian integer `re + im * i ∈ ℤ[i]`. -/
structure GaussInt where
  re : Int
  im : Int
  deriving DecidableEq, Repr

namespace GaussInt

def zero : GaussInt := ⟨0, 0⟩
def one : GaussInt := ⟨1, 0⟩
def I : GaussInt := ⟨0, 1⟩

def add (x y : GaussInt) : GaussInt := ⟨x.re + y.re, x.im + y.im⟩
def sub (x y : GaussInt) : GaussInt := ⟨x.re - y.re, x.im - y.im⟩
def neg (x : GaussInt) : GaussInt := ⟨-x.re, -x.im⟩
def conj (x : GaussInt) : GaussInt := ⟨x.re, -x.im⟩
def mul (x y : GaussInt) : GaussInt :=
  ⟨x.re * y.re - x.im * y.im, x.re * y.im + x.im * y.re⟩
def normSq (x : GaussInt) : Int := x.re * x.re + x.im * x.im

/-- Multiply by `i^q` for `q ∈ {0, 1, 2, 3}` (mod 4). -/
def mulPowI (x : GaussInt) (q : Nat) : GaussInt :=
  match q % 4 with
  | 0 => x
  | 1 => ⟨-x.im, x.re⟩
  | 2 => ⟨-x.re, -x.im⟩
  | _ => ⟨x.im, -x.re⟩

end GaussInt

/-! ### Exact Cyclotomic Ring `ℤ[ζ₈] = ℤ[z]/(z⁴ + 1)` -/

/-- Exact element `c0 + c1*ζ₈ + c2*ζ₈² + c3*ζ₈³ ∈ ℤ[ζ₈]` where `ζ₈ = e^{iπ/4}`, `ζ₈⁴ = -1`,
    `ζ₈² = i`, and `√2 = ζ₈ - ζ₈³`. -/
structure Zeta8 where
  c0 : Int
  c1 : Int
  c2 : Int
  c3 : Int
  deriving DecidableEq, Repr

namespace Zeta8

def zero : Zeta8 := ⟨0, 0, 0, 0⟩
def one : Zeta8 := ⟨1, 0, 0, 0⟩
def z : Zeta8 := ⟨0, 1, 0, 0⟩
def I : Zeta8 := ⟨0, 0, 1, 0⟩
def sqrt2 : Zeta8 := ⟨0, 1, 0, -1⟩

def ofGauss (a b : Int) : Zeta8 := ⟨a, 0, b, 0⟩
def add (x y : Zeta8) : Zeta8 := ⟨x.c0 + y.c0, x.c1 + y.c1, x.c2 + y.c2, x.c3 + y.c3⟩
def neg (x : Zeta8) : Zeta8 := ⟨-x.c0, -x.c1, -x.c2, -x.c3⟩

/-- Complex conjugation on `ℤ[ζ₈]`: `conj(ζ₈) = -ζ₈³`, `conj(ζ₈²) = -ζ₈²`, `conj(ζ₈³) = -ζ₈`. -/
def conj (x : Zeta8) : Zeta8 := ⟨x.c0, -x.c3, -x.c2, -x.c1⟩

/-- Exact product modulo `z⁴ + 1 = 0`. -/
def mul (x y : Zeta8) : Zeta8 :=
  ⟨x.c0 * y.c0 - x.c1 * y.c3 - x.c2 * y.c2 - x.c3 * y.c1,
   x.c0 * y.c1 + x.c1 * y.c0 - x.c2 * y.c3 - x.c3 * y.c2,
   x.c0 * y.c2 + x.c1 * y.c1 + x.c2 * y.c0 - x.c3 * y.c3,
   x.c0 * y.c3 + x.c1 * y.c2 + x.c2 * y.c1 + x.c3 * y.c0⟩

/-- Multiply by `i^q = ζ₈^(2q)` for `q mod 4`. -/
def mulPowI (x : Zeta8) (q : Nat) : Zeta8 :=
  match q % 4 with
  | 0 => x
  | 1 => ⟨-x.c2, -x.c3, x.c0, x.c1⟩
  | 2 => ⟨-x.c0, -x.c1, -x.c2, -x.c3⟩
  | _ => ⟨x.c2, x.c3, -x.c0, -x.c1⟩

/-- Squared modulus `x * conj(x) = r0 + r1 * √2 ∈ ℤ[√2]`.
    Returns `(r0, r1)` where `c2 = 0` and `c3 = -c1` identically. -/
def normSqPair (x : Zeta8) : Int × Int :=
  let p := mul x (conj x)
  (p.c0, p.c1)

end Zeta8

end

end WeylMagic
