<!-- SPDX-License-Identifier: CC-BY-4.0 -->
# Contributing to `weyl-magic-obstruction-frontier`

Contributions, independent replications, statement-fidelity audits, and counterexample reports are warmly welcome.

## Workflow Rules (Build Standard v1.2.0)

- **Main-branch workflow:** The maintainer commits directly to `main` with informational-only CI (no branch protection, no required review gates, no commit signing). External contributors may open GitHub Issues (using the forms in `.github/ISSUE_TEMPLATE/`) with patches, replication reports, or formalization improvements.
- **Finding Classification:** When filing an issue or audit item, classify it using one of the 10 finding classes defined in `.github/labels.yml`: `bug`, `error`, `issue`, `problem`, `concern`, `dilemma`, `conflict`, `gap`, `hole`, or `blindspot`.
- **Formal Integrity Requirements:**
  - Zero `sorry` (except the isolated `lean/PalomarChallenge.lean` statement stub), zero `admit`, zero `native_decide`, zero custom `axiom` declarations.
  - Every Lean `.lean` file must begin with a `module` header (Palomar compliance) and stay well under 10,000 lines.
  - All declarations in `lean/VerifyAxioms.lean` must remain strictly within `[propext, Classical.choice, Quot.sound]`, and `results/lean_axioms.txt` plus the verbatim block in `README.md` must stay synchronized (`python scripts/check_readme_axioms.py`).
- **Epistemic & Licensing Standards:**
  - Respect dual REUSE 3.3 licensing (`Apache-2.0` for code, `CC-BY-4.0` for documentation, paper, figures, and data; see `REUSE.toml`).
  - Keep `[LEAN-6K]`, `[EXACT-COMP]`, `[NUMERICAL-APPROX]`, and `[OPEN]` clearly separated. Never promote floating-point search results to formal proofs.
  - Disclose AI assistance transparently.

## Pre-Submission Verification Checklist

Run the following locally before submitting changes:

```bash
just verify-lean
just verify-rust
just verify-zig
just verify-c
just verify-moonlab
just verify-python
pwsh -File scripts/Audit-Repo.ps1   # or: bash scripts/audit-repo.sh .
```

All contributors are expected to follow [CODE_OF_CONDUCT.md](CODE_OF_CONDUCT.md).
