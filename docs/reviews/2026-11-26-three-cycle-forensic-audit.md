<!-- SPDX-License-Identifier: CC-BY-4.0 -->
# Three-Cycle Forensic & Red-Team Audit Report (`0TH-2026-022`)

- **Date:** 2026-11-26
- **Target Repository:** `weyl-magic-obstruction-frontier` (`v1.0.0`, Archive ID `0TH-2026-022`)
- **Frameworks Applied:**
  1. **Build Standard for LLMs v1.2.0** (90 items across Part A & Part B, hard rules R1–R8, 10 finding classes).
  2. **Defensible Independent AI Research Playbook v1.3** (10-pass review protocol, 6-kernel Palomar verification, statement-fidelity audit, honest epistemic boundaries, legal/identity review).
- **Auditor Role:** Internal red-team / adversarial self-audit prior to `v1.0.0` freeze and GitHub publication (**not** external independent journal peer review).

---

## 1. Ten-Pass Playbook v1.3 Verdict Matrix

| Pass | Scope | Result | Evidence |
|---|---|---|---|
| **Pass 1 — Lean 4.35.0 Clean Build & Axioms** | Zero-Mathlib build, forbidden tokens, `#print axioms` | **PASS** | `lake build` (17 jobs, 0 warnings), `lake build PalomarChallenge` (10 jobs). `VerifyAxioms.lean` audits **36/36** declarations strictly within `[propext, Classical.choice, Quot.sound]`; `prove_t3c/d/e` use **0** axioms. Zero `sorry` outside isolated `PalomarChallenge.lean`. |
| **Pass 2 — Six-Kernel Palomar Replay** | `lake check --paranoid` + `lake comparator --config comparator.json --paranoid` | **PASS** | All 6 independent kernels (`Lean paranoid`, `lean4lean` 58,675 decls, `nanoda`, `con-leche` 58,678 decls, `con-ron` 58,678 decls, `Lean default`) accepted both full export (`CHECK_EXIT=0`) and all 23 Palomar targets (`COMP_EXIT=0`). Tamper-injecting negative gate verified in CI. |
| **Pass 3 — Statement Fidelity & Adversarial Tests** | Literature alignment + non-vacuity + boundary refutations | **PASS** | `NonVacuity.lean` (5 witnesses) + `AdversarialTests.lean` (8 refutations: $n=1,2$ sharpness, Rothaus $m=1$, odd power-of-2 Fermat failure, `v42`/`v44` $\alpha=4$ crossover, $n=5$ tower rupture, $n=4$ MUB gap, reducible char-3 cubic). Exact alignment verified between `TwoStabilizerTower.lean` and `CLAIMS.md` (`C2-8`). |
| **Pass 4 — Polyglot Differential Exact Consensus** | Rust, Zig, C11, x86-64 NASM, Python, `reference/oracle.py` | **PASS** | 100% exact bit-for-bit agreement across all 5 exact languages on 896 bent functions, `v42`, `v44`, `n=5` rupture (`11097089024/254^4`), and char-3 Alltop (`D=3,9,27,81`). `162/162` pytest tests, `7/7` mutation kills, `100k`/`25k` fuzzing, and CBMC harness all PASS. |
| **Pass 5 — Classical Cross-Check Honesty** | QGTL, Moonlab WASM, Eshkol AD, `qrng_stream.c`, C++20 L-BFGS | **PASS** | Explicitly labelled `[NUMERICAL-APPROX]` and **classical CPU** throughout `README.md`, `CLAIMS.md`, `LIMITATIONS.md`, `paper/main.tex`, and `docs/site/`. Zero quantum-hardware overclaims. |
| **Pass 6 — Live Literature & Citation Integrity** | DOI / arXiv resolution & retraction screening | **PASS** | `scripts/check_citations.py` checked 14 DOIs + 10 arXiv IDs live against Crossref & arXiv APIs: **0 failures, 0 retractions**. Damski et al. (`arXiv:2603.15550`) explicitly credited for $\mathrm{GR}(9,n)$ existence. `C2-7` fixed missing arXiv IDs in printed bibliography. |
| **Pass 7 — Visual PDF & Figure Inspection** | Page-by-page inspection of 14-page `amsart` PDF & 5 vector figures | **PASS** | Caught and fixed `R\'enyi` axis typography (`C2-4`), `--` en-dashes (`C2-5`), double period on `CRediT..` (`C2-6`), and micro-margin label placement (`C3-1`). Rebuilt with **0** TeX/BibTeX/overfull/underfull warnings on both local and clean-room `dist/arxiv_submission.tar.gz` builds. |
| **Pass 8 — Web Observatory & Blueprint Security/A11y** | Zero-CDN, strict CSP, WCAG 2.2 AA, 23 Palomar targets | **PASS** | Tightened CSP to `default-src 'none'` (`C1-1`); `scripts/verify_site.py` verifies 0 CDN URLs, 0 raw `$...$` LaTeX tokens, `<main>`/`lang="en"`, and all 23 Palomar targets. |
| **Pass 9 — Legal, Identity, Dual Licensing & AI Disclosure** | Author identity, REUSE 3.3, CRediT, no false LLC | **PASS** | `Alexander Stephen Donahue (Independent Researcher, Spokane, WA, USA; ORCID 0009-0006-8168-9648)` everywhere; zero corporate entity claims; Apache-2.0 (code) + CC-BY-4.0 (docs/paper/data) in `REUSE.toml`; transparent AI-assistance disclosure in paper & `LIMITATIONS.md`. |
| **Pass 10 — Provenance, Clean Tree & Build Standard Score** | `MANIFEST.sha256`, `.tsr`, `.ots`, SLSA, `Audit-Repo.ps1` | **PASS** | Frozen SHA-256 digests (`25` root + `5` data files), genuine DigiCert RFC 3161 `.tsr` (5,996 B), Bitcoin OpenTimestamps `.ots` (272 B), SLSA CI attestation, and **100.0%** Build Standard v1.2.0 score (`75/75` applicable items PASS, 0 fail, 0 partial, 0 unknown). |

---

## 2. Adversarial Red-Team Questions & Honest Verdicts

1. **Could `PalomarSolution.lean` subtly weaken a theorem from `PalomarChallenge.lean`?**
   - *Mitigated:* `lake comparator --config comparator.json --paranoid` enforces definitional type equality between `PalomarChallenge` and `PalomarSolution` across all 23 theorem targets in a sandboxed export replayed through 6 independent kernels, plus CI runs a deliberate tamper-injection test verifying that injecting `sorry` or a custom axiom causes comparator rejection.
2. **Could the $n=4$ cubic state $|\Psi_4(\theta^*)\rangle$ be beaten by a non-equimodular state in $\mathbb{C}^{16}$?**
   - *Honest Boundary:* Yes, in principle — `T2e` rules out equimodular states only, and C++20 multi-start L-BFGS (`[NUMERICAL-APPROX]`) is heuristic. Both `paper/main.tex` and `CLAIMS.md` explicitly mark global optimality over $\mathbb{C}^{16}$ as `[OPEN]`.
3. **Could `W(4) \otimes W(2)` or `W(4) \otimes W(4)` admit an undiscovered WH-SIC?**
   - *Honest Boundary:* Godsil–Roy's proof applies to elementary abelian $W(2)^{\otimes n}$; therefore Pillar 3 is stated strictly as an exact logical dichotomy (`T3a`–`T3e`), with non-cyclic WH-SIC exclusion explicitly marked `[OPEN]`.

See [HARDENING_LOG.md](../../HARDENING_LOG.md) for the full 24-item finding ledger across Cycles 1–3.
