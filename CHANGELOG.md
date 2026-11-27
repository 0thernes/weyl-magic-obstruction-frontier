<!-- SPDX-License-Identifier: CC-BY-4.0 -->
# Changelog

All notable changes to `weyl-magic-obstruction-frontier` (`0TH-2026-022`) are documented in this file.

The format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.1.0] - 2026-11-27

### Added
- **Lean 4.35.0 Kernel-Closed Arbitrary-Bent $n=4$ Bridge (`WeylMagic.n4_z4_bent_hyperplane_rupture_arbitrary_bent`):** Directly invokes Rothaus's universal degree bound (`T2c`), exact $\mathbb{F}_2^4$ Möbius ANF reconstruction, and the 28-form hyperplane-triple rupture (`T2d`–`T2e`) inside the Lean 4 kernel for arbitrary `IsBent 2 f`.
- **Nontrivial $n=2$ Pauli Idempotence Non-Vacuity Witness (`WeylMagic.nonvacuity_pillar1_n2_mub_spectrum`):** Proves `IsScaledPauliMUBSpectrum 2 n2MubSign` directly from the $\mathbb{Z}[i]^4$ fiducial `(1, 1, 1, i)` with `pauliIdempRHS 2 n2MubSign 1 0 = 4 ≠ 0` (`38` audited declarations total in `VerifyAxioms.lean`).
- **Statement-Fidelity Audit (`docs/statement-fidelity.md`):** Line-by-line mapping of all 38 audited Lean declarations to manuscript claims with explicit disclosure of every paper-to-Lean bridge.
- **True Isolated Source-Code Mutation Testing (`scripts/mutation_check.py`):** Replaced arithmetic checks with 9 real production-code mutants injected into an isolated temp copy of `src/weyl_magic/oracle.py` verified via `pytest` subprocesses (`9/9` killed).
- **Strict Draft 2020-12 `repo.yaml` Schema Validation & Frozen-JSON Consistency Tests (`tests/test_all.py`):** Enforces `repo-standard.schema.json`, `CITATION.cff` + `VERSION` single-source-of-truth, and all 5 frozen JSON datasets in CI.
- **2D Canvas Fallback & WCAG 2.2 AA Keyboard Navigation (`docs/site/index.html`, `docs/site/blueprint.html`):** Added automatic 2D Canvas fallback when WebGL2 is absent, expanded Blueprint ledger to all 38 audited declarations, and added keyboard activation (`tabindex="0"`, Enter/Space, focus rings) on SVG nodes.

### Fixed
- **Live Bibliography Correction (`paper/references.bib` & `scripts/check_citations.py`):** Upgraded `check_citations.py` to live title/author matching, Atom `<entry>` XML parsing, and both-direction (`updated-by` & `update-to`) Crossref retraction screening — catching and correcting a 1-digit wrong arXiv ID on `Leone2022SRE` (`2106.12567` → `2106.12587`). All 17 entries (`14` DOIs + `10` arXiv IDs) now pass live title, author, and retraction verification.
- **Glossary Formula Correction (`docs/glossary.md`):** Fixed $\Phi_{2\alpha}$ / $\ln$ definition to match manuscript Eq. (1) exactly.
- **Strict 1-to-1 Lean Target Alignment (`CLAIMS.md`, `LIMITATIONS.md`, `docs/faq.md`, `ROADMAP.md`):** Aligned `T1b`/`T1c`/`T1d`, `T3e`, and `T5b`/`T5c` labels with `lean/Challenge.lean`.
- **Attribution, Provenance & Epistemic Honesty Fixes:** Fixed `tsotchke/quantum_rng` (`splitmix64`+`hadamard_mix`, MIT) attribution (removing wrong `Xoshiro256++` references), removed stale `ks31` residue from `third_party/{qgtl,moonlab}/PROVENANCE.md`, removed unarchived `"2,000+"` / `"278"` numerical restart counts, honestly labeled `eshkol/magic_qgt_ad.esk` as an unexecuted source-level companion spec, honestly marked `B44: partial` in `repo.yaml` / `REPLICATION.md` pending third-party human replication, fixed a `qgtl_bridge.c` error-path leak, added QRNG known-answer assertions in C11 & Node, checked computed `norm2` and all 4 `Zeta8` norm components in Zig & Rust, and removed dead `Eisenstein` struct from `WeylMagic/Basic.lean`.

## [1.0.2] - 2026-11-27

### Changed
- Reassigned canonical Master Research Archive identifier from `0TH-2026-021` to `0TH-2026-022` to avoid collision with concurrent archive registration `38f7fbd`, re-sealing frozen PDF, clean-room arXiv tarball, figures, manifests, and RFC 3161 / OpenTimestamps proofs (zero changes to any Lean 4.35.0 proof or polyglot verification engine).

## [1.0.1] - 2026-11-26

### Changed & Fixed
- Reassigned canonical Master Research Archive identifier from `0TH-2026-020` to `0TH-2026-021` to avoid collision with concurrent archive registration `ceced1a` (`quantum-phasespace-rigidity`), rebuilding frozen PDF, clean-room arXiv tarball, figures, manifests, and RFC 3161 / OpenTimestamps proofs with zero Lean proof changes.
- Guarded `now_sec` under `#ifdef WEYL_MAGIC_HAS_ASM` in `c/tests/test_weyl_magic.c` for strict `-Werror` no-ASM ASan/UBSan CI builds.
- Added `shell: bash` to `rust-matrix` CI job for Windows PowerShell compatibility and pinned `pytest==9.0.3` in `requirements.lock.txt` (0 open security alerts).

## [1.0.0] - 2026-11-26

### Added
- **Zero-Mathlib Lean 4.35.0 Palomar Formalization (`lean/`):** 22 numbered theorem groups (`T1a`–`T5d`), 23 Palomar challenge/solution targets, 5 non-vacuity witnesses, and 8 adversarial refutations (36 total audited declarations in `VerifyAxioms.lean`, strictly within `[propext, Classical.choice, Quot.sound]`, replayed across all 6 independent kernels).
- **Nine-Engine Polyglot Verification Stack:**
  - Rust (`#![forbid(unsafe_code)]`, exact `i128` / $\mathbb{Z}[\zeta_8]$ / $\mathbb{Z}[\zeta_9]$ through `D=81`).
  - Zig (`comptime` FWHT + exact `i128` verifier).
  - ISO C11 (`-Wall -Wextra -Wpedantic -Werror -Wshadow -Wconversion`), dual Win64/SysV ELF64 x86-64 NASM assembly (`asm/fwht_x64.asm`, 1.56× speedup over `-O3` C11), 100k differential fuzzer, ASan/UBSan sanitizer build, and CBMC bounded model checking harness.
  - C++20 multi-start Riemannian L-BFGS optimizer (`cpp/magic_search.cpp`) mapping all order-8 and order-16 abelian groups across $\alpha \in \{2, 3, 4\}$.
  - Python exact `Fraction`/`Decimal` oracle (`src/weyl_magic/oracle.py`), textbook $O(D^3)$ reference oracle (`reference/oracle.py`), 162 automated/property tests (`tests/test_all.py`), mutation verifier (`scripts/mutation_check.py`), and live Crossref/arXiv citation auditor (`scripts/check_citations.py`).
  - Explicitly labelled classical cross-checks: QGTL C bridge (`c/src/qgtl_bridge.c`), Moonlab WASM CPU simulator + bit-exact QRNG twin (`node/moonlab_crosscheck.cjs`), and Eshkol AD (`eshkol/magic_qgt_ad.esk`).
- **AMS-LaTeX White Paper & arXiv Package (`paper/`, `dist/`):** 14-page `amsart` manuscript with 5 Okabe-Ito vector figures, 17 live-verified references, zero TeX/BibTeX/overfull warnings, and clean-room `dist/arxiv_submission.tar.gz`.
- **Interactive Zero-CDN Site (`docs/site/`):** WCAG 2.2 AA WebGL2 3D observatory (`index.html`) and interactive SVG proof blueprint DAG (`blueprint.html`).
- **Cryptographic Provenance & Build Standard v1.2.0 Compliance:** `MANIFEST.sha256`, `data/MANIFEST.sha256`, RFC 3161 DigiCert `.tsr`, OpenTimestamps `.ots`, SLSA CI attestations, dual Apache-2.0 / CC-BY-4.0 REUSE 3.3 licensing, and three-cycle forensic hardening audit documentation.
