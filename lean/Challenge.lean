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
# Formal Statement Contract (`Challenge.lean`)

Zero-`sorry` specification of all 22 numbered theorem targets (`T1a`–`T5d`) and the
master conjunction (`ALL`) across the five pillars of the Weyl–Heisenberg Magic
Obstruction Frontier. Imported identically by `PalomarChallenge.lean` and
`PalomarSolution.lean` for independent 6-kernel comparator verification.
-/

namespace WeylMagic.Spec

@[expose] public section

-- Pillar 1: Universal 2-Adic Idempotence Obstruction (ALL odd n ≥ 3)
def stmt_t1a : Prop :=
  ∀ (n : Nat), 3 ≤ n → n % 2 = 1 → ∀ (K : Int),
    ((2 : Int) ^ n) * (((2 : Int) ^ n) - 2) * (((2 : Int) ^ n) - 2) ≠ K * K

def stmt_t1b : Prop :=
  ∀ (n : Nat) (s : Nat → Nat → Int), IsScaledPauliMUBSpectrum n s →
    ∃ K : Int, ((2 : Int) ^ n) * (((2 : Int) ^ n) - 2) * (((2 : Int) ^ n) - 2) = K * K

def stmt_t1c : Prop :=
  ∀ (n : Nat), 3 ≤ n → n % 2 = 1 → ∀ (s : Nat → Nat → Int), ¬ IsScaledPauliMUBSpectrum n s

def stmt_t1d : Prop :=
  IsScaledPauliMUBSpectrum 1 n1MubSign ∧
  (sumRange 4 (fun x => GaussInt.normSq (n2MubVec x)) = 4) ∧
  (∀ a b, a < 4 → b < 4 →
    if a = 0 ∧ b = 0 then n2PauliExpectSq n2MubVec a b = 16
    else if a = 0 then n2PauliExpectSq n2MubVec a b = 0
    else n2PauliExpectSq n2MubVec a b = 4) ∧
  (4 * n2Phi4Num n2MubVec = 7 * 256)

-- Pillar 2: Symplectic Rigidity, Fermat Z4-Locking, Rothaus Bound, n = 4 Bent-Hyperplane Rupture
def stmt_t2a : Prop :=
  ∀ (n : Nat) (H : PauliSubgroup n) (c : Nat → Nat → Int),
    (∀ ra rb, ra < 2 ^ n → rb < 2 ^ n → H.inH ra rb = false → c ra rb ≠ 0) →
    (∀ ra rb, ra < 2 ^ n → rb < 2 ^ n → (ra ≠ 0 ∨ rb ≠ 0) →
      subgroupCharSum n H ra rb * c ra rb = 0) →
    ∀ ra rb, ra < 2 ^ n → rb < 2 ^ n →
      (∀ pa pb, pa < 2 ^ n → pb < 2 ^ n → H.inH pa pb = true →
        sympForm n pa pb ra rb = false) →
      H.inH ra rb = true

def stmt_t2b : Prop :=
  ∀ (m : Nat) (R I : Int),
    R * R + I * I = ((2 : Int) ^ m) * ((2 : Int) ^ m) →
    ((R = (2 : Int) ^ m ∨ R = -((2 : Int) ^ m)) ∧ I = 0) ∨
    (R = 0 ∧ (I = (2 : Int) ^ m ∨ I = -((2 : Int) ^ m)))

def stmt_t2c : Prop :=
  ∀ (m : Nat), 2 ≤ m → ∀ (f : Nat → Bool), IsBent m f →
    ∀ (M : Nat), m < popcount (2 * m) M → (anfSum (2 * m) f M) % 2 = 0

def stmt_t2d : Prop :=
  countNondegenQuad4 = 28 ∧
  ((List.range 64).all fun q => !isBent4Bool (quad4Eval q) || hasZeroTripleQuad4 q) = true

def stmt_t2e : Prop :=
  ∀ (qMask lin : Nat) (c0 : Bool), qMask < 64 →
    isBent4Bool (quad4Eval qMask) = true →
    ∀ (h : Nat → Bool),
      (∀ d, 0 < d → d < 16 →
        z4RealExpect4 (deg2Eval4 qMask lin c0) h d = 4 ∨
        z4RealExpect4 (deg2Eval4 qMask lin c0) h d = -4) → False

-- Pillar 3: Non-Flat 2-Torsion WH-MUBs, Super-MUB Anomalies, and alpha-Phase Transition
def stmt_t3a : Prop :=
  sumRange 8 (fun x => (Zeta8.normSqPair (psi42Z8 x)).1) = 8 ∧
  sumRange 8 (fun x => (Zeta8.normSqPair (psi42Z8 x)).2) = 0 ∧
  w42Z8SpectrumCounts psi42Z8 64 8 = (1, 7, 56, 0)

def stmt_t3b : Prop :=
  sumRange 16 (fun x => (Zeta8.normSqPair (psi44Z8 x)).1) = 320 ∧
  sumRange 16 (fun x => (Zeta8.normSqPair (psi44Z8 x)).2) = 0 ∧
  w44Z8SpectrumCounts psi44Z8 102400 6400 = (1, 15, 240, 0)

def stmt_t3c : Prop :=
  sumRange 8 (fun x => GaussInt.normSq (v42SuperMub x)) = 1001 ∧
  let (n4, n6, n8) := w42MomentsG v42SuperMub
  n4 = 1851540086824 ∧
  n6 = 1114095888133087352 ∧
  n8 = 1022331659421630523334728 ∧
  8 * n4 < 15 * (1001 ^ 4) ∧
  64 * n6 < 71 * (1001 ^ 6) ∧
  512 * n8 > 519 * (1001 ^ 8)

def stmt_t3d : Prop :=
  sumRange 16 (fun x => GaussInt.normSq (v44SuperMub x)) = 1596 ∧
  let (n4, n6, n8) := w44MomentsG v44SuperMub
  n4 = 12399519780160 ∧
  n6 = 17475825055844169216 ∧
  n8 = 42256971384682869158123968 ∧
  16 * n4 < 31 * (1596 ^ 4) ∧
  256 * n6 < 271 * (1596 ^ 6) ∧
  4096 * n8 > 4111 * (1596 ^ 8)

def stmt_t3e : Prop :=
  (32 * (1596 ^ 4) < 17 * 12399519780160) ∧
  (16 * 12399519780160 < 31 * (1596 ^ 4)) ∧
  (31 * 10000000 < 16 * 21505201)

-- Pillar 4: Universal Two-Stabilizer Tower, n = 4 Cubic, n = 5 SOS Rupture, AME Ceiling
def stmt_t4a : Prop :=
  (∀ H p q : Int, twoStabParsevalNum H p q = (2 * H - 1) * (2 * H) * (q * q)) ∧
  (∀ p q : Int, 3 * twoStabPhi4Num 1 p q - 4 * (4 * (q * q * q * q)) =
    8 * ((3 * (p * p) - q * q) * (3 * (p * p) - q * q))) ∧
  (4 * twoStabPhi4Num 2 1 2 = 7 * (16 * 16)) ∧
  (9 * twoStabPhi4Num 4 1 3 = 16 * (64 * 81))

def stmt_t4b : Prop :=
  (∀ p q : Int, twoStabPhi4Num 8 p q = 128 * n4Phi4Scaled2 p q) ∧
  (n4StationaryCubic 3774568 10000000 < 0) ∧
  (0 < n4StationaryCubic 3774569 10000000) ∧
  (10000000 * n4Phi4Scaled2 3774568 10000000 < 21505202 * (2 * (10000000 ^ 4))) ∧
  (21505201 * (2 * (10000000 ^ 4)) < 10000000 * n4Phi4Scaled2 3774568 10000000) ∧
  (∀ p q : Int, 0 < q → 10 * p ≤ 4 * q →
    0 < 1359 * (p * p) - 1302 * (p * q) + 311 * (q * q))

def stmt_t4c : Prop :=
  (∀ p q : Int, 3 * (1024 * (q * q * q * q)) ≤ twoStabPhi4Num 16 p q) ∧
  (n5NormSq n5RuptureVec = 254) ∧
  (n5Phi4Num n5RuptureVec = 11097089024) ∧
  (n5Phi4Num n5RuptureVec < 3 * (254 ^ 4))

def stmt_t4d : Prop :=
  (∀ (N : Nat) (S D_minus_1 : Int) (w : Nat → Int),
    sumRange N w = S * D_minus_1 →
    (S * D_minus_1) * (S * D_minus_1) ≤ (N : Int) * sumRange N (fun i => w i * w i)) ∧
  ((9 + 3 * 3) * 4 > 7 * 9) ∧
  ((918 + 31 * 31) = 1879 ∧ 1879 * 32 > 63 * 918) ∧
  ((3402 + 63 * 63) * 6 = 13 * 3402 ∧ 13 * 64 > 127 * 6)

-- Pillar 5: Divided-Power Char-3 Alltop, Universal Gauss-Sum Flatness, Char-5, Exact QGT
def stmt_t5a : Prop :=
  (∀ x a : Nat, x < 3 → a < 3 →
    ((((((x + a) % 3 : Nat) : Int) - (x : Int)) -
      ((a : Int) + 3 * (a : Int) * (x : Int) * (x : Int) +
       3 * (a : Int) * ((a : Int) + 1) * (x : Int))) % 9 = 0)) ∧
  (∀ x y z a b c : Int,
    (3 * ((x + a) * (x + a) * (y + b) - x * x * y) =
      3 * (b * x * x + 2 * a * x * y) +
      3 * (2 * a * b * x + a * a * y) +
      3 * (a * a * b)) ∧
    (6 * ((x + a) * (y + b) * (z + c) - x * y * z) =
      6 * (c * x * y + b * x * z + a * y * z) +
      6 * (b * c * x + a * c * y + a * b * z) +
      6 * (a * b * c)))

def stmt_t5b : Prop :=
  ∀ (D : Nat), 0 < D → ∀ (χ : Nat → Zeta9) (shift : Nat → Nat → Nat),
    (∀ y, y < D →
      sumZ9 D (fun x => Zeta9.mul (χ x) (Zeta9.conjExact (χ y))) =
      sumZ9 D (fun h => Zeta9.mul (χ (shift h y)) (Zeta9.conjExact (χ y)))) →
    (sumZ9 D (fun y => Zeta9.mul (χ (shift 0 y)) (Zeta9.conjExact (χ y))) = Zeta9.ofInt D) →
    (∀ h, 0 < h → h < D →
      sumZ9 D (fun y => Zeta9.mul (χ (shift h y)) (Zeta9.conjExact (χ y))) = Zeta9.zero) →
    Zeta9.normSq (sumZ9 D χ) = Zeta9.ofInt D

def stmt_t5c : Prop :=
  w3SpectrumCounts 1 gChar3_n1 = (1, 2, 6, 0) ∧
  w3SpectrumCounts 2 gChar3_n2 = (1, 8, 72, 0) ∧
  w3SpectrumCounts 3 gChar3_n3 = (1, 26, 702, 0) ∧
  w5_n1SpectrumCounts = (1, 4, 20, 0) ∧
  w5_n2SpectrumCounts = (1, 24, 600, 0)

def stmt_t5d : Prop :=
  ∀ (D s c σ q : Int),
    D * (s * s) = q * q → c * c + σ * σ = q * q →
    let N := 2 * (q * q) + 2 * (s * c)
    D * (N * (q * q) - (s * s * (σ * σ) + (q * q + s * c) * (q * q + s * c))) =
      (D - 1) * (q * q * q * q)

/-- Master conjunction of all 22 theorem targets across all 5 pillars. -/
def stmt_all_weyl_magic_theorems : Prop :=
  stmt_t1a ∧ stmt_t1b ∧ stmt_t1c ∧ stmt_t1d ∧
  stmt_t2a ∧ stmt_t2b ∧ stmt_t2c ∧ stmt_t2d ∧ stmt_t2e ∧
  stmt_t3a ∧ stmt_t3b ∧ stmt_t3c ∧ stmt_t3d ∧ stmt_t3e ∧
  stmt_t4a ∧ stmt_t4b ∧ stmt_t4c ∧ stmt_t4d ∧
  stmt_t5a ∧ stmt_t5b ∧ stmt_t5c ∧ stmt_t5d

end

end WeylMagic.Spec
