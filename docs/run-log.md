<!-- SPDX-License-Identifier: CC-BY-4.0 -->
# Run Log & Verification Audit Trail (`0TH-2026-021`)

Chronological record of verified builds, tests, cross-checks, and publication actions for `weyl-magic-obstruction-frontier` (`v1.0.0`).

| Timestamp (UTC) | Phase | Command / Action | Outcome & Key Metrics |
|---|---|---|---|
| 2026-11-26 | Formalization | `cd lean && lake build && lake build PalomarChallenge` | PASS (17 + 10 jobs, 0 warnings, 0 errors, Lean 4.35.0 zero-Mathlib) |
| 2026-11-26 | Axiom Audit | `cd lean && lake env lean VerifyAxioms.lean` -> `results/lean_axioms.txt` | PASS (36/36 declarations strictly within `[propext, Classical.choice, Quot.sound]`; 3 targets 0 axioms) |
| 2026-11-26 | Kernel Replay | `leanchecker --fresh`, `leanchecker-paranoid --fresh`, `lake check --paranoid`, `lake comparator --config comparator.json --paranoid` | Recorded in Cycle 1–3 audit (`HARDENING_LOG.md`) |
| 2026-11-26 | Polyglot Exact | Rust (`cargo clippy --all-targets -- -D warnings && cargo test --release`), Zig (`0.17.0`), C11 (`-Werror -Wconversion`) + Win64 NASM (`1.56×` over `-O3`) + 100k/25k fuzz | PASS (100% exact match on 896 bent, `v42`, `v44`, `n=5` rupture, char-3 `n=1..4`) |
| 2026-11-26 | Classical Cross-Checks | QGTL C bridge (`max_rel_err = 1.224e-8`), Moonlab WASM (`max_err = 1.33e-14`), QRNG bit-exact twin (`seed=1`), C++20 L-BFGS (`64` starts/group), Eshkol AD | PASS (frozen JSON written to `data/`) |
| 2026-11-26 | Python & Citations | `pytest -v` (`162/162` in `0.56s`), `ruff` (`0`), `mypy --strict` (`0`), `check_citations.py` (`14 DOIs + 10 arXiv IDs`, `0` failures) | PASS |
| 2026-11-26 | Manuscript | `python scripts/package_arxiv.py` (Tectonic main + clean-room tarball compile) | PASS (14 pages, **0** TeX/BibTeX/overfull/underfull warnings) |
| 2026-11-26 | Hardening Cycles 1–3 | Three full forensic hardening audit cycles, `Audit-Repo.ps1`, `mutation_check.py`, `verify_site.py`, `generate_manifests.py`, `stamp_timestamps.py` | Recorded in `HARDENING_LOG.md` & `docs/reviews/2026-11-26-three-cycle-forensic-audit.md` |
