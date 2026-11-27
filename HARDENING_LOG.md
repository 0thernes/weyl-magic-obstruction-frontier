<!-- SPDX-License-Identifier: CC-BY-4.0 -->
# HARDENING_LOG.md — Three-Cycle Forensic Hardening Audit (`0TH-2026-022`)

Every defect, discrepancy, visual glitch, epistemic risk, or coverage gap uncovered across all three full hardening cycles is permanently logged below using the ten canonical finding classes of **Build Standard for LLMs v1.2.0** (`bug`, `error`, `issue`, `problem`, `concern`, `dilemma`, `conflict`, `gap`, `hole`, `blindspot`) and **Defensible Independent AI Research Playbook v1.3**.

---

## Summary Ledger

| Cycle | Focus | Findings Logged | Resolved | Open |
|---|---|---|---|---|
| **Pre-Freeze Build** | Lean 4.35.0 formalization, polyglot build, LaTeX clean-room | 10 | 10 | 0 |
| **Cycle 1** | 90-item Build Standard audit, Palomar 6-kernel replay, forbidden token & LLC sweeps, CSP & site validation | 4 | 4 | 0 |
| **Cycle 2** | Deep cross-file mathematical consistency, 14-page rendered PDF visual inspection, LF normalization, symbol fidelity | 8 | 8 | 0 |
| **Cycle 3** | Figure label micro-alignment, Ruff/Mypy strictness, SHA-256 manifests, live RFC 3161 + OpenTimestamps freeze, clean-tree audit | 2 | 2 | 0 |
| **v1.1.0 Hostile Red-Team (Cycles 1–3)** | Draft 2020-12 `repo.yaml` schema, true 9-mutant source mutation testing, live title+retraction citation audit (`Leone2022SRE` fixed), arbitrary-bent $n=4$ Lean bridge + nontrivial $n=2$ non-vacuity (`38/38` axioms), `B44: partial` honesty, Eshkol/QRNG/PROVENANCE/glossary fixes, 2D fallback + WCAG keyboard nav | 18 | 18 | 0 |
| **Total** | **All Cycles Complete** | **42** | **42** | **0** |

---

## Pre-Freeze Formalization & Polyglot Build Catches

| ID | Class | Location | Finding | Resolution & Verification |
|---|---|---|---|---|
| `P-01` | `bug` | `lean/WeylMagic/TwoStabilizerTower.lean` | Early draft had factor-of-2 mismatch (`4*` vs `8*` at $D=2$) and constant term sign error at $D=16$. | Caught immediately by Lean 4.35.0 kernel; corrected and proved identically (`prove_t4a`, `prove_t4b`). |
| `P-02` | `error` | `lean/WeylMagic/Char3AlltopAndQGT.lean` | Initial candidate cubic $t^3 - 2t - 1$ over $\mathbb{F}_3$ had root $t = 2$ (reducible). | Replaced by irreducible $t^3 + 2t + 1 = 0$ yielding exact `(1, 26, 702, 0)`; preserved reducible polynomial permanently as Adversarial Refutation #8 (`refute_reducible_char3_poly`). |
| `P-03` | `error` | `eshkol/magic_qgt_ad.esk`, `node/moonlab_crosscheck.cjs` | 8th-digit truncation in $t^*$ (`0.37745687` vs exact `0.3774568011835382`). | Caught by 50-digit `Decimal` Newton–Raphson; fixed (Moonlab error dropped from `9.74e-13` to `1.33e-14`). |
| `P-04` | `concern` | `c/src/qgtl_bridge.c`, `tests/test_all.py` | Naive finite-difference `acos(1 - 1e-11)` lost digits at `eps = 1e-5`. | Upgraded to Richardson extrapolation (`eps1=1e-3, eps2=5e-4`), cutting max relative error to `1.224e-8`. |
| `P-05` | `dilemma` | `lean/WeylMagic/Char3AlltopAndQGT.lean` | Naive $O(D^3)$ triple sum for $W(3)^{\otimes 3}$ (`D=27`) exceeded Lean default `maxHeartbeats`. | Implemented radix-3 cyclotomic FFT (`fft3Z9`), achieving ~9× speedup well under default heartbeats without raising limits. |
| `P-06` | `issue` | `rust/src/lib.rs`, `zig/src/main.zig` | 6 Clippy lints in Rust (`add`/`mul` naming, indexed loops) and Zig 0.17 array init syntax. | Renamed `Zeta9::plus/times`, refactored to iterators, switched to `@splat(0)`; `clippy -D warnings` and `zig test` pass with 0 warnings. |
| `P-07` | `conflict` | `paper/main.tex`, `paper/references.bib` | BibTeX missing-pages warning on `@article{Liu2026MaximalMagic}` and minor overfull/underfull hboxes. | Converted to `@misc` with arXiv `howpublished` and tightened layout; Tectonic compiles with literal **0** warnings on both local and clean-room tarball builds. |
| `P-08` | `hole` | `docs/site/index.html` | Raw `$...$` LaTeX tokens present in zero-CDN HTML (would render unparsed without MathJax/KaTeX). | Replaced all math with native Unicode + semantic `<sub>`/`<sup>` HTML; enforced permanently by `scripts/verify_site.py`. |
| `P-09` | `blindspot` | `lean/` | Palomar Registry requires `module` header on every `.lean` file, `lake-manifest.json`, and 6-kernel replay via `lake comparator --paranoid`. | Verified `module` header on 100% of `.lean` files, committed `lake-manifest.json`, and passed all 6 kernels (`Lean paranoid`, `lean4lean`, `nanoda`, `con-leche`, `con-ron`, `Lean default`) with `CHECK_EXIT=0` and `COMP_EXIT=0`. |
| `P-10` | `problem` | Global author metadata | Earlier independent work used non-existent entity name in affiliation/copyright lines (Playbook v1.3 Finding 1). | Enforced `Alexander Stephen Donahue` (`Independent Researcher, Spokane, WA, USA`, ORCID `0009-0006-8168-9648`) and dual Apache-2.0 / CC-BY-4.0 REUSE 3.3 across 100% of files; verified zero false entity claims via repo-wide sweep. |

---

## Cycle 1 — Build Standard 90-Item Audit, Security & Formal Sweeps

| ID | Class | Location | Finding | Resolution & Verification |
|---|---|---|---|---|
| `C1-1` | `hole` | `docs/site/index.html`, `docs/site/blueprint.html` | Content Security Policy used `default-src 'self'` instead of strict `default-src 'none'`. | Tightened both pages to `default-src 'none'; style-src 'unsafe-inline'; script-src 'unsafe-inline'; img-src 'self' data:; connect-src 'none'; font-src 'none'; object-src 'none'; base-uri 'none'; form-action 'none';`; verified by `scripts/verify_site.py`. |
| `C1-2` | `gap` | `.github/labels.yml` | Build Standard item `A30` failed: `.github/labels.yml` for the 10 finding classes was missing. | Created `.github/labels.yml` containing all 10 finding-class labels (`bug` through `blindspot`) and applied them to the GitHub repository. |
| `C1-3` | `gap` | `justfile`, `repo.yaml`, `c/tests/cbmc_harness.c`, `scripts/mutation_check.py` | Missing `reproduce`/`rollback` recipes (`B01`/`A36`), `A37`/`B27` manual declarations, CBMC bounded harness (`B25`), libFuzzer entry (`B15`), and executable mutation harness (`B13`). | Implemented `cbmc_harness.c`, `LLVMFuzzerTestOneInput`, `mutation_check.py` (`7/7` mutants killed), `justfile` recipes, and `repo.yaml` entries. |
| `C1-4` | `gap` | `docs/reviews/`, Git history | `A23` (no commits yet) and `B45` (missing `docs/reviews/*.md`) flagged by `Audit-Repo.ps1`. | Authored `docs/reviews/2026-11-26-three-cycle-forensic-audit.md` and committed directly to `main`; `Audit-Repo.ps1` reaches **100.0%**. |

---

## Cycle 2 — Deep Cross-File Semantic, Mathematical & Visual PDF Audit

| ID | Class | Location | Finding | Resolution & Verification |
|---|---|---|---|---|
| `C2-1` | `bug` | `src/weyl_magic/oracle.py:345` | Stale 8th-digit typo `Decimal("0.37745687")` remained as Newton–Raphson initial guess (converged correctly, but left a stale digit string in source). | Updated initial guess to `Decimal("0.37745680")`; repo-wide grep confirms zero occurrences of `0.37745687` outside historical logs. |
| `C2-2` | `issue` | `data/*.json`, `results/lean_axioms.txt`, `scripts/generate_data.py` | 6 frozen data/result files had Windows CRLF (`\r\n`) line endings (plus UTF-8 BOM on `lean_axioms.txt`). | Normalized all 6 files to pure UTF-8 LF (no BOM) and updated `generate_data.py` to open outputs with `newline="\n"`. |
| `C2-3` | `conflict` | `README.md`, `scripts/mutation_check.py` | Initial usage snippet in `README.md` referenced idealized wrapper names (`verify_bent4_exhaustive`) instead of actual exported symbols (`audit_all_f2_4_bent`, `wh_gauss_moments`, etc.). | Updated `README.md` and `scripts/mutation_check.py` to call exact exported symbols from `weyl_magic.oracle` and verified execution. |
| `C2-4` | `bug` | `scripts/generate_figures.py` (`fig2`, `fig5`) | Visual inspection of rendered 14-page PDF pages 9 and 12 revealed literal `R\'enyi` on matplotlib axes (`usetex=False`). | Replaced with Unicode `Rényi` and visually re-verified both rebuilt vector PDF figures. |
| `C2-5` | `issue` | `scripts/generate_figures.py` (`fig3`, `fig4`) | Visual inspection of PDF page 10 revealed literal double hyphens `--` in `Fubini--Study`, `Entanglement--Magic`, and `Cauchy--Schwarz`. | Replaced with Unicode en-dash `–` and visually re-verified rebuilt PDF figures. |
| `C2-6` | `issue` | `paper/main.tex:765` | Visual inspection of PDF page 13 caught double period `AI-Assistance Disclosure and CRediT..` caused by `amsart`'s `\@addpunct` after uppercase `T.`. | Removed trailing periods inside `\paragraph{...}` arguments so `amsart` appends exactly one period on all three headings. |
| `C2-7` | `issue` | `paper/references.bib` (`Damski2026ProductWH`, `Knipfer2026TwoQutrit`) | Visual inspection of PDF page 14 showed `amsplain` omits `eprint` fields, hiding arXiv IDs `2603.15550` and `2607.07197` in the printed bibliography. | Added explicit `howpublished = {arXiv:... [quant-ph]}` fields; rebuilt PDF with zero warnings. |
| `C2-8` | `concern` | `CLAIMS.md` (`T4b`) | `CLAIMS.md` cited the 11-digit Python bracket `(37745680118/10^11, 37745680119/10^11)` rather than explicitly stating Lean's exact 7-digit kernel bracket `(3774568/10^7, 3774569/10^7)` on `[0, 2/5]`. | Aligned `CLAIMS.md` verbatim with `n4_two_stab_cubic_exact` and `n4_cubic_strictly_monotone_on_interval`, noting the 50-digit Python refinement separately. |

---

## Cycle 3 — Micro-Typography, Lint Strictness & Cryptographic Provenance Freeze

| ID | Class | Location | Finding | Resolution & Verification |
|---|---|---|---|---|
| `C3-1` | `issue` | `scripts/generate_figures.py` (`fig2`, `fig4`) | Visual re-inspection showed `AME(2,2) >= 2` slightly grazing the left y-axis spine in `fig4`, and the `alpha = 4` crossover label slightly clipped below `y = 0` in `fig2`. | Adjusted `fig4` `AME(2,2)` offset rightward (`+0.08`) and expanded `fig2` y-axis lower bound to `-0.0048`; visually verified clean margins and zero TeX warnings. |
| `C3-2` | `issue` | `scripts/verify_site.py:26` | `uvx ruff check` flagged `E501` (line length 121 > 120). | Extracted `cdns` tuple onto preceding line; `ruff check` (`0` errors) and `mypy --strict` (`0` errors) both pass cleanly. |

---

## v1.1.0 Hostile 3-Cycle Red-Team Audit (2026-11-27)

Full 18-finding table covering all 10 Build Standard v1.2.0 classes (`bug`, `error`, `issue`, `problem`, `concern`, `dilemma`, `conflict`, `gap`, `hole`, `blindspot`) and Playbook v1.3 Gold Standard checks is archived in [docs/reviews/2026-11-27-hostile-red-team-v1.1.0-audit.md](docs/reviews/2026-11-27-hostile-red-team-v1.1.0-audit.md). Key high-severity catches resolved at root cause:

- **`R1-05` (`hole` — real bibliographic bug):** Upgrading `scripts/check_citations.py` from HTTP-200-only to live title/author/XML/both-direction retraction auditing caught a real 1-digit wrong arXiv ID on `Leone2022SRE` (`2106.12567` → `2106.12587`). All `17/17` entries (`14` DOIs + `10` arXiv IDs) now pass live checks.
- **`R1-01` (`conflict`):** `repo.yaml` previously failed strict Draft 2020-12 `repo-standard.schema.json` validation; rewritten strictly schema-compliant with `B44: partial` (honestly noting third-party human replication remains open) and enforced permanently in `tests/test_all.py`.
- **`R1-02` (`hole`):** Replaced arithmetic tautologies in `scripts/mutation_check.py` with true isolated source-code mutation testing injecting 9 production mutants into `src/weyl_magic/oracle.py` and running real `pytest` subprocesses (`9/9` killed).
- **`R1-06` & `R1-07` (`hole`, `gap`):** Added nontrivial $n=2$ Pauli idempotence non-vacuity (`nonvacuity_pillar1_n2_mub_spectrum`, $K=4 \ne 0$) and kernel-closed arbitrary-bent $n=4$ bridge (`n4_z4_bent_hyperplane_rupture_arbitrary_bent`) inside Lean 4.35.0 (`38/38` audited declarations strictly within `[propext, Classical.choice, Quot.sound]`), plus `docs/statement-fidelity.md`.
- **`R1-24`, `R2-01`, `R2-02`, `R2-17` (`error`, `dilemma`):** Removed stale `ks31` residue from `third_party/{qgtl,moonlab}/PROVENANCE.md`, corrected `tsotchke/quantum_rng` attribution (removing wrong `Xoshiro256++` labels), fixed the $\Phi_{2\alpha}$/$\ln$ formula in `docs/glossary.md`, aligned `CLAIMS.md` 1-to-1 with `Challenge.lean`, removed unarchived `"2,000+"`/`"278"` restart counts, honestly labeled `eshkol/magic_qgt_ad.esk` as a source-level companion spec not run in CI, and added 2D Canvas fallback + WCAG 2.2 AA keyboard navigation to `docs/site/`.
