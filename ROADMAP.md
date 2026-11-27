<!-- SPDX-License-Identifier: CC-BY-4.0 -->
# ROADMAP.md

## Released (`v1.0.0` — 2026-11-26)
- Complete zero-Mathlib Lean 4.35.0 6-kernel formalization of all 5 pillars (`T1a`–`T5d`, 23 Palomar targets, 5 non-vacuity witnesses, 8 adversarial refutations).
- Nine-engine polyglot exact & numerical cross-verification stack (Lean 4.35.0, Rust, Zig, ISO C11, x86-64 NASM, C++20, Python, QGTL, Moonlab WASM, Eshkol AD).
- Zero-warning 14-page AMS-LaTeX preprint + clean-room `dist/arxiv_submission.tar.gz`, WebGL2 Observatory, Proof Blueprint DAG, RFC 3161 + OpenTimestamps provenance, and archive registration as `0TH-2026-020`.

## Near-Term (`v1.1.x`)
- **Palomar Registry submission:** Submit the pinned 40-character `v1.0.0` commit SHA to `palomar-registry.org` and record the registry URL in `README.md` and `CITATION.cff`.
- **Exact algebraic $\alpha = 4$ Super-MUB witnesses:** Upgrade empirical C++20 L-BFGS `E3-LBFGS` results ($\Phi_8 < \Phi_8^{\mathrm{MUB}}$ in $W(4)\otimes W(2)$ and $W(4)\otimes W(4)$) from `[NUMERICAL-APPROX]` to exact cyclotomic `[LEAN-6K]` witnesses.
- **Lean kernel $n = 4$ char-3 Alltop certificate (`D = 81`):** Extend `T5b` from $n \le 3$ (`D = 27`) inside Lean 4.35.0 to $n = 4$ (`D = 81`, already verified in Rust and C11) via radix-3 divide-and-conquer reflection.

## Medium-Term (`v1.2.x` / Open Problems)
- **Non-equimodular $n = 4$ barrier (`O1`):** Investigate branch-and-bound / SDP sum-of-squares certification over $\mathbb{C}^{16}$ to determine whether $|\Psi_4(\theta^*)\rangle$ ($\Phi_4^* \approx 2.150520$) is globally optimal.
- **Even $n \ge 6$ quaternary rupture (`O2`):** Analyze whether degree-3 bent functions on $\mathbb{F}_2^6$ avoid the 3-hyperplane zero-sum parity obstruction or trigger a higher-order 7-hyperplane rupture.
- **Mathlib helper upstreaming:** Contribute self-contained helper lemmas (2-adic valuation parity, Rothaus degree bound, radix-3 FFT identities) to Mathlib under Apache-2.0.
