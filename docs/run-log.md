<!-- SPDX-License-Identifier: CC-BY-4.0 -->
# Run Log & Verification Audit Trail (`0TH-2026-022`)

Chronological record of verified builds, tests, cross-checks, and publication actions for `weyl-magic-obstruction-frontier` (`v1.0.0`).

| Timestamp (UTC) | Phase | Command / Action | Outcome & Key Metrics |
|---|---|---|---|
| 2026-11-26 | Formalization | `cd lean && lake build && lake build PalomarChallenge` | PASS (17 + 10 jobs, 0 warnings, 0 errors, Lean 4.35.0 zero-Mathlib) |
| 2026-11-26 | Axiom Audit | `cd lean && lake env lean VerifyAxioms.lean` -> `results/lean_axioms.txt` | PASS (36/36 declarations strictly within `[propext, Classical.choice, Quot.sound]`; 3 targets 0 axioms) |
| 2026-11-26 | Kernel Replay | `leanchecker --fresh`, `leanchecker-paranoid --fresh`, `lake check --paranoid`, `lake comparator --config comparator.json --paranoid` | Recorded in Cycle 1–3 audit (`HARDENING_LOG.md`) |
| 2026-11-26 | Polyglot Exact | Rust (`cargo clippy --all-targets -- -D warnings && cargo test --release`), Zig (`0.17.0`), C11 (`-Werror -Wconversion`) + Win64 NASM (`1.56×` over `-O3`) + 100k/25k fuzz | PASS (100% exact match on 896 bent, `v42`, `v44`, `n=5` rupture, char-3 `n=1..4`) |
| 2026-11-26 | Classical Cross-Checks | QGTL C bridge (`max_rel_err = 1.224e-8`), Moonlab WASM (`max_err = 1.33e-14`), QRNG bit-exact twin (`seed=1`), C++20 L-BFGS (`64` starts/group) | PASS (frozen JSON written to `data/`; `eshkol/magic_qgt_ad.esk` is source-level spec only, not executed in CI) |
| 2026-11-26 | Python & Citations | `pytest -v`, `ruff` (`0`), `mypy --strict` (`0`), `check_citations.py` (`14 DOIs + 10 arXiv IDs`) | PASS (upgraded in `v1.1.0` to live title/author/retraction audit & true 9-mutant source mutation testing) |
| 2026-11-26 | Manuscript | `python scripts/package_arxiv.py` (Tectonic main + clean-room tarball compile) | PASS (14 pages, **0** TeX/BibTeX/overfull/underfull warnings) |
| 2026-11-26 | Hardening Cycles 1–3 (`v1.0.0`) | Three forensic hardening audit cycles, `Audit-Repo.ps1`, `verify_site.py`, `generate_manifests.py`, `stamp_timestamps.py` | Recorded in `HARDENING_LOG.md` & `docs/reviews/2026-11-26-three-cycle-forensic-audit.md` |
| 2026-11-27 | Hostile Red-Team Hardening (`v1.1.0`) | 3-cycle hostile audit across all 134+ files: added arbitrary-bent `n=4` Lean bridge & nontrivial `n=2` Pauli idempotence (`38/38` axioms), fixed `Leone2022SRE` arXiv ID (`2106.12587`), replaced fake mutation check with 9/9 real source mutants, fixed Draft 2020-12 `repo.yaml` (`B44: partial`), fixed glossary/attribution/PROVENANCE/Eshkol honesty | Recorded in `HARDENING_LOG.md` & `docs/reviews/2026-11-27-hostile-red-team-v1.1.0-audit.md` |
