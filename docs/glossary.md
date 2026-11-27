<!-- SPDX-License-Identifier: CC-BY-4.0 -->
# Glossary

- **AME($n, d$) (Absolutely Maximally Entangled state):** Pure $n$-qudit state of local dimension $d$ that is $\lfloor n/2 \rfloor$-uniform (every reduced density matrix of size $\le \lfloor n/2 \rfloor$ is maximally mixed).
- **ANF (Algebraic Normal Form):** Unique representation of a Boolean function $f: \mathbb{F}_2^n \to \mathbb{F}_2$ as a multilinear polynomial over $\mathbb{F}_2$. Its maximum monomial weight is $\deg_{\mathrm{ANF}}(f)$.
- **Bent function:** Boolean function $f: \mathbb{F}_2^{2m} \to \mathbb{F}_2$ whose Walsh–Hadamard transform satisfies $|\widehat{(-1)^f}(u)| = 2^m$ for all $u \in \mathbb{F}_2^{2m}$. By Rothaus's theorem (`T2c`), $\deg_{\mathrm{ANF}}(f) \le m$ for all $m \ge 2$.
- **Divided-power carry polynomial:** Elementary $\mathbb{Z}_9$ lift of a cubic $\mathbb{F}_3$ polynomial encoding the carry quadratic term required to produce flat displacement magnitudes in $W(3)^{\otimes n}$.
- **Equimodular state:** Pure state $|\psi\rangle = D^{-1/2} \sum_x e^{i\phi_x} |x\rangle$ whose computational-basis amplitudes all have equal modulus $D^{-1/2}$.
- **FWHT (Fast Walsh–Hadamard Transform):** $O(N \log N)$ butterfly transform over $\mathbb{F}_2^n$; implemented in exact `Int`/`i128`/`i64` across Lean, Rust, Zig, C11, and baseline x86-64 NASM.
- **Palomar Challenge/Solution:** Standardized Lean 4 verification split where `PalomarChallenge.lean` defines theorem types (`sorry`-stubbed) and `PalomarSolution.lean` supplies axiom-clean proofs verified via `lake comparator --paranoid`.
- **QGT (Quantum Geometric Tensor / Fubini–Study metric):** $g_{\theta\theta}(\theta) = \langle \partial_\theta\Psi | \partial_\theta\Psi \rangle - |\langle \Psi | \partial_\theta\Psi \rangle|^2$, proved identically equal to $(1 - D^{-1})/(2 + 2 D^{-1/2}\cos\theta)^2$ for $|\Psi_n(\theta)\rangle$ (`T5d`).
- **Rothaus degree bound:** Classical theorem (Rothaus 1976) proving every bent function on $\mathbb{F}_2^{2m}$ ($m \ge 2$) has algebraic degree at most $m$; proved universally in Lean 4.35.0 (`T2c`).
- **SOS (Sum-of-Squares) certificate:** Algebraic identity expressing a non-negative polynomial as a sum of squared polynomials with positive rational coefficients, used in `T4c` to prove $\Phi_4(\Psi_5(\theta)) \ge 3$ unconditionally.
- **Stabilizer Rényi Entropy ($M_\alpha$) & Moment ($\Phi_{2\alpha}$):** For a $D$-dimensional pure state and projective Weyl–Heisenberg operator basis $\mathcal{W}$, $\Phi_{2\alpha}(\psi) = \sum_{W \in \mathcal{W}} |\langle\psi|W|\psi\rangle|^{2\alpha}$ and $M_\alpha(\psi) = \frac{1}{1-\alpha}\ln\bigl(\Phi_{2\alpha}(\psi) / D\bigr)$ in nats (minimizing $\Phi_{2\alpha}$ maximizes $M_\alpha$).
- **Super-MUB anomaly:** Pure state in a product Weyl–Heisenberg group (such as $W(4)\otimes W(2)$ or $W(4)\otimes W(4)$) achieving strictly smaller $\Phi_{2\alpha}$ (higher magic $M_\alpha$) than an exact WH-MUB fiducial in the same group.
- **WH-MUB fiducial:** Pure state whose displacement expectations satisfy $|\langle\psi|D_g|\psi\rangle|^2 \in \{0, D^{-1}, 1\}$ with multiplicity $\{D-1, D^2-D, 1\}$, yielding $\Phi_{2\alpha}^{\mathrm{MUB}} = 1 + (D-1)D^{1-\alpha}$.
- **2-adic valuation ($v_2(k)$):** Largest non-negative integer $r$ such that $2^r \mid k$. Used in Pillar 1 (`T1a`–`T1c`) via $v_2(2^n(2^n-2)^2) = n + 2$.
