<!-- SPDX-License-Identifier: CC-BY-4.0 -->
# Statement-Fidelity Audit (`docs/statement-fidelity.md`)

A machine-checked Lean 4 proof guarantees logical derivation of the **formalized** proposition from Lean's axioms — it does **not** automatically guarantee that the formalized proposition faithfully matches the mathematical claim in the manuscript. Following the Defensible Independent AI Research Playbook (v1.3), this document maps **every** audited Lean 4.35.0 declaration in `lean/` line-by-line to its mathematical statement, explicitly documents every bridge that remains a paper proof outside the Lean kernel, and links every non-vacuity and adversarial boundary check.

## 1. Complete Target-by-Target Statement-Fidelity Ledger (`lean/Challenge.lean`)

| Target ID | `Challenge.lean` Symbol | Exact Formalized Proposition in Lean 4.35.0 | Paper Claim Mapped | Formalization Bridges Remaining in Paper Prose (Explicitly Disclosed) |
|---|---|---|---|---|
| **`T1a`** | `stmt_t1a` (`odd_two_adic_square_impossible`) | `∀ n, 3 ≤ n → n % 2 = 1 → ∀ K : Int, 2^n * (2^n - 2)^2 ≠ K^2` | Theorem 2.1(2), arithmetic core | **None** — exact 1-to-1 integer identity. |
| **`T1b`** | `stmt_t1b` (`pauli_idempotence_forces_square`) | `∀ n s, IsScaledPauliMUBSpectrum n s → ∃ K : Int, 2^n * (2^n - 2)^2 = K^2` | Theorem 2.1(1) | Paper eq. (4) derives `(2^n - 2) c_R = ∑ σ(P,PR) c_P c_{PR}` from `ρ^2 = ρ` on `ℂ^{2^n}`; Lean starts from `IsScaledPauliMUBSpectrum` encoding that exact equation. Nontriviality & sign convention of `pauliPhaseExp4` / `pauliIdempRHS` are kernel-validated at `n = 2` (`K = 4 ≠ 0`) in `nonvacuity_pillar1_n2_mub_spectrum`. |
| **`T1c`** | `stmt_t1c` (`no_odd_pauli_mub_all_n`) | `∀ n, 3 ≤ n → n % 2 = 1 → ∀ s, ¬ IsScaledPauliMUBSpectrum n s` | Theorem 2.1(2), Strong Form odd `n ≥ 3` | Same Hilbert-space-to-Bloch-idempotence bridge as `T1b`; zero subgroup or equimodularity assumptions anywhere. |
| **`T1d`** | `stmt_t1d` (`sharpness_n1_n2_witnesses`) | `IsScaledPauliMUBSpectrum 1 n1MubSign` AND exact `n = 2` `ℤ[i]^4` fiducial `(1,1,1,i)` (`norm2=4`, 3 zeros, 12 entries `4`, `Φ_4 = 7/4`) | Theorem 2.1(3) | **None** (and `nonvacuity_pillar1_n2_mub_spectrum` additionally proves `IsScaledPauliMUBSpectrum 2 n2MubSign` directly from `(1,1,1,i)`). |
| **`T2a`** | `stmt_t2a` (`symplectic_lagrangian_rigidity`) | For any `PauliSubgroup n H` and Bloch spectrum `c` supported off `H` obeying resolution of identity `(∑_{h∈H} (-1)^{ω(h,r)}) c_r = 0`, `∀ r ∈ H^⊥, r ∈ H` | Section 3.1 | Paper derives eq. (6) from `∑_{h∈H} P_h ρ P_h^† = I`; Lean proves the exact symplectic consequence `H^⊥ ⊆ H` for all `n`. |
| **`T2b`** | `stmt_t2b` (`fermat_gaussian_pow2_locking`) | `∀ m R I : Int, R^2 + I^2 = (2^m)^2 → (R = ±2^m ∧ I = 0) ∨ (R = 0 ∧ I = ±2^m)` | Theorem 3.1 | Paper eq. (7) applies Walsh inversion to show `2^m \overline{u_x} u_{x⊕a} ∈ ℤ[i]` with norm `2^{2m}`; Lean proves the exact Diophantine axis-locking theorem for all `m`. |
| **`T2c`** | `stmt_t2c` (`rothaus_degree_bound_all_m`) | `∀ m ≥ 2, ∀ f, IsBent m f → ∀ M, m < popcount (2*m) M → anfSum (2*m) f M % 2 = 0` | Theorem 3.2 (Rothaus 1976) | **None** — exact universal proof of Poisson summation and Rothaus's ANF degree bound for all `m ≥ 2` directly from `IsBent`. |
| **`T2d`** | `stmt_t2d` (`n4_quad_bent_count_and_triple`) | Exactly `28` of `64` homogeneous quadratic forms on `𝔽₂⁴` are bent (`28×32 = 896`), and every bent quadratic form admits a zero-sum 3-hyperplane triple | Theorem 3.3 (first part) | **None** — exact kernel-decided classification over all `64` forms. |
| **`T2e`** | `stmt_t2e` (`n4_z4_bent_hyperplane_rupture`) | For every bent quadratic `qMask < 64`, every affine shift `(lin, c0)`, and every lift `h`, no `ℤ₄` state satisfies `|z4RealExpect4 f h d| = 4` for all `0 < d < 16` | Theorem 3.3 (rupture) | Paper links equimodular `W(2)^⊗4` fiducials to `ℤ₄` states (`T2b`) and bent `f` (Parseval + Wiener–Khinchin). The bridge from **arbitrary** `IsBent 2 f` through `T2c → T2d → T2e` is now **100% kernel-closed inside Lean** via `n4_z4_bent_hyperplane_rupture_arbitrary_bent`! |
| **`T3a`–`T3b`** | `stmt_t3a`, `stmt_t3b` | Exact `ℤ[ζ₈]` norm & squared displacement counts for `psi42Z8` (`(1,7,56,0)`) in `W(4)⊗W(2)` and `psi44Z8` (`(1,15,240,0)`) in `W(4)⊗W(4)` | Theorem 4.1(1)–(2) | **None** — exact cyclotomic ring arithmetic over `ℤ[z]/(z^4 + 1)`. |
| **`T3c`–`T3d`** | `stmt_t3c`, `stmt_t3d` | Exact `ℤ[i]` norm and cleared-denominator `Φ_4, Φ_6, Φ_8` inequalities proving `v42` and `v44` beat WH-MUB at `α = 2, 3` and reverse at `α = 4` (0 axioms) | Theorem 4.1(3)–(4) | **None** — pure exact Gaussian-integer reduction with zero axioms. |
| **`T3e`** | `stmt_t3e` (`order16_magic_phase_hierarchy`) | Exact strict chain `32/17 < Φ_4(v44) < 31/16 < 21505201/10^7` (0 axioms) | Theorem 4.1(4) hierarchy | **None** — exact integer inequalities (connected to `|Ψ_4(θ*)⟩` via `T4b`). |
| **`T4a`** | `stmt_t4a` | Universal 3-stratum Parseval identity for all even `D = 2H` & rational `t = p/q`, plus exact `n = 1` (`4/3`), `n = 2` (`7/4`), `n = 3` (`16/9`) identities | Theorem 5.1(1) | Paper derives the three-stratum counts from `|0^n⟩ + e^{iθ}|+^n⟩`; Lean proves the exact Parseval and `Φ_4` identities on the three-stratum formula (independently checked against full `4^n`-Pauli sums in `reference/oracle.py` and Moonlab WASM). |
| **`T4b`** | `stmt_t4b` | Exact `n = 4` quartic identity `twoStabPhi4Num 8 p q = 128 * n4Phi4Scaled2 p q`, cubic sign bracket `(3774568/10^7, 3774569/10^7)`, `Φ_4` bracket, and strict convexity on `[0, 2/5]` | Theorem 5.1(2) | Real Intermediate Value Theorem connects the rational sign change + convexity to the unique real root `t* ∈ (0.3774568, 0.3774569)`. Global optimality over `ℂ^{16}` is explicitly `[OPEN]`. |
| **`T4c`** | `stmt_t4c` | Universal `n = 5` SOS floor `Φ_4(Ψ_5) ≥ 3` for all `p, q : Int`, plus exact `ℤ[i]^{32}` rupture witness (`norm2=254`, `num4=11097089024 < 3 * 254^4`) | Theorem 5.1(3) | Density of `ℚ` in `ℝ` extends the polynomial inequality `twoStabPhi4Num 16 p q ≥ 3072 q^4` to all real `t`; the rupture witness uses exact FWHT-32 inside Lean. |
| **`T4d`** | `stmt_t4d` | Universal discrete Cauchy–Schwarz `(S*(d^n-1))^2 ≤ N * ∑ w_i^2` plus exact arithmetic corollaries for `AME(2,2)`, `AME(5,2)`, `AME(6,2)` | Theorem 5.2 | Paper counts the vanishing low-weight Pauli operators `Z(n,d,k) = ∑_{w=1}^k C(n,w)(d^2-1)^w` for `k`-uniform states; Lean proves the universal Cauchy–Schwarz step and exact AME rational bounds. |
| **`T5a`** | `stmt_t5a` | Exact `𝔽₃` carry-quadratic law mod 9 (`((x+a)%3 - x) ≡ a + 3ax^2 + 3a(a+1)x (mod 9)`) + divided-power cross-term identity mod 9 | Theorem 6.1(1) | **None** — exact modular arithmetic identity. |
| **`T5b`** | `stmt_t5b` (`universal_gauss_sum_flat_modulus`) | Universal `ℤ[ζ₉]` bilinear Gauss-sum flat-modulus theorem: translation reindexing + zero off-diagonal shifts + `D` on diagonal implies `|∑ χ(x)|^2 = D` | Theorem 6.1(2) | **None** — exact algebraic proof in `ℤ[ζ₉]`. |
| **`T5c`** | `stmt_t5c` | Exact radix-3 FFT `ℤ[ζ₉]` MUB certificates for `W(3)^⊗{1,2,3}` (`D=3,9,27`) AND exact `ℤ[ζ₅]` certificates for `W(5)^⊗{1,2}` (`D=5,25`) | Theorem 6.1(2) | **None** for `D ≤ 27` (`[LEAN-6K]`); `W(3)^⊗4` (`D=81`) is verified in exact `ℤ[ζ₉]` by Rust and C11 (`[EXACT-COMP]`), NOT inside Lean. |
| **`T5d`** | `stmt_t5d` (`two_stab_qgt_metric_exact`) | Universal cleared-denominator algebraic identity for the Provost–Vallee Fubini–Study QGT metric `(1 - D^{-1})/(2 + 2 D^{-1/2} cos θ)^2` | Theorem 6.1(3) | Paper differentiates `|Ψ_n(θ)⟩` to obtain `⟨∂_θ Ψ|∂_θ Ψ⟩ - |⟨Ψ|∂_θ Ψ⟩|^2`; Lean proves the exact cleared-denominator rational identity for all `D, s, c, σ, q` satisfying `D s^2 = q^2`, `c^2 + σ^2 = q^2` (cross-checked numerically via QGTL Richardson extrapolation to `1.224e-8`). |

## 2. Kernel-Closed Bridge, Non-Vacuity & Adversarial Refutation Audit (15 Extra Declarations)

In addition to the 23 Palomar targets (`T1a`–`T5d` + `prove_all_weyl_magic_theorems`), `lean/VerifyAxioms.lean` audits **15 structural assurance declarations** (38 total):

1. **Kernel-closed Pillar 2 bridge (`BentHyperplaneRupture.lean`):**
   - `WeylMagic.n4_z4_bent_hyperplane_rupture_arbitrary_bent`: directly proves `IsBent 2 f → (∀ d ∈ {1..15}, |z4RealExpect4 f h d| = 4) → False` for **arbitrary** `f : Nat → Bool` by invoking `rothaus_degree_bound_all_m` inside Lean, reconstructing `(extractQuad4 f, extractLin4 f, f 0)` via exact Möbius inversion, proving `isBent4Bool (quad4Eval q) = true`, and applying `n4_z4_bent_hyperplane_rupture`.
2. **Six constructive non-vacuity witnesses (`NonVacuity.lean`):**
   - `nonvacuity_pillar1_odd_obstruction` (`n = 1` + odd `n = 3, 5` hypotheses inhabited)
   - `nonvacuity_pillar1_n2_mub_spectrum` (**nontrivial `n = 2`** proof of `IsScaledPauliMUBSpectrum 2 n2MubSign` derived directly from `(1,1,1,i)` with `pauliIdempRHS 2 n2MubSign 1 0 = 4 ≠ 0`!)
   - `nonvacuity_pillar2_symplectic_and_bent` (`zSubgroup2`, `(4,0)`, `quad4Eval 33` bent + weight-3 mask)
   - `nonvacuity_pillar3_dual_witnesses` (simultaneous WH-MUB & Super-MUB in `W(4)⊗W(2)` and `W(4)⊗W(4)`)
   - `nonvacuity_pillar4_tower_and_ame` (Parseval uniform weight vector + `n = 4` interval point + `n = 5` witness)
   - `nonvacuity_pillar5_gauss_and_qgt` (`D = 3` quadratic Gauss sum + `(4,5,6,8,10)` QGT witness)
3. **Eight adversarial boundary refutations (`AdversarialTests.lean`):**
   - `refute_two_adic_obstruction_at_n1_and_n2`
   - `refute_rothaus_at_m1`
   - `refute_fermat_axis_locking_for_odd_pow2`
   - `refute_w42_super_mub_at_alpha4`
   - `refute_w44_super_mub_at_alpha4`
   - `refute_two_stab_optimal_at_n5`
   - `refute_n4_tower_reaches_mub`
   - `refute_reducible_char3_poly`
