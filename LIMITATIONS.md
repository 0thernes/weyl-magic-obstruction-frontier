<!-- SPDX-License-Identifier: CC-BY-4.0 -->
# LIMITATIONS.md — Scope, Epistemic Boundaries, and Real vs. Metaphor

This document states explicitly what `weyl-magic-obstruction-frontier` (`0TH-2026-022`) **does not prove**, where its formal guarantees stop, and how classical software cross-checks are distinguished from physical quantum claims.

## 1. Mathematical & Formal Scope Boundaries

1. **Non-peer-reviewed preprint:** All theorems in `lean/` are machine-checked by Lean 4.35.0 and five additional external kernels, which guarantees logical derivation from standard Lean axioms (`propext`, `Classical.choice`, `Quot.sound`) — **not** peer review, mathematical significance, or immunity to specification mismatch. Readers should audit `lean/PalomarChallenge.lean` and `lean/WeylMagic/Basic.lean` directly to verify statement fidelity.
2. **$n=4$ Equimodularity Hypothesis (`T2e`):** Theorem `T2e` rules out **equimodular** $n=4$ qubit WH-MUB states (states with equal computational-basis magnitudes $|c_x| = 1/4$). While our C++20 Riemannian L-BFGS search (`64` starts, reaching $\Phi_4 \approx 2.150520154714$) finds no non-equimodular state below the two-stabilizer stationary point $|\Psi_4(\theta^*)\rangle$, **global optimality of $|\Psi_4(\theta^*)\rangle$ over all of $\mathbb{C}^{16}$ is NOT formally proved** (`[OPEN]`).
3. **Even $n \ge 6$ Qubits:** Pillar 1 (`T1b`) is unconditional for **all odd $n \ge 3$**. The even-$n$ quaternary bent-hyperplane analysis in Pillar 2 is proved universally up to Rothaus's bound (`T2c`, all $m \ge 2$) and completed through the exhaustive 3-hyperplane zero-sum contradiction specifically at $n = 4$ (`T2d`, `T2e`). The strong form for even $n \ge 6$ remains `[OPEN]`.
4. **Characteristic-3 Alltop Prior Work & Scope:** Existence of complete Weyl–Heisenberg MUBs in characteristic $3$ via Galois rings $\mathrm{GR}(9, n)$ is established by Damski et al. (`arXiv:2603.15550`). Our Pillar 5 contribution (`T5a`–`T5b`) is an elementary $\mathbb{Z}_9$ divided-power carry formulation and machine-checked Lean 4.35.0 $\mathbb{Z}[\zeta_9]$ certificates for $n = 1, 2, 3$ (plus exact Rust/C11 verification at $n = 4$, `D = 81`). Lean kernel verification for $n \ge 4$ is not claimed inside Lean (it is `[EXACT-COMP]`, not `[LEAN-6K]`).
5. **Pillar 3 $\alpha = 4$ Re-Optimization:** While `v42` and `v44` are machine-checked (`[LEAN-6K]`, 0 axioms) to beat WH-MUB at $\alpha = 2, 3$ and lose at $\alpha = 4$, the further finding that direct L-BFGS re-optimization at $\alpha = 4$ still beats WH-MUB (`1.012971 < 1.013672` and `1.003658 < 1.003662`) is strictly `[NUMERICAL-APPROX]` until exact algebraic $\alpha = 4$ witnesses are constructed.
6. **Zero-Mathlib Trust Base Tradeoff:** Avoiding Mathlib keeps the trust base tiny (~3 seconds cold build, zero external Lean dependencies) and eliminates dependency drift, but means algebraic structures (finite fields, cyclotomic rings, Fubini–Study fractions) are encoded directly in `lean/WeylMagic/Basic.lean` rather than reusing Mathlib's `ZMod`/`CyclotomicField` APIs.

## 2. Real vs. Metaphor (Classical Cross-Checks vs. Quantum Hardware)

| Component | What It Actually Is (Real) | What It Is NOT (Explicit Disclaimer) |
|---|---|---|
| **QGTL (`third_party/qgtl`, `c/src/qgtl_bridge.c`)** | Classical C11 finite-difference Richardson extrapolation of the Fubini–Study metric tensor on CPU. | Not a quantum computer, not a formal proof, not a physical quantum experiment. |
| **Moonlab (`third_party/moonlab`, `node/moonlab_crosscheck.cjs`)** | Classical WebAssembly CPU state-vector simulator cross-checking double-precision expectations to $1.33 \times 10^{-14}$. | Not a physical quantum processor or hardware noise benchmark. |
| **QRNG Stream (`c/src/qrng_stream.c`)** | Deterministic classical SplitMix64 + Xoshiro256++ pseudorandom stream (MIT-licensed, bit-exact across C11, Node BigInt, and Python) used to seed multi-start L-BFGS and differential fuzzers reproducibly. | Not physical quantum random number generation; explicitly deterministic for reproducibility. |
| **Eshkol (`eshkol/magic_qgt_ad.esk`)** | Classical automatic-differentiation script checking $d\Phi_4/dt|_{t^*}=0$ and 2nd-order QGT curvature. | Not a deductive symbolic proof engine; the formal proof lives in Lean `T4b` and `T5d`. |
| **WebGL2 Observatory (`docs/site/index.html`)** | Client-side 3D visualization of frozen verified JSON curves and exact $\alpha$-crossover data. | Not a live compute backend or scientific oracle. |

## 3. AI-Assistance & Authorship Disclosure

This repository, its Lean 4.35.0 proofs, polyglot verifiers, and AMS-LaTeX manuscript were developed by Alexander Stephen Donahue (`Independent Researcher, Spokane, WA, USA`, ORCID `0009-0006-8168-9648`) with substantial AI assistance (Google Antigravity / Gemini agentic workflows) under human direction, specification, and verification. Every deductive mathematical claim rests exclusively on deterministic machine-checked Lean 4.35.0 kernels and independent exact arithmetic verifiers — never on unverified LLM prose.

## 4. Infrastructure & Platform Limitations

- **Windows vs. Linux `bwrap` sandboxing:** `lake check --paranoid` and `lake comparator --paranoid` require Linux `bubblewrap` (`bwrap`) for OS-level sandboxing; on Windows, local runs require `--inadvisably-no-sandbox`, while full `bwrap`-sandboxed 6-kernel replay executes in Ubuntu GitHub Actions CI.
- **Tectonic Network Fetch:** First-time local Tectonic compilation downloads TeX Live bundles on demand unless cached; the frozen PDF and clean-room `dist/arxiv_submission.tar.gz` are committed and checksummed for offline inspection.
