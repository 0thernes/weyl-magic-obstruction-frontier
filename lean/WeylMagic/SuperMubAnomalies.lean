module
-- SPDX-License-Identifier: Apache-2.0
-- Copyright (c) 2026 Alexander Stephen Donahue

public import WeylMagic.Basic

/-!
# Pillar 3: Non-Flat 2-Torsion WH-MUB Fiducials, Super-MUB Counterexamples, and the `α`-Phase Transition

Certifies exact cyclotomic (`ℤ[ζ₈]`) WH-MUB fiducials AND exact Gaussian-integer (`ℤ[i]`)
Super-MUB counterexamples across the mixed 2-torsion product Weyl–Heisenberg groups
`W(4) ⊗ W(2)` (`D = 8`) and `W(4) ⊗ W(4)` (`D = 16`):

1. **T3a (`w42_z8_mub_fiducial_exact`):** Exact `ψ₄₂ ∈ ℤ[ζ₈]⁸` (`‖ψ₄₂‖² = 8`) achieves the
   exact `W(4) ⊗ W(2)` WH-MUB spectrum (`1` of `64`, `7` of `0`, `56` of `8`), yielding
   `Φ₄ = 15/8`, `Φ₆ = 71/64`, `Φ₈ = 519/512`.
2. **T3b (`w44_z8_mub_fiducial_exact`):** Exact `ψ₄₄ ∈ ℤ[ζ₈]¹⁶` (`‖ψ₄₄‖² = 320`) achieves
   the exact `W(4) ⊗ W(4)` WH-MUB spectrum (`1` of `102400`, `15` of `0`, `240` of `6400`),
   yielding `Φ₄ = 31/16`, `Φ₆ = 271/256`, `Φ₈ = 4111/4096`.
3. **T3c (`w42_super_mub_alpha_transition`):** Exact `v₄₂ ∈ ℤ[i]⁸` (`‖v₄₂‖² = 1001`) strictly
   BEATS the `W(4) ⊗ W(2)` WH-MUB fiducial at BOTH `α = 2` (`Φ₄ < 15/8`) AND `α = 3`
   (`Φ₆ < 71/64`), then REVERSES at `α = 4` (`Φ₈ > 519/512`) — proving an exact Rényi-index
   `α`-crossover between `α = 3` and `α = 4`!
4. **T3d (`w44_super_mub_alpha_transition`):** Exact `v₄₄ ∈ ℤ[i]¹⁶` (`‖v₄₄‖² = 1596`) strictly
   BEATS the `W(4) ⊗ W(4)` WH-MUB fiducial at BOTH `α = 2` (`Φ₄ < 31/16`) AND `α = 3`
   (`Φ₆ < 271/256`), then REVERSES at `α = 4` (`Φ₈ > 4111/4096`)!
5. **T3e (`order16_magic_phase_hierarchy`):** Certifies the strict rational hierarchy separating
   the distinct `D = 16` abelian magic phases:
   `32/17 (ℤ₁₆ Zauner SIC) < Φ₄(v₄₄) (ℤ₄×ℤ₄ Super-MUB) < 31/16 (WH-MUB) < 21505201/10⁷ (ℤ₂⁴)`.
-/

namespace WeylMagic

@[expose] public section

/-! ### Exact Product Weyl–Heisenberg Expectation Evaluators for `W(4) ⊗ W(2)` & `W(4) ⊗ W(4)` -/

/-- Exact `ℤ[ζ₈]` expectation `⟨v | W_{4,2}(a, b) | v⟩` for `v : Nat → Zeta8`, `a, b < 8`.
    Indexing: `x = 2*x0 + x1` (`x0 ∈ ℤ₄, x1 ∈ ℤ₂`), shift `(a0, a1)`, phase `i^(b0*x0 + 2*b1*x1)`. -/
def w42ExpectZ8 (v : Nat → Zeta8) (a b : Nat) : Zeta8 :=
  let a0 := a / 2; let a1 := a % 2
  let b0 := b / 2; let b1 := b % 2
  let term (x : Nat) : Zeta8 :=
    let x0 := x / 2; let x1 := x % 2
    let xa := 2 * ((x0 + a0) % 4) + ((x1 + a1) % 2)
    let prod := Zeta8.mul (Zeta8.conj (v x)) (v xa)
    Zeta8.mulPowI prod (b0 * x0 + 2 * b1 * x1)
  Zeta8.add (Zeta8.add (Zeta8.add (term 0) (term 1)) (Zeta8.add (term 2) (term 3)))
            (Zeta8.add (Zeta8.add (term 4) (term 5)) (Zeta8.add (term 6) (term 7)))

/-- Exact `ℤ[ζ₈]` expectation `⟨v | W_{4,4}(a, b) | v⟩` for `v : Nat → Zeta8`, `a, b < 16`.
    Indexing: `x = 4*x0 + x1` (`x0, x1 ∈ ℤ₄`), shift `(a0, a1)`, phase `i^(b0*x0 + b1*x1)`. -/
def w44ExpectZ8 (v : Nat → Zeta8) (a b : Nat) : Zeta8 :=
  let a0 := a / 4; let a1 := a % 4
  let b0 := b / 4; let b1 := b % 4
  let term (x : Nat) : Zeta8 :=
    let x0 := x / 4; let x1 := x % 4
    let xa := 4 * ((x0 + a0) % 4) + ((x1 + a1) % 4)
    let prod := Zeta8.mul (Zeta8.conj (v x)) (v xa)
    Zeta8.mulPowI prod (b0 * x0 + b1 * x1)
  let s0 := Zeta8.add (Zeta8.add (term 0) (term 1)) (Zeta8.add (term 2) (term 3))
  let s1 := Zeta8.add (Zeta8.add (term 4) (term 5)) (Zeta8.add (term 6) (term 7))
  let s2 := Zeta8.add (Zeta8.add (term 8) (term 9)) (Zeta8.add (term 10) (term 11))
  let s3 := Zeta8.add (Zeta8.add (term 12) (term 13)) (Zeta8.add (term 14) (term 15))
  Zeta8.add (Zeta8.add s0 s1) (Zeta8.add s2 s3)

/-- Exact `ℤ[i]` expectation squared `|⟨v | W_{4,2}(a, b) | v⟩|²` for `v : Nat → GaussInt`. -/
def w42ExpectSqG (v : Nat → GaussInt) (a b : Nat) : Int :=
  let a0 := a / 2; let a1 := a % 2
  let b0 := b / 2; let b1 := b % 2
  let term (x : Nat) : GaussInt :=
    let x0 := x / 2; let x1 := x % 2
    let xa := 2 * ((x0 + a0) % 4) + ((x1 + a1) % 2)
    let prod := GaussInt.mul (GaussInt.conj (v x)) (v xa)
    GaussInt.mulPowI prod (b0 * x0 + 2 * b1 * x1)
  let s := GaussInt.add
    (GaussInt.add (GaussInt.add (term 0) (term 1)) (GaussInt.add (term 2) (term 3)))
    (GaussInt.add (GaussInt.add (term 4) (term 5)) (GaussInt.add (term 6) (term 7)))
  GaussInt.normSq s

/-- Exact `ℤ[i]` expectation squared `|⟨v | W_{4,4}(a, b) | v⟩|²` for `v : Nat → GaussInt`. -/
def w44ExpectSqG (v : Nat → GaussInt) (a b : Nat) : Int :=
  let a0 := a / 4; let a1 := a % 4
  let b0 := b / 4; let b1 := b % 4
  let term (x : Nat) : GaussInt :=
    let x0 := x / 4; let x1 := x % 4
    let xa := 4 * ((x0 + a0) % 4) + ((x1 + a1) % 4)
    let prod := GaussInt.mul (GaussInt.conj (v x)) (v xa)
    GaussInt.mulPowI prod (b0 * x0 + b1 * x1)
  let s0 := GaussInt.add (GaussInt.add (term 0) (term 1)) (GaussInt.add (term 2) (term 3))
  let s1 := GaussInt.add (GaussInt.add (term 4) (term 5)) (GaussInt.add (term 6) (term 7))
  let s2 := GaussInt.add (GaussInt.add (term 8) (term 9)) (GaussInt.add (term 10) (term 11))
  let s3 := GaussInt.add (GaussInt.add (term 12) (term 13)) (GaussInt.add (term 14) (term 15))
  GaussInt.normSq (GaussInt.add (GaussInt.add s0 s1) (GaussInt.add s2 s3))

/-! ### T3a: Exact `ℤ[ζ₈]⁸` WH-MUB Fiducial in `W(4) ⊗ W(2)` -/

/-- Exact non-flat 2-torsion WH-MUB fiducial `ψ₄₂ ∈ ℤ[ζ₈]⁸` (`‖ψ₄₂‖² = 8`). -/
def psi42Z8 : Nat → Zeta8
  | 0 => ⟨0, -1, 0, 0⟩
  | 1 => ⟨-1, 0, -1, 0⟩
  | 2 => ⟨1, 0, 0, 0⟩
  | 3 => ⟨0, 0, 0, 0⟩
  | 4 => ⟨0, 0, 0, -1⟩
  | 5 => ⟨0, 0, 0, 0⟩
  | 6 => ⟨0, 0, 1, 0⟩
  | _ => ⟨0, 1, 0, -1⟩

/-- Counts `(nId, nZero, nFlat, nOther)` of squared norms across all 64 operators of `W(4) ⊗ W(2)`. -/
def w42Z8SpectrumCounts (v : Nat → Zeta8) (idVal flatVal : Int) : Nat × Nat × Nat × Nat :=
  let rec loopA (a : Nat) (acc : Nat × Nat × Nat × Nat) : Nat × Nat × Nat × Nat :=
    match a with
    | 0 => acc
    | a' + 1 =>
      let rec loopB (b : Nat) (accB : Nat × Nat × Nat × Nat) : Nat × Nat × Nat × Nat :=
        match b with
        | 0 => accB
        | b' + 1 =>
          let (r0, r1) := Zeta8.normSqPair (w42ExpectZ8 v a' b')
          let (cI, cZ, cF, cO) := accB
          let next :=
            if r1 != 0 then (cI, cZ, cF, cO + 1)
            else if r0 == idVal then (cI + 1, cZ, cF, cO)
            else if r0 == 0 then (cI, cZ + 1, cF, cO)
            else if r0 == flatVal then (cI, cZ, cF + 1, cO)
            else (cI, cZ, cF, cO + 1)
          loopB b' next
      loopA a' (loopB 8 acc)
  loopA 8 (0, 0, 0, 0)

/-- **T3a:** `psi42Z8 ∈ ℤ[ζ₈]⁸` has exact squared norm `(8, 0)` and exact `W(4) ⊗ W(2)`
    WH-MUB spectrum: `1` entry of `64`, `7` entries of `0`, `56` entries of `8`, `0` others
    (giving exact `Φ₄ = 15/8`, `Φ₆ = 71/64`, `Φ₈ = 519/512`). -/
theorem w42_z8_mub_fiducial_exact :
    sumRange 8 (fun x => (Zeta8.normSqPair (psi42Z8 x)).1) = 8 ∧
    sumRange 8 (fun x => (Zeta8.normSqPair (psi42Z8 x)).2) = 0 ∧
    w42Z8SpectrumCounts psi42Z8 64 8 = (1, 7, 56, 0) := by
  decide

/-! ### T3b: Exact `ℤ[ζ₈]¹⁶` WH-MUB Fiducial in `W(4) ⊗ W(4)` -/

/-- Exact non-flat 2-torsion WH-MUB fiducial `ψ₄₄ ∈ ℤ[ζ₈]¹⁶` (`‖ψ₄₄‖² = 320`,
    stabilized by the non-cyclic 2-torsion subgroup `2(ℤ₄⁴) ≅ ℤ₂⁴`). -/
def psi44Z8 : Nat → Zeta8
  | 0  => ⟨3, 0, 1, 0⟩
  | 1  => ⟨-1, 0, 3, 0⟩
  | 2  => ⟨-3, 0, -1, 0⟩
  | 3  => ⟨-1, 0, 3, 0⟩
  | 4  => ⟨0, 3, 0, 1⟩
  | 5  => ⟨0, 1, 0, 7⟩
  | 6  => ⟨0, 3, 0, 1⟩
  | 7  => ⟨0, 3, 0, 1⟩
  | 8  => ⟨-3, 0, -1, 0⟩
  | 9  => ⟨-1, 0, 3, 0⟩
  | 10 => ⟨-1, 0, -7, 0⟩
  | 11 => ⟨-5, 0, -5, 0⟩
  | 12 => ⟨0, -3, 0, -1⟩
  | 13 => ⟨0, -3, 0, -1⟩
  | 14 => ⟨0, 5, 0, -5⟩
  | _  => ⟨0, 3, 0, 1⟩

/-- Counts `(nId, nZero, nFlat, nOther)` across one `a`-row (`b = 0..15`) of `W(4) ⊗ W(4)`. -/
def w44Z8RowCounts (v : Nat → Zeta8) (idVal flatVal : Int) (a : Nat) : Nat × Nat × Nat × Nat :=
  let step (b : Nat) (acc : Nat × Nat × Nat × Nat) : Nat × Nat × Nat × Nat :=
    let (r0, r1) := Zeta8.normSqPair (w44ExpectZ8 v a b)
    let (cI, cZ, cF, cO) := acc
    if r1 != 0 then (cI, cZ, cF, cO + 1)
    else if r0 == idVal then (cI + 1, cZ, cF, cO)
    else if r0 == 0 then (cI, cZ + 1, cF, cO)
    else if r0 == flatVal then (cI, cZ, cF + 1, cO)
    else (cI, cZ, cF, cO + 1)
  step 15 (step 14 (step 13 (step 12 (step 11 (step 10 (step 9 (step 8
    (step 7 (step 6 (step 5 (step 4 (step 3 (step 2 (step 1 (step 0 (0, 0, 0, 0))))))))))))))))

def addCount4 (x y : Nat × Nat × Nat × Nat) : Nat × Nat × Nat × Nat :=
  (x.1 + y.1, x.2.1 + y.2.1, x.2.2.1 + y.2.2.1, x.2.2.2 + y.2.2.2)

/-- Counts `(nId, nZero, nFlat, nOther)` across all 256 operators of `W(4) ⊗ W(4)` (shallow balanced tree). -/
def w44Z8SpectrumCounts (v : Nat → Zeta8) (idVal flatVal : Int) : Nat × Nat × Nat × Nat :=
  let r := w44Z8RowCounts v idVal flatVal
  addCount4
    (addCount4 (addCount4 (r 0) (r 1)) (addCount4 (r 2) (r 3)))
    (addCount4
      (addCount4 (addCount4 (r 4) (r 5)) (addCount4 (r 6) (r 7)))
      (addCount4
        (addCount4 (addCount4 (r 8) (r 9)) (addCount4 (r 10) (r 11)))
        (addCount4 (addCount4 (r 12) (r 13)) (addCount4 (r 14) (r 15)))))

/-- **T3b:** `psi44Z8 ∈ ℤ[ζ₈]¹⁶` has exact squared norm `(320, 0)` and exact `W(4) ⊗ W(4)`
    WH-MUB spectrum: `1` entry of `102400`, `15` entries of `0`, `240` entries of `6400`, `0` others
    (giving exact `Φ₄ = 31/16`, `Φ₆ = 271/256`, `Φ₈ = 4111/4096`). -/
theorem w44_z8_mub_fiducial_exact :
    sumRange 16 (fun x => (Zeta8.normSqPair (psi44Z8 x)).1) = 320 ∧
    sumRange 16 (fun x => (Zeta8.normSqPair (psi44Z8 x)).2) = 0 ∧
    w44Z8SpectrumCounts psi44Z8 102400 6400 = (1, 15, 240, 0) := by
  decide

/-! ### T3c & T3d: Exact `ℤ[i]` Super-MUB Witnesses & `α = 2, 3 → 4` Phase-Transition Reversal -/

/-- Exact `ℤ[i]⁸` Super-MUB counterexample for `W(4) ⊗ W(2)` (`‖v₄₂‖² = 1001`). -/
def v42SuperMub : Nat → GaussInt
  | 0 => ⟨-2, 5⟩
  | 1 => ⟨-2, 5⟩
  | 2 => ⟨-9, 9⟩
  | 3 => ⟨-9, -10⟩
  | 4 => ⟨-11, -4⟩
  | 5 => ⟨-11, -4⟩
  | 6 => ⟨-1, -18⟩
  | _ => ⟨0, 1⟩

/-- Exact `ℤ[i]¹⁶` Super-MUB counterexample for `W(4) ⊗ W(4)` (`‖v₄₄‖² = 1596`). -/
def v44SuperMub : Nat → GaussInt
  | 0  => ⟨9, -10⟩
  | 1  => ⟨-7, -1⟩
  | 2  => ⟨4, 4⟩
  | 3  => ⟨2, 15⟩
  | 4  => ⟨1, 1⟩
  | 5  => ⟨-7, 0⟩
  | 6  => ⟨2, -1⟩
  | 7  => ⟨5, 2⟩
  | 8  => ⟨14, -7⟩
  | 9  => ⟨-6, 14⟩
  | 10 => ⟨3, 6⟩
  | 11 => ⟨-5, -1⟩
  | 12 => ⟨-2, 1⟩
  | 13 => ⟨0, -16⟩
  | 14 => ⟨3, 4⟩
  | _  => ⟨-4, 13⟩

/-- Computes `(num4, num6, num8)` simultaneously in one pass over `W(4) ⊗ W(2)` (`64` ops). -/
def w42MomentsG (v : Nat → GaussInt) : Int × Int × Int :=
  let rec loopA (a : Nat) (acc : Int × Int × Int) : Int × Int × Int :=
    match a with
    | 0 => acc
    | a' + 1 =>
      let rec loopB (b : Nat) (accB : Int × Int × Int) : Int × Int × Int :=
        match b with
        | 0 => accB
        | b' + 1 =>
          let m := w42ExpectSqG v a' b'
          let m2 := m * m
          let m3 := m2 * m
          let m4 := m2 * m2
          let (s4, s6, s8) := accB
          loopB b' (s4 + m2, s6 + m3, s8 + m4)
      loopA a' (loopB 8 acc)
  loopA 8 (0, 0, 0)

/-- Computes `(num4, num6, num8)` over one `a`-row (`b = 0..15`) of `W(4) ⊗ W(4)`. -/
def w44RowMomentsG (v : Nat → GaussInt) (a : Nat) : Int × Int × Int :=
  let step (b : Nat) (acc : Int × Int × Int) : Int × Int × Int :=
    let m := w44ExpectSqG v a b
    let m2 := m * m
    let m3 := m2 * m
    let m4 := m2 * m2
    (acc.1 + m2, acc.2.1 + m3, acc.2.2 + m4)
  step 15 (step 14 (step 13 (step 12 (step 11 (step 10 (step 9 (step 8
    (step 7 (step 6 (step 5 (step 4 (step 3 (step 2 (step 1 (step 0 (0, 0, 0))))))))))))))))

def addMom3 (x y : Int × Int × Int) : Int × Int × Int :=
  (x.1 + y.1, x.2.1 + y.2.1, x.2.2 + y.2.2)

/-- Computes `(num4, num6, num8)` across all 256 operators of `W(4) ⊗ W(4)` (shallow balanced tree). -/
def w44MomentsG (v : Nat → GaussInt) : Int × Int × Int :=
  let r := w44RowMomentsG v
  addMom3
    (addMom3 (addMom3 (r 0) (r 1)) (addMom3 (r 2) (r 3)))
    (addMom3
      (addMom3 (addMom3 (r 4) (r 5)) (addMom3 (r 6) (r 7)))
      (addMom3
        (addMom3 (addMom3 (r 8) (r 9)) (addMom3 (r 10) (r 11)))
        (addMom3 (addMom3 (r 12) (r 13)) (addMom3 (r 14) (r 15)))))

/-- **T3c (`W(4) ⊗ W(2)` Super-MUB Anomaly & `α`-Crossover Certificate):**
    `v42SuperMub ∈ ℤ[i]⁸` (`‖v‖² = 1001`) strictly beats the `W(4) ⊗ W(2)` WH-MUB fiducial
    at BOTH `α = 2` (`Φ₄ < 15/8`) AND `α = 3` (`Φ₆ < 71/64`), and strictly REVERSES above
    WH-MUB at `α = 4` (`Φ₈ > 519/512`). -/
theorem w42_super_mub_alpha_transition :
    sumRange 8 (fun x => GaussInt.normSq (v42SuperMub x)) = 1001 ∧
    let (n4, n6, n8) := w42MomentsG v42SuperMub
    n4 = 1851540086824 ∧
    n6 = 1114095888133087352 ∧
    n8 = 1022331659421630523334728 ∧
    8 * n4 < 15 * (1001 ^ 4) ∧
    64 * n6 < 71 * (1001 ^ 6) ∧
    512 * n8 > 519 * (1001 ^ 8) := by
  decide

/-- **T3d (`W(4) ⊗ W(4)` Super-MUB Anomaly & `α`-Crossover Certificate):**
    `v44SuperMub ∈ ℤ[i]¹⁶` (`‖v‖² = 1596`) strictly beats the `W(4) ⊗ W(4)` WH-MUB fiducial
    at BOTH `α = 2` (`Φ₄ < 31/16`) AND `α = 3` (`Φ₆ < 271/256`), and strictly REVERSES above
    WH-MUB at `α = 4` (`Φ₈ > 4111/4096`). -/
theorem w44_super_mub_alpha_transition :
    sumRange 16 (fun x => GaussInt.normSq (v44SuperMub x)) = 1596 ∧
    let (n4, n6, n8) := w44MomentsG v44SuperMub
    n4 = 12399519780160 ∧
    n6 = 17475825055844169216 ∧
    n8 = 42256971384682869158123968 ∧
    16 * n4 < 31 * (1596 ^ 4) ∧
    256 * n6 < 271 * (1596 ^ 6) ∧
    4096 * n8 > 4111 * (1596 ^ 8) := by
  decide

/-- **T3e (Order-16 Abelian Magic Phase Hierarchy):**
    Strict separation of the exact rational `Φ₄` strata across order-16 abelian groups:
    `32/17 (ℤ₁₆ Zauner SIC) < Φ₄(v₄₄) (ℤ₄×ℤ₄ Super-MUB) < 31/16 (WH-MUB) < 21505201/10⁷ (ℤ₂⁴)`. -/
theorem order16_magic_phase_hierarchy :
    (32 * (1596 ^ 4) < 17 * 12399519780160) ∧
    (16 * 12399519780160 < 31 * (1596 ^ 4)) ∧
    (31 * 10000000 < 16 * 21505201) := by
  decide

end

end WeylMagic
