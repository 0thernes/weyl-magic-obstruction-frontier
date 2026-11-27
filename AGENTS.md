<!-- SPDX-License-Identifier: CC-BY-4.0 -->
# AGENTS.md — AI Coding Agent Instructions

This repository (`weyl-magic-obstruction-frontier`, archive ID `0TH-2026-020`) follows the **Build Standard for LLMs v1.2.0** (`docs/build-standard.md`).

## Non-Negotiable Rules
1. **No blocking gates (R1–R4):** Commit and push straight to `main`. Never add branch protection, required checks, commit signing, PR templates, Dependabot, Renovate, CodeRabbit, or `.github/copilot-instructions.md`. CI is informational only.
2. **Formal integrity:** Zero `sorry` outside isolated `lean/PalomarChallenge.lean`, zero `admit`, zero `native_decide`, zero custom axioms. Every audited declaration in `lean/VerifyAxioms.lean` must remain strictly within `[propext, Classical.choice, Quot.sound]`.
3. **Epistemic honesty & identity:** Author is `Alexander Stephen Donahue` (`Independent Researcher, Spokane, WA, USA`, ORCID `0009-0006-8168-9648`). Never claim corporate affiliation (`0thernes LLC`), never fabricate numbers/DOIs/CI logs, and keep `[LEAN-6K]`, `[EXACT-COMP]`, `[NUMERICAL-APPROX]`, and `[OPEN]` clearly separated.
4. **Classical cross-check labelling:** QGTL, Moonlab WASM, Eshkol AD, and `qrng_stream.c` are deterministic classical arithmetic/simulation cross-checks — never represent them as quantum hardware or physical randomness.
5. **Dual licensing:** Apache-2.0 for code; CC-BY-4.0 for paper, docs, figures, and data (see `REUSE.toml`).

## Key Verification Commands
- Lean 4.35.0: `cd lean && lake build && lake build PalomarChallenge && lake env lean VerifyAxioms.lean && lake env leanchecker --fresh PalomarSolution && lake env leanchecker-paranoid --fresh PalomarSolution`
- Rust: `cd rust && cargo clippy --all-targets -- -D warnings && cargo test --release`
- Zig: `cd zig && zig test src/main.zig && zig run -OReleaseFast src/main.zig`
- C11 + ASM + Fuzz + QGTL: see `justfile` target `verify-c`
- Moonlab WASM: `node node/moonlab_crosscheck.cjs`
- Python: `pytest -v && python scripts/check_readme_axioms.py`
- Paper: `python scripts/package_arxiv.py`
- Build Standard audit: `pwsh -File scripts/Audit-Repo.ps1` (Windows) or `bash scripts/audit-repo.sh .` (Linux/macOS)
