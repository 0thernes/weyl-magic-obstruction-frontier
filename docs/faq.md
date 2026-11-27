<!-- SPDX-License-Identifier: CC-BY-4.0 -->
# Frequently Asked Questions (FAQ)

### 1. Why zero-Mathlib Lean 4.35.0 instead of Mathlib4?
A zero-Mathlib formalization keeps the trusted computing base tiny (core Lean 4.35.0 `Init` only), builds from clean in seconds without multi-gigabyte `.olean` caches, prevents upstream Mathlib API drift, and lets all **six independent bundled kernels** (`leanchecker`, `leanchecker-paranoid`, `lean4lean`, `nanoda`, `con-leche`, `con-ron`) replay the entire export cleanly. See [ADR 0001](adr/0001-zero-mathlib-lean4-palomar.md).

### 2. Does `PalomarChallenge.lean` contain `sorry`? Is that allowed?
Yes — by Palomar's specification (`lake comparator`), `PalomarChallenge.lean` is the *statement-only* challenge stub containing `sorry` placeholders for the 23 theorem targets. `PalomarSolution.lean` contains **zero** `sorry` and **zero** custom axioms; `lake comparator --config comparator.json --paranoid` proves that `PalomarSolution` matches every statement in `PalomarChallenge` definitionally and uses only `[propext, Classical.choice, Quot.sound]`.

### 3. Does Pillar 2 prove that no $n=4$ qubit state at all can achieve the WH-MUB bound $\Phi_4 = 31/16$?
No. Theorem `T2e` rules out all **equimodular** $n=4$ qubit states ($|c_x| = 1/4$ for all $x \in \mathbb{F}_2^4$). Our C++20 Riemannian L-BFGS numerical search across $\mathbb{C}^{16}$ reaches $\Phi_4 \approx 2.150520154714$ (matching $|\Psi_4(\theta^*)\rangle$), but global optimality over non-equimodular states in $\mathbb{C}^{16}$ remains `[OPEN]`.

### 4. Why do `v42` and `v44` lose at $\alpha = 4$ if direct L-BFGS re-optimization beats WH-MUB at $\alpha = 4$?
Because Super-MUB maximizers in $W(4)\otimes W(2)$ and $W(4)\otimes W(4)$ do **not** have a flat Weyl–Heisenberg spectrum! Minimizing $\Phi_4$ ($\alpha=2$) produces a non-uniform spectrum whose higher moments ($\Phi_8$, $\alpha=4$) overtake the flat WH-MUB baseline, whereas re-optimizing directly for $\Phi_8$ shifts the state to a slightly flatter non-MUB spectrum that still beats WH-MUB at $\alpha=4$.

### 5. Are QGTL, Moonlab WASM, Eshkol AD, and `qrng_stream.c` running on a quantum computer?
No. All four are strictly **deterministic classical CPU** cross-checks (finite-difference differential geometry, WASM double-precision state-vector simulation, automatic differentiation, and SplitMix64/Xoshiro256++ pseudorandom stream seeding). See [LIMITATIONS.md](../LIMITATIONS.md).

### 6. How does Pillar 5 relate to Damski et al. (`arXiv:2603.15550`)?
Damski et al. established the existence of complete characteristic-3 Weyl–Heisenberg MUBs via Galois rings $\mathrm{GR}(9,n)$. Our Pillar 5 (`T5a`–`T5b`) provides an elementary $\mathbb{Z}_9$ divided-power carry formulation, a universal bilinear Gauss-sum flat-modulus theorem, and machine-checked Lean 4.35.0 $\mathbb{Z}[\zeta_9]$ certificates for $n = 1, 2, 3$ (extended to $n = 4, D = 81$ in Rust and C11).

### 7. Has this work been peer-reviewed?
No. It is an independent machine-checked research preprint (`0TH-2026-021`). Machine checking guarantees logical validity relative to Lean 4.35.0's kernels and our stated definitions, not peer review.
