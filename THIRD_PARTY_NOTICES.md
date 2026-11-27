<!-- SPDX-License-Identifier: CC-BY-4.0 -->
# Third-Party Notices and Attribution

This repository contains original code (Apache-2.0) and documentation/research artifacts (CC-BY-4.0) by Alexander Stephen Donahue, alongside unmodified third-party open-source components vendored strictly for classical verification cross-checks and Build Standard compliance tooling.

## 1. Vendored Third-Party Software

### QGTL — Quantum Geometric Tensor Library (`third_party/qgtl/`)
- **Upstream:** [tsotchke/quantum_geometric_tensor](https://github.com/tsotchke/quantum_geometric_tensor) (commit `770994aa8ddd858e6bb16eebb25250a7b9f67c96`, v0.777 beta; unmodified `differential_geometry.c`, `differential_geometry.h`, and `LICENSE`; see [third_party/qgtl/PROVENANCE.md](third_party/qgtl/PROVENANCE.md)).
- **License:** MIT License ([third_party/qgtl/LICENSE](third_party/qgtl/LICENSE)).
- **Role in this repo:** Classical CPU finite-difference Fubini–Study metric tensor cross-check against Pillar 5 (`T5d`) via `c/src/qgtl_bridge.c`.

### Moonlab WASM Quantum State-Vector Simulator (`third_party/moonlab/`)
- **Upstream:** [tsotchke/moonlab](https://github.com/tsotchke/moonlab) (commit `cd3b2347e3739327548708073d7e4ac710cc6a6c`, v1.2.1; unmodified prebuilt `moonlab.js`, `moonlab.wasm`, and `LICENSE`; see [third_party/moonlab/PROVENANCE.md](third_party/moonlab/PROVENANCE.md)).
- **License:** MIT License ([third_party/moonlab/LICENSE](third_party/moonlab/LICENSE)).
- **Role in this repo:** Classical CPU double-precision state-vector expectation cross-check (`node/moonlab_crosscheck.cjs`).

### Deterministic Integer Mixer (`c/src/qrng_stream.c`, `node/moonlab_crosscheck.cjs`, `src/weyl_magic/oracle.py`)
- **Upstream:** [tsotchke/quantum_rng](https://github.com/tsotchke/quantum_rng) (commit `1a77e77f`, MIT License, Copyright (c) 2024 Tsotchke) for the verbatim `splitmix64` / `hadamard_mix` / `absorb_seed` 64-bit integer mixer block (which itself incorporates SplitMix64 mixing constants from Guy Steele / Sebastiano Vigna's public-domain SplitMix64).
- **License:** Dual-labeled `Apache-2.0 AND MIT` (MIT for the verbatim upstream mixer block; Apache-2.0 for the counter-mode wrapper and Python/JS ports).
- **Role in this repo:** Deterministic reproducible stream seeding for C++20 multi-start L-BFGS and C11 differential fuzzing (explicitly labelled classical integer mixer, not physical quantum entropy).

### Build Standard for LLMs v1.2.0 Audit Scripts (`scripts/Audit-Repo.ps1`, `scripts/audit-repo.sh`, `scripts/audit-checks.tsv`, `repo-standard.schema.json`)
- **Origin:** Local Build Standard v1.2.0 template suite (`docs/build-standard.md`).
- **Role in this repo:** Automated 90-item repository hygiene, documentation, and Draft 2020-12 schema audit.

## 2. External Toolchains & Runtime Dependencies (Not Vendored)

- **Lean 4.35.0 & Bundled External Kernels (`leanchecker-paranoid`, `lean4lean`, `nanoda`, `con-leche`, `con-ron`):** Apache-2.0 (Lean FRO and respective kernel authors). Zero Mathlib or external Lean packages are imported.
- **Python test/figure toolchain (`requirements.lock.txt`):** `pytest` (MIT), `hypothesis` (MPL-2.0), `numpy` (BSD-3-Clause), `matplotlib` (PSF-based), `PyYAML` (MIT), `jsonschema` (MIT), `ruff` (MIT), `mypy` (MIT).
- **Tectonic TeX Engine:** MIT License.
- **Rust Standard Library (`std`), Zig Standard Library (`std`), GCC/G++ runtime, NASM, Node.js:** Respective OSI-approved open-source licenses.

## 3. Scholarly Prior-Work Attribution

All 17 scholarly references in [paper/references.bib](paper/references.bib) have been verified live against Crossref DOI and arXiv Atom APIs with title/author matching and retraction screening (`scripts/check_citations.py`). In particular, Galois-ring $\mathrm{GR}(9,n)$ existence of characteristic-3 Weyl–Heisenberg MUBs is explicitly attributed to Damski et al. (`arXiv:2603.15550`), and the classical degree bound on bent Boolean functions is attributed to O. S. Rothaus (1976).
