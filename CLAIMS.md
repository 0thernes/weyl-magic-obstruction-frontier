<!-- SPDX-License-Identifier: CC-BY-4.0 -->
# CLAIMS.md — Falsifiable Claim Ledger (`0TH-2026-022`)

Every mathematical, computational, and empirical claim in `weyl-magic-obstruction-frontier` is enumerated below with its exact epistemic tier, exact `Challenge.lean` / `PalomarSolution.lean` symbol (verified 1-to-1 against [docs/statement-fidelity.md](docs/statement-fidelity.md)), executable verification command, and explicit falsification condition (**what would prove us wrong**).

## Epistemic Status Legend

- **`[LEAN-6K]`**: Machine-checked deductive proof in zero-Mathlib Lean 4.35.0, audited via `VerifyAxioms.lean` strictly within `[propext, Classical.choice, Quot.sound]` and replayed through 6 independent kernels (`lean`, `leanchecker-paranoid`, `lean4lean`, `nanoda`, `con-leche`, `con-ron`).
- **`[EXACT-COMP]`**: Exact integer, Gaussian-integer, cyclotomic ($\mathbb{Z}[\zeta_8]$, $\mathbb{Z}[\zeta_9]$, $\mathbb{Z}[\zeta_5]$), or rational (`Fraction`) verification across independent compiled engines (Rust, Zig, C11+NASM, Python).
- **`[NUMERICAL-APPROX]`**: Floating-point optimization, simulation, or finite-difference cross-check (C++20 L-BFGS, QGTL Richardson QGT, Moonlab WASM CPU simulator). Never promoted to proof.
- **`[OPEN]`**: Unsettled mathematical question explicitly delimited as outside our proof scope.

---

## Pillar 1 — 2-Adic Odd-Qubit Magic Obstruction

| Claim ID | Statement | Tier | Lean Symbol | Verification Command | What Would Prove Us Wrong (Falsification) |
|---|---|---|---|---|---|
| `T1a` | For every odd $n \ge 3$ and every $K \in \mathbb{Z}$, $2^n(2^n-2)^2 \ne K^2$ (since $v_2(2^n(2^n-2)^2) = n + 2$ is odd). | `[LEAN-6K]` | `WeylMagic.Palomar.prove_t1a` | `cd lean && lake env lean VerifyAxioms.lean` | Exhibiting any odd $n \ge 3$ and integer $K$ with $2^n(2^n-2)^2 = K^2$. |
| `T1b` | Any scaled pure-state Pauli MUB spectrum (`IsScaledPauliMUBSpectrum n s`) forces $\exists K \in \mathbb{Z},\; 2^n(2^n-2)^2 = K^2$ directly from squared Pauli idempotence. | `[LEAN-6K]` (`[propext]`) | `WeylMagic.Palomar.prove_t1b` | `cd lean && lake comparator --config comparator.json --paranoid` | Exhibiting a valid scaled Pauli MUB spectrum violating the integer square condition (nontriviality of the predicate is kernel-checked at $n=2$ with $K=4$ in `nonvacuity_pillar1_n2_mub_spectrum`). |
| `T1c` | Unconditional odd-$n \ge 3$ nonexistence: for EVERY odd $n \ge 3$ and EVERY $s$, $\neg \mathrm{IsScaledPauliMUBSpectrum}\; n\; s$ (zero subgroup or equimodularity assumptions). | `[LEAN-6K]` | `WeylMagic.Palomar.prove_t1c` | `cd lean && lake comparator --config comparator.json --paranoid` | Exhibiting a unit vector $\psi \in \mathbb{C}^{2^n}$ (odd $n \ge 3$) whose $4^n$ Pauli expectation magnitudes squared lie strictly in $\{0, 2^{-n}\}$ (with $c_I = 1$). |
| `T1d` | Sharpness at BOTH $n=1$ (`IsScaledPauliMUBSpectrum 1 n1MubSign`, $2^1-2=0$) AND $n=2$ (exact $\mathbb{Z}[i]^4$ fiducial $(1,1,1,i)$ with $\|v\|^2=4$, 3 zeros, 12 entries of $1/4$, $\Phi_4 = 7/4$). | `[LEAN-6K]` | `WeylMagic.Palomar.prove_t1d` | `pytest -v tests/test_all.py -k pillar1` | Finding any Pauli operator on $\mathbb{C}^4$ whose squared expectation on $(1,1,1,i)/2$ lies outside $\{0, 1/4, 1\}$. |

---

## Pillar 2 — $n=4$ Quaternary Bent-Hyperplane Rupture

| Claim ID | Statement | Tier | Lean Symbol | Verification Command | What Would Prove Us Wrong (Falsification) |
|---|---|---|---|---|---|
| `T2a` | Symplectic rigidity for all $n$: any Pauli subgroup $H$ obeying the resolution-of-identity character sum with $c_r = 0 \iff r \in H \setminus \{0\}$ satisfies $H^\perp \subseteq H$. | `[LEAN-6K]` | `WeylMagic.Palomar.prove_t2a` | `cd lean && lake build` | Exhibiting a non-coisotropic subgroup $H$ satisfying the resolution-of-identity character sum condition. |
| `T2b` | Fermat Gaussian-square axis locking for all $m$: integer $R^2 + I^2 = (2^m)^2$ forces $(R, I) \in \{(\pm 2^m, 0), (0, \pm 2^m)\}$, locking equimodular phases to $\mathbb{Z}_4$. | `[LEAN-6K]` | `WeylMagic.Palomar.prove_t2b` | `pytest -v tests/test_all.py -k fermat` | Exhibiting integers $R \ne 0, I \ne 0$ with $R^2 + I^2 = 4^m$ (for odd powers $2^{2m+1}$, $(2^m)^2 + (2^m)^2 = 2^{2m+1}$ exists, formalized in `refute_fermat_axis_locking_for_odd_pow2`). |
| `T2c` | Universal Rothaus (1976) degree bound: for EVERY $m \ge 2$, EVERY bent $f: \mathbb{F}_2^{2m} \to \mathbb{F}_2$, and EVERY mask $M$ with $\operatorname{wt}(M) > m$, $\mathrm{anfSum}(2m, f, M) \equiv 0 \pmod 2$. | `[LEAN-6K]` | `WeylMagic.Palomar.prove_t2c` | `cd lean && lake comparator --config comparator.json --paranoid` | Exhibiting a bent Boolean function on $\mathbb{F}_2^{2m}$ ($m \ge 2$) with ANF degree $> m$ (sharp at $m=1$ via `refute_rothaus_at_m1`). |
| `T2d` | Exhaustive $\mathbb{F}_2^4$ quadratic bent classification: exactly $28$ of $64$ homogeneous quadratic forms are bent ($28 \times 32 = 896$ bent functions total, confirmed across all $65{,}536$ functions in Rust/Zig/C11/Python), and EVERY bent quadratic form admits a zero-sum 3-hyperplane triple. | `[LEAN-6K]` + `[EXACT-COMP]` | `WeylMagic.Palomar.prove_t2d` | `cargo test --release && ./build/test_weyl_magic` | Finding a bent count $\ne 896$, a bent function of degree $>2$ on $\mathbb{F}_2^4$, or a bent quadratic form lacking a zero-sum triple. |
| `T2e` | Complete $n=4$ $\mathbb{Z}_4$ bent-hyperplane rupture over all 896 bent functions and all lifts $h$: no $\mathbb{Z}_4$-phase state satisfies $|16\operatorname{Re}\langle u|X^d|u\rangle| = 4$ for all nonzero $d < 16$ (closed directly from arbitrary `IsBent 2 f` in `n4_z4_bent_hyperplane_rupture_arbitrary_bent`). | `[LEAN-6K]` + `[EXACT-COMP]` | `WeylMagic.Palomar.prove_t2e` (+ `n4_z4_bent_hyperplane_rupture_arbitrary_bent`) | `zig test zig/src/main.zig && pytest -v tests/test_all.py -k bent` | Exhibiting an equimodular 4-qubit state with WH-MUB Pauli spectrum, or a lift $h$ surviving all 15 nonzero $X$-shifts. |

---

## Pillar 3 — Super-MUB Torsion Anomalies & $\alpha$-Dependence

| Claim ID | Statement | Tier | Lean Symbol | Verification Command | What Would Prove Us Wrong (Falsification) |
|---|---|---|---|---|---|
| `T3a` | Exact $\mathbb{Z}[\zeta_8]$ WH-MUB fiducial `psi42Z8` in $W(4)\otimes W(2)$ (`norm2=8`, exact spectrum $\{64:1, 0:7, 8:56\}$, $\Phi_4 = 15/8$). | `[LEAN-6K]` | `WeylMagic.Palomar.prove_t3a` | `cd lean && lake build` | Computing any of the 64 displacement expectations of `psi42Z8` in $\mathbb{Z}[\zeta_8]$ and finding a squared norm outside $\{0, 8, 64\}$. |
| `T3b` | Exact $\mathbb{Z}[\zeta_8]$ WH-MUB fiducial `psi44Z8` in $W(4)\otimes W(4)$ (`norm2=320`, exact spectrum $\{102400:1, 0:15, 6400:240\}$, $\Phi_4 = 31/16$). | `[LEAN-6K]` | `WeylMagic.Palomar.prove_t3b` | `cd lean && lake build` | Computing any of the 256 displacement expectations of `psi44Z8` in $\mathbb{Z}[\zeta_8]$ and finding a squared norm outside $\{0, 6400, 102400\}$. |
| `T3c` | Exact $\mathbb{Z}[i]$ Super-MUB witness `v42` (`norm2=1001`) in $W(4)\otimes W(2)$ strictly beats WH-MUB at $\alpha=2$ ($\Phi_4 = 1851540086824/1001^4 < 15/8$) and $\alpha=3$ ($\Phi_6 < 71/64$), but reverses at $\alpha=4$ ($\Phi_8 > 519/512$). | `[LEAN-6K]` (0 axioms) | `WeylMagic.Palomar.prove_t3c` | `cargo test --release` | Exact arithmetic evaluation of `v42` violating any of the three rational inequalities. |
| `T3d` | Exact $\mathbb{Z}[i]$ Super-MUB witness `v44` (`norm2=1596`) in $W(4)\otimes W(4)$ strictly beats WH-MUB at $\alpha=2$ ($\Phi_4 = 12399519780160/1596^4 < 31/16$) and $\alpha=3$ ($\Phi_6 < 271/256$), but reverses at $\alpha=4$ ($\Phi_8 > 4111/4096$). | `[LEAN-6K]` (0 axioms) | `WeylMagic.Palomar.prove_t3d` | `cargo test --release` | Exact arithmetic evaluation of `v44` violating any of the three rational inequalities. |
| `T3e` | Strict order-16 magic phase hierarchy: $32/17 < \Phi_4(v_{4,4}) < 31/16 < 21505201/10^7$ (separating Zauner SIC, Super-MUB $W(4)\otimes W(4)$, WH-MUB $W(4)\otimes W(2)^2$, and 4-qubit cubic $|\Psi_4(\theta^*)\rangle$). | `[LEAN-6K]` (0 axioms) | `WeylMagic.Palomar.prove_t3e` | `cd lean && lake env lean VerifyAxioms.lean` | Refutation of any strict rational inequality in the four-tier chain. |
| `E3-LBFGS` | Direct Riemannian L-BFGS re-optimization at $\alpha=4$ still beats WH-MUB in $W(4)\otimes W(2)$ ($\Phi_8 \approx 1.012971 < 1.013672$) and $W(4)\otimes W(4)$ ($\Phi_8 \approx 1.003658 < 1.003662$), showing Super-MUB maximizers move with $\alpha$. | `[NUMERICAL-APPROX]` | *(empirical)* | `./build/magic_search 64` | Showing that the $\Phi_8$-minimizing state at $\alpha=4$ has a normalization bug or fails to achieve $\Phi_8 < \Phi_8^{\mathrm{MUB}}$ upon exact rational rounding. |

---

## Pillar 4 — Two-Stabilizer Tower, $n=5$ SOS Rupture & AME Magic Ceilings

| Claim ID | Statement | Tier | Lean Symbol | Verification Command | What Would Prove Us Wrong (Falsification) |
|---|---|---|---|---|---|
| `T4a` | Universal 3-stratum Parseval identity for $|\Psi_n(\theta)\rangle$ unifying $n=1$ ($4/3$, Tetrahedral SIC), $n=2$ ($7/4$, WH-MUB), and $n=3$ ($16/9$, Hoggar SIC). | `[LEAN-6K]` | `WeylMagic.Palomar.prove_t4a` | `cd lean && lake build` | Finding a discrepancy between the closed-form $\Phi_4(\Psi_n(\theta))$ polynomial and the direct $4^n$-Pauli sum at $n=1,2,3$. |
| `T4b` | At $n=4$, $\Phi_4(\Psi_4(t)) = \frac{1}{2}(6795t^4 - 13020t^3 + 9330t^2 - 2940t + 347)$ is strictly convex on $[0, 2/5]$ with unique stationary point solving $453t^3 - 651t^2 + 311t - 49 = 0$ bracketed in Lean by $(3774568/10^7, 3774569/10^7)$ (refined to 50 digits in Python `Decimal`), with $21505201/10^7 < \Phi_4(t_0) < 21505202/10^7$, strictly above $31/16$. | `[LEAN-6K]` | `WeylMagic.Palomar.prove_t4b` | `pytest -v tests/test_all.py -k pillar4` | Showing $453t^3-651t^2+311t-49$ has no sign change on the bracket or $\Phi_4(\Psi_4(t)) \le 31/16$ for some $t \in [0, 2/5]$. |
| `T4c` | At $n=5$, an explicit integer sum-of-squares decomposition proves $\Phi_4(\Psi_5(\theta)) \ge 3$ for all $\theta$, whereas the exact $\mathbb{Z}[i]^{32}$ rupture witness (`norm2=254`, `num4=11097089024`) achieves $\Phi_4 = 693568064/260144641 \approx 2.666086 < 3$. | `[LEAN-6K]` + `[EXACT-COMP]` | `WeylMagic.Palomar.prove_t4c` | `./build/test_weyl_magic && cargo test --release` | Exhibiting a $\theta$ with $\Phi_4(\Psi_5(\theta)) < 3$, OR finding that the 32-component witness does not give `num4 = 11097089024` and `norm2 = 254`. |
| `T4d` | Universal Cauchy–Schwarz ceiling on $k$-uniform and AME states: $\Phi_4(\mathrm{AME}(2,2)) \ge 2$, $\Phi_4(\mathrm{AME}(5,2)) \ge 1879/918$, $\Phi_4(\mathrm{AME}(6,2)) \ge 13/6$. | `[LEAN-6K]` | `WeylMagic.Palomar.prove_t4d` | `pytest -v tests/test_all.py -k ame` | Exhibiting a genuine $k$-uniform qubit state whose Pauli 4th moment strictly violates the Cauchy–Schwarz floor on the non-vanishing weight strata. |

---

## Pillar 5 — Divided-Power Characteristic-3 Alltop, Char-5 & Exact QGT

| Claim ID | Statement | Tier | Lean Symbol | Verification Command | What Would Prove Us Wrong (Falsification) |
|---|---|---|---|---|---|
| `T5a` | Elementary $\mathbb{F}_3$ carry-quadratic law and universal divided-power cross-term identity mod~9 (crediting Damski et al. `arXiv:2603.15550` for Galois-ring $\mathrm{GR}(9,n)$ char-3 MUB existence). | `[LEAN-6K]` | `WeylMagic.Palomar.prove_t5a` | `cd lean && lake build` | Exhibiting $x, a \in \mathbb{F}_3^n$ violating the $\mathbb{Z}_9$ carry-quadratic identity. |
| `T5b` | Universal bilinear Gauss-sum flat-modulus theorem in $\mathbb{Z}[\zeta_9]$: translation reindexing annihilating nonzero shifts forces $|\sum_{x<D}\chi(x)|^2 = D$. | `[LEAN-6K]` | `WeylMagic.Palomar.prove_t5b` | `cd lean && lake build` | Exhibiting a character sequence satisfying the diagonal/off-diagonal hypotheses whose squared modulus in $\mathbb{Z}[\zeta_9]$ differs from $D$. |
| `T5c` | Exact radix-3 FFT $\mathbb{Z}[\zeta_9]$ WH-MUB certificates for $W(3)^{\otimes 1,2,3}$ (`D = 3, 9, 27`, counts `(1,2,6,0)`, `(1,8,72,0)`, `(1,26,702,0)`) AND exact $\mathbb{Z}[\zeta_5]$ Alltop certificates for $W(5)^{\otimes 1,2}$ (`D = 5, 25`, counts `(1,4,20,0)`, `(1,24,600,0)`). Extended to $W(3)^{\otimes 4}$ (`D=81`, `(1,80,6480,0)`) in Rust & C11 (`[EXACT-COMP]`). | `[LEAN-6K]` (`[propext]`) + `[EXACT-COMP]` ($D=81$) | `WeylMagic.Palomar.prove_t5c` | `cargo test --release && ./build/test_weyl_magic` | Finding any displacement magnitude squared outside $\{0, D, D^2\}$ for the char-3 ($n \le 4$) or char-5 ($n \le 2$) Alltop fiducials. |
| `T5d` | Universal cleared-denominator Fubini–Study QGT metric for the two-stabilizer family: $g_{\theta\theta}(\theta) = (1 - D^{-1})/(2 + 2 D^{-1/2}\cos\theta)^2$, independently cross-checked via QGTL Richardson extrapolation (`max_rel_err = 1.224e-8`). | `[LEAN-6K]` (identity) + `[NUMERICAL-APPROX]` (QGTL check) | `WeylMagic.Palomar.prove_t5d` | `./build/qgtl_bridge && pytest -v tests/test_all.py -k qgt` | Computing $g_{\theta\theta}(\theta) = \langle\partial_\theta\Psi|\partial_\theta\Psi\rangle - |\langle\Psi|\partial_\theta\Psi\rangle|^2$ and finding any deviation from $(1-D^{-1})/(2+2D^{-1/2}\cos\theta)^2$. |

---

## Explicitly Open Questions (Not Claimed Proved)

| Open ID | Question | Status |
|---|---|---|
| `O1` | Does ANY non-equimodular $n=4$ qubit state achieve the WH-MUB bound $\Phi_4 = 31/16$? (Our `T2e` + `n4_z4_bent_hyperplane_rupture_arbitrary_bent` rule out all equimodular/Lagrangian states; C++20 L-BFGS numerical minimum over 64 starts is $2.150520154714$, matching $|\Psi_4(\theta^*)\rangle$, which is NOT proved globally optimal over $\mathbb{C}^{16}$.) | `[OPEN]` |
| `O2` | Does the strong form of the even-$n$ WH-MUB nonexistence obstruction hold for all even $n \ge 6$? | `[OPEN]` |
| `O3` | Do non-cyclic WH-SIC fiducials exist in $W(4)\otimes W(2)$ or $W(4)\otimes W(4)$? (Pillar 3 establishes a sharp logical dichotomy for Liu–Low–Yin Part~I; numerical Welch excesses are $6.19\times 10^{-2}$ and $2.57\times 10^{-2}$, not a formal exclusion.) | `[OPEN]` |
| `O4` | Are there closed-form algebraic families of Super-MUB maximizers in $W(4)\otimes W(2)$ and $W(4)\otimes W(4)$ as a continuous function of Rényi index $\alpha \in (1, \infty)$? | `[OPEN]` |
