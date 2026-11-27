<!-- SPDX-License-Identifier: CC-BY-4.0 -->
# ERRATA.md

This file tracks all post-release corrections, errata, and mathematical or numerical clarifications for `weyl-magic-obstruction-frontier` (`0TH-2026-021`).

## Active Errata (`v1.0.0`)

None as of initial frozen release `v1.0.0` (2026-11-26).

## Pre-Release Defects Caught & Resolved Before `v1.0.0`

All defects discovered during formalization and the three-cycle forensic hardening audit are permanently documented with finding classes (`bug`, `error`, `issue`, `problem`, `concern`, `dilemma`, `conflict`, `gap`, `hole`, `blindspot`) in [HARDENING_LOG.md](HARDENING_LOG.md) and [docs/reviews/2026-11-26-three-cycle-forensic-audit.md](docs/reviews/2026-11-26-three-cycle-forensic-audit.md). Notable pre-release catches include:

1. **8th-digit truncation in $t^*$ (`0.37745687` vs. exact `0.3774568011835382`):** Caught by 50-digit `Decimal` Newton–Raphson; corrected in `eshkol/magic_qgt_ad.esk` and `node/moonlab_crosscheck.cjs` prior to `v1.0.0` freeze.
2. **Factor-of-2 & constant-term algebra errors in early drafts of `TwoStabilizerTower.lean`:** Caught immediately by the Lean 4.35.0 kernel; corrected and proved identically.
3. **Reducible cubic $t^3 - 2t - 1$ over $\mathbb{F}_3$:** Caught on $W(3)^{\otimes 3}$; replaced by irreducible $t^3 + 2t + 1 = 0$ and preserved permanently as Adversarial Refutation #8 (`refute_reducible_char3_poly`).

## Reporting an Erratum

If you find a mathematical, formalization, citation, or code error, please open a GitHub issue using the repository issue forms or email `0_0@0thernes.art`.
