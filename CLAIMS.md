<!-- SPDX-License-Identifier: CC-BY-4.0 -->
# CLAIMS.md — Falsifiable Claim Ledger (`0TH-2026-020`)

Every mathematical, computational, and empirical claim in `weyl-magic-obstruction-frontier` is enumerated below with its exact epistemic tier, formal Lean 4.35.0 symbol (where applicable), executable verification command, and explicit falsification condition (**what would prove us wrong**).

## Epistemic Status Legend

- **`[LEAN-6K]`**: Machine-checked deductive proof in zero-Mathlib Lean 4.35.0, audited via `VerifyAxioms.lean` strictly within `[propext, Classical.choice, Quot.sound]` and replayed through 6 independent kernels (`leanchecker`, `leanchecker-paranoid`, `lean4lean`, `nanoda`, `con-leche`, `con-ron`).
- **`[EXACT-COMP]`**: Exact integer, Gaussian-integer, cyclotomic ($\mathbb{Z}[\zeta_8]$, $\mathbb{Z}[\zeta_9]$, $\mathbb{Z}[\zeta_5]$), or rational (`Fraction`) verification across independent compiled engines (Rust, Zig, C11+NASM, Python).
- **`[NUMERICAL-APPROX]`**: Floating-point optimization, simulation, or finite-difference cross-check (C++20 L-BFGS, QGTL Richardson QGT, Moonlab WASM CPU simulator, Eshkol AD). Never promoted to proof.
- **`[OPEN]`**: Unsettled mathematical question explicitly delimited as outside our proof scope.

---

## Pillar 1 — 2-Adic Odd-Qubit Magic Obstruction

| Claim ID | Statement | Tier | Lean Symbol | Verification Command | What Would Prove Us Wrong (Falsification) |
|---|---|---|---|---|---|
| `T1a` | For every odd $n \ge 3$, $v_2(2^n(2^n-2)^2) = n + 2$ is odd. | `[LEAN-6K]` | `WeylMagic.Palomar.prove_t1a` | `cd lean && lake env lean VerifyAxioms.lean` | Exhibiting any odd $n \ge 3$ where $2^n(2^n-2)^2$ is a perfect square in $\mathbb{N}$. |
| `T1b` | No $n$-qubit pure state with odd $n \ge 3$ has a WH-MUB Pauli spectrum ($\|c_P\|^2 \in \{0, 2^{-n}\}$), unconditionally (no subgroup or equimodularity assumptions). | `[LEAN-6K]` | `WeylMagic.Palomar.prove_t1b` | `cd lean && lake comparator --config comparator.json --paranoid` | Exhibiting a unit vector $\psi \in \mathbb{C}^{2^n}$ (odd $n \ge 3$) whose $4^n$ Pauli expectation magnitudes squared lie strictly in $\{0, 2^{-n}\}$ with exactly $2^n$ zeros and $4^n - 2^n$ nonzero entries. |
| `T1c` | Sharpness at $n=1$: $2^1 - 2 = 0$, and the single-qubit magic fiducial exists (equivalently $n=1$ escapes the parity contradiction). | `[LEAN-6K]` | `WeylMagic.Palomar.prove_t1c` | `cd lean && lake build` | Showing `T1b` erroneously extends to $n=1$ (refuted by `refute_two_adic_obstruction_at_n1_and_n2`). |
| `T1d` | Sharpness at $n=2$: $\psi = (1, 1, 1, i)/2$ achieves an exact WH-MUB spectrum with $\Phi_4 = 7/4$. | `[LEAN-6K]` | `WeylMagic.Palomar.prove_t1d` | `pytest -v tests/test_all.py -k pillar1` | Finding any Pauli operator on $\mathbb{C}^4$ whose expectation on $(1,1,1,i)/2$ has squared magnitude outside $\{0, 1/4, 1\}$. |

---

## Pillar 2 — $n=4$ Quaternary Bent-Hyperplane Rupture

| Claim ID | Statement | Tier | Lean Symbol | Verification Command | What Would Prove Us Wrong (Falsification) |
|---|---|---|---|---|---|
| `T2a` | Symplectic rigidity: for any equimodular phase state whose Pauli zeros contain a subspace $H$, $H^\perp \subseteq H$. | `[LEAN-6K]` | `WeylMagic.Palomar.prove_t2a` | `cd lean && lake build` | Exhibiting a non-coisotropic subspace $H$ satisfying the equimodular vanishing conditions. |
| `T2b` | Fermat axis locking: for integer $(R, I)$ with $R^2 + I^2 = 4^m$, one coordinate is $0$ and the other is $\pm 2^m$, locking quaternary phases $u_x \in \mathbb{Z}_4$. | `[LEAN-6K]` | `WeylMagic.Palomar.prove_t2b` | `pytest -v tests/test_all.py -k fermat` | Exhibiting integers $R \ne 0, I \ne 0$ with $R^2 + I^2 = 4^m$ (note: for odd powers $2^{2m+1}$, $(2^m)^2 + (2^m)^2 = 2^{2m+1}$ DOES exist, formalized as `refute_fermat_axis_locking_for_odd_pow2`). |
| `T2c` | Universal Rothaus (1976) degree bound: every bent Boolean function on $\mathbb{F}_2^{2m}$ for ALL $m \ge 2$ satisfies $\deg_{\mathrm{ANF}}(f) \le m$. | `[LEAN-6K]` | `WeylMagic.Palomar.prove_t2c` | `cd lean && lake comparator --config comparator.json --paranoid` | Exhibiting a bent Boolean function on $\mathbb{F}_2^{2m}$ ($m \ge 2$) containing an ANF monomial of degree $\ge m+1$ (at $m=1$, $\deg=2 > 1$ exists, formalized in `refute_rothaus_at_m1`). |
| `T2d` | Exhaustive $\mathbb{F}_2^4$ bent classification: of all $65{,}536$ Boolean functions on $\mathbb{F}_2^4$, exactly $896$ are bent (28 quadratic forms $\times$ 32 affine shifts), and $0$ have degree $> 2$. | `[LEAN-6K]` + `[EXACT-COMP]` | `WeylMagic.Palomar.prove_t2d` | `cargo test --release && ./build/test_weyl_magic` | Finding a $65{,}537$-th function or a single bent function on $\mathbb{F}_2^4$ of degree $3$ or $4$, or a count $\ne 896$. |
| `T2e` | Universal 3-hyperplane zero-sum triple: every one of the 896 bent functions on $\mathbb{F}_2^4$ admits $a \ne b$ with $\mathbf{1}_{E_a} \oplus \mathbf{1}_{E_b} \oplus \mathbf{1}_{E_{a \oplus b}} = 0$, contradicting $\sum_{x \in E_a} h(x) \equiv 1 \pmod 2$ and ruling out $n=4$ equimodular WH-MUB states. | `[LEAN-6K]` + `[EXACT-COMP]` | `WeylMagic.Palomar.prove_t2e` | `zig test zig/src/main.zig && pytest -v tests/test_all.py -k bent` | Exhibiting a single $n=4$ bent function with no zero-sum hyperplane triple $(E_a, E_b, E_{a\oplus b})$, OR exhibiting an equimodular 4-qubit state with WH-MUB spectrum. |

---

## Pillar 3 — Super-MUB Torsion Anomalies & $\alpha$-Dependence

| Claim ID | Statement | Tier | Lean Symbol | Verification Command | What Would Prove Us Wrong (Falsification) |
|---|---|---|---|---|---|
| `T3a` | Exact $\mathbb{Z}[\zeta_8]$ WH-MUB fiducial in $W(4)\otimes W(2)$ (`norm2=8`, exact spectrum $\{64:1, 0:7, 8:56\}$, $\Phi_4 = 15/8$). | `[LEAN-6K]` | `WeylMagic.Palomar.prove_t3a` | `cd lean && lake build` | Computing any of the 64 displacement expectations of `psi42` in $\mathbb{Z}[\zeta_8]$ and finding a squared norm outside $\{0, 8, 64\}$. |
| `T3b` | Exact $\mathbb{Z}[\zeta_8]$ WH-MUB fiducial in $W(4)\otimes W(4)$ (`norm2=320`, exact spectrum $\{102400:1, 0:15, 6400:240\}$, $\Phi_4 = 31/16$). | `[LEAN-6K]` | `WeylMagic.Palomar.prove_t3b` | `cd lean && lake build` | Computing any of the 256 displacement expectations of `psi44` in $\mathbb{Z}[\zeta_8]$ and finding a squared norm outside $\{0, 6400, 102400\}$. |
| `T3c` | Exact $\mathbb{Z}[i]$ Super-MUB witness `v42` (`norm2=1001`) in $W(4)\otimes W(2)$ strictly beats WH-MUB at $\alpha=2$ ($\Phi_4 = 1851540086824/1001^4 < 15/8$) and $\alpha=3$ ($\Phi_6 < 71/64$), but strictly LOSES at $\alpha=4$ ($\Phi_8 > 519/512$). | `[LEAN-6K]` (0 axioms) | `WeylMagic.Palomar.prove_t3c` | `cargo test --release` | Exact arithmetic evaluation of `v42` violating any of the three rational inequalities. |
| `T3d` | Exact $\mathbb{Z}[i]$ Super-MUB witness `v44` (`norm2=1596`) in $W(4)\otimes W(4)$ strictly beats WH-MUB at $\alpha=2$ ($\Phi_4 = 12399519780160/1596^4 < 31/16$) and $\alpha=3$ ($\Phi_6 < 271/256$), but strictly LOSES at $\alpha=4$ ($\Phi_8 > 4111/4096$). | `[LEAN-6K]` (0 axioms) | `WeylMagic.Palomar.prove_t3d` | `cargo test --release` | Exact arithmetic evaluation of `v44` violating any of the three rational inequalities. |
| `T3e` | Combined Super-MUB torsion dichotomy across $W(4)\otimes W(2)$ and $W(4)\otimes W(4)$: WH-MUB fiducials exist yet are strictly suboptimal for $M_2$ and $M_3$ magic. | `[LEAN-6K]` (0 axioms) | `WeylMagic.Palomar.prove_t3e` | `cd lean && lake env lean VerifyAxioms.lean` | Refutation of any of `T3a`–`T3d`. |
| `E3-LBFGS` | Direct Riemannian L-BFGS re-optimization at $\alpha=4$ still beats WH-MUB in $W(4)\otimes W(2)$ ($\Phi_8 \approx 1.012971 < 1.013672$) and $W(4)\otimes W(4)$ ($\Phi_8 \approx 1.003658 < 1.003662$), showing Super-MUB maximizers drift continuously with $\alpha$. | `[NUMERICAL-APPROX]` | *(empirical)* | `./build/magic_search 64` | Showing that the $\Phi_8$-minimizing state at $\alpha=4$ has a bug in normalization or fails to achieve $\Phi_8 < \Phi_8^{\mathrm{MUB}}$ upon exact rational rounding. |

---

## Pillar 4 — Two-Stabilizer Tower, $n=5$ SOS Rupture & AME Magic Ceilings

| Claim ID | Statement | Tier | Lean Symbol | Verification Command | What Would Prove Us Wrong (Falsification) |
|---|---|---|---|---|---|
| `T4a` | Universal 3-stratum Parseval identity for $|\Psi_n(\theta)\rangle$ unifying $n=1$ ($4/3$), $n=2$ ($7/4$), and $n=3$ ($16/9$, Hoggar SIC). | `[LEAN-6K]` | `WeylMagic.Palomar.prove_t4a` | `cd lean && lake build` | Finding a discrepancy between the closed-form $\Phi_4(\Psi_n(\theta))$ polynomial and the direct $4^n$-Pauli sum at $n=1,2,3$. |
| `T4b` | At $n=4$, $\Phi_4(\Psi_4(t)) = \frac{1}{2}(6795t^4 - 13020t^3 + 9330t^2 - 2940t + 347)$ is strictly convex on $[0, 2/5]$ with unique stationary point solving $453t^3 - 651t^2 + 311t - 49 = 0$ bracketed in Lean by $(3774568/10^7, 3774569/10^7)$ (and refined to 50 digits in Python `Decimal`), with $21505201/10^7 < \Phi_4(t_0) < 21505202/10^7$, strictly above $31/16$. | `[LEAN-6K]` | `WeylMagic.Palomar.prove_t4b` | `pytest -v tests/test_all.py -k pillar4` | Showing $453t^3-651t^2+311t-49$ has no sign change on the bracket or $\Phi_4(\Psi_4(t)) \le 31/16$ for some $t \in [0, 2/5]$. |
| `T4c` | At $n=5$, an explicit sum-of-squares decomposition proves $\Phi_4(\Psi_5(\theta)) \ge 3$ for all $\theta$, whereas the exact $\mathbb{Z}[i]^{32}$ rupture witness (`norm2=254`, `num4=11097089024`) achieves $\Phi_4 = 693568064/260144641 \approx 2.666086 < 3$. | `[LEAN-6K]` + `[EXACT-COMP]` | `WeylMagic.Palomar.prove_t4c` | `./build/test_weyl_magic && cargo test --release` | Exhibiting a $\theta$ with $\Phi_4(\Psi_5(\theta)) < 3$, OR finding that the 32-component witness does not give `num4 = 11097089024` and `norm2 = 254`. |
| `T4d` | Universal Cauchy–Schwarz ceiling on $k$-uniform and AME states: $\Phi_4(\mathrm{AME}(2,2)) \ge 2$, $\Phi_4(\mathrm{AME}(5,2)) \ge 1879/918$, $\Phi_4(\mathrm{AME}(6,2)) \ge 13/6$. | `[LEAN-6K]` | `WeylMagic.Palomar.prove_t4d` | `pytest -v tests/test_all.py -k ame` | Exhibiting a genuine $k$-uniform qubit state whose Pauli 4th moment strictly violates the Cauchy–Schwarz floor on the non-vanishing weight strata. |

---

## Pillar 5 — Divided-Power Characteristic-3 Alltop, Char-5 & Exact QGT

| Claim ID | Statement | Tier | Lean Symbol | Verification Command | What Would Prove Us Wrong (Falsification) |
|---|---|---|---|---|---|
| `T5a` | Elementary $\mathbb{F}_3$ carry-quadratic law and universal divided-power difference identity in $\mathbb{Z}_9$ (with explicit attribution to Damski et al. `arXiv:2603.15550` for Galois-ring $\mathrm{GR}(9,n)$ char-3 MUB existence). | `[LEAN-6K]` | `WeylMagic.Palomar.prove_t5a` | `cd lean && lake build` | Exhibiting $x, a \in \mathbb{F}_3^n$ violating the $\mathbb{Z}_9$ carry-quadratic identity. |
| `T5b` | Universal bilinear Gauss-sum flat-modulus theorem + exact radix-3 FFT $\mathbb{Z}[\zeta_9]$ WH-MUB certificates for $W(3)^{\otimes 1,2,3}$ (`D = 3, 9, 27`, spectra `(1,2,6,0)`, `(1,8,72,0)`, `(1,26,702,0)`). Extended to $n=4$ (`D=81`, `(1,80,6480,0)`) in Rust & C11. | `[LEAN-6K]` ($n \le 3$) + `[EXACT-COMP]` ($n=4$) | `WeylMagic.Palomar.prove_t5b` | `cargo test --release && ./build/test_weyl_magic` | Finding a non-flat off-diagonal displacement magnitude for the cubic polynomial $t^3 = 2 + t$ ($n=3$) or quartic $t^4 = 1 + 2t$ ($n=4$). |
| `T5c` | Exact $\mathbb{Z}[\zeta_5]$ Alltop cubic WH-MUB certificates for $W(5)^{\otimes 1}$ (`D=5`, `(1,4,20,0)`) and $W(5)^{\otimes 2}$ (`D=25`, `(1,24,600,0)`). | `[LEAN-6K]` (1 axiom: `propext`) | `WeylMagic.Palomar.prove_t5c` | `cd lean && lake env lean VerifyAxioms.lean` | Finding any displacement magnitude squared outside $\{0, D, D^2\}$ for the char-5 Alltop fiducial. |
| `T5d` | Universal closed-form Fubini–Study QGT metric for the two-stabilizer family: $g_{\theta\theta}(\theta) = (1 - D^{-1})/(2 + 2 D^{-1/2}\cos\theta)^2$, independently cross-checked via QGTL Richardson extrapolation (`max_rel_err = 1.224e-8`). | `[LEAN-6K]` (identity) + `[NUMERICAL-APPROX]` (QGTL check) | `WeylMagic.Palomar.prove_t5d` | `./build/qgtl_bridge && pytest -v tests/test_all.py -k qgt` | Computing $g_{\theta\theta}(\theta) = \langle\partial_\theta\Psi|\partial_\theta\Psi\rangle - |\langle\Psi|\partial_\theta\Psi\rangle|^2$ and finding any deviation from $(1-D^{-1})/(2+2D^{-1/2}\cos\theta)^2$. |

---

## Explicitly Open Questions (Not Claimed Proved)

| Open ID | Question | Status |
|---|---|---|
| `O1` | Does ANY non-equimodular $n=4$ qubit state achieve the WH-MUB bound $\Phi_4 = 31/16$? (Our `T2e` rules out equimodular states; C++20 L-BFGS numerical minimum is $2.15052015\dots$, matching $|\Psi_4(\theta^*)\rangle$, which is NOT proved globally optimal over $\mathbb{C}^{16}$.) | `[OPEN]` |
| `O2` | Does the strong form of the even-$n$ WH-MUB nonexistence obstruction hold for all even $n \ge 6$? | `[OPEN]` |
| `O3` | Are there closed-form algebraic families of Super-MUB maximizers in $W(4)\otimes W(2)$ and $W(4)\otimes W(4)$ as a continuous function of Rényi index $\alpha \in (1, \infty)$? | `[OPEN]` |
