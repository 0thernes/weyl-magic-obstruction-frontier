<!-- SPDX-License-Identifier: CC-BY-4.0 -->
# Third-Party Notices and Attribution

This repository contains original code (Apache-2.0) and documentation/research artifacts (CC-BY-4.0) by Alexander Stephen Donahue, alongside unmodified third-party open-source components vendored strictly for classical verification cross-checks and Build Standard compliance tooling.

## 1. Vendored Third-Party Software

### QGTL — Quantum Geometric Tensor Library (`third_party/qgtl/`)
- **Upstream:** Quantum Geometric Tensor Library (unmodified `differential_geometry.c` and required headers; see [third_party/qgtl/PROVENANCE.md](third_party/qgtl/PROVENANCE.md)).
- **License:** MIT License ([third_party/qgtl/LICENSE](third_party/qgtl/LICENSE)).
- **Role in this repo:** Classical CPU finite-difference Fubini–Study metric tensor cross-check against Pillar 5 (`T5d`).

### Moonlab WASM Quantum State-Vector Simulator (`third_party/moonlab/`)
- **Upstream:** Moonlab WebAssembly state-vector runtime (see [third_party/moonlab/PROVENANCE.md](third_party/moonlab/PROVENANCE.md)).
- **License:** MIT License ([third_party/moonlab/LICENSE](third_party/moonlab/LICENSE)).
- **Role in this repo:** Classical CPU double-precision state-vector expectation cross-check (`node/moonlab_crosscheck.cjs`).

### SplitMix64 & Xoshiro256++ PRNG Algorithm (`c/src/qrng_stream.c`, `node/moonlab_crosscheck.cjs`)
- **Upstream Authors:** Sebastiano Vigna and David Blackman (public domain / CC0-1.0); adapted under MIT/Apache-2.0 for deterministic bit-exact seeding across C11, Node BigInt, and Python.
- **Role in this repo:** Deterministic reproducible stream seeding for C++20 multi-start L-BFGS and C11 differential fuzzing (explicitly labelled classical PRNG, not physical quantum entropy).

### Build Standard for LLMs v1.2.0 Audit Scripts (`scripts/Audit-Repo.ps1`, `scripts/audit-repo.sh`, `scripts/audit-checks.tsv`, `repo-standard.schema.json`)
- **Origin:** Local Build Standard v1.2.0 template suite (`docs/build-standard.md`).
- **Role in this repo:** Automated 90-item repository hygiene, documentation, and verification audit.

## 2. External Toolchains & Runtime Dependencies (Not Vendored)

- **Lean 4.35.0 & Bundled External Kernels (`leanchecker-paranoid`, `lean4lean`, `nanoda`, `con-leche`, `con-ron`):** Apache-2.0 (Lean FRO and respective kernel authors). Zero Mathlib or external Lean packages are imported.
- **Python test/figure toolchain (`requirements.lock.txt`):** `pytest` (MIT), `hypothesis` (MPL-2.0), `numpy` (BSD-3-Clause), `matplotlib` (PSF-based), `ruff` (MIT), `mypy` (MIT).
- **Tectonic TeX Engine:** MIT License.
- **Rust Standard Library (`std`), Zig Standard Library (`std`), GCC/G++ runtime, NASM, Node.js:** Respective OSI-approved open-source licenses.

## 3. Scholarly Prior-Work Attribution

All 17 scholarly references in [paper/references.bib](paper/references.bib) have been checked against live Crossref DOI and arXiv APIs (`scripts/check_citations.py`). In particular, Galois-ring $\mathrm{GR}(9,n)$ existence of characteristic-3 Weyl–Heisenberg MUBs is explicitly attributed to Damski et al. (`arXiv:2603.15550`), and the classical degree bound on bent Boolean functions is attributed to O. S. Rothaus (1976).
