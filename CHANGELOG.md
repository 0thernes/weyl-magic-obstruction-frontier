<!-- SPDX-License-Identifier: CC-BY-4.0 -->
# Changelog

All notable changes to `weyl-magic-obstruction-frontier` (`0TH-2026-020`) are documented in this file.

The format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

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
