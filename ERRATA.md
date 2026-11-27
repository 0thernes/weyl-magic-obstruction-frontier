<!-- SPDX-License-Identifier: CC-BY-4.0 -->
# ERRATA.md

This file tracks all post-release corrections, errata, and mathematical or numerical clarifications for `weyl-magic-obstruction-frontier` (`0TH-2026-022`).

## Active Errata (`v1.1.0`)

None as of release `v1.1.0` (2026-11-27).

## Resolved Documentation & Tooling Corrections (`v1.0.2` → `v1.1.0`)

A hostile 3-cycle red-team hardening audit conducted on 2026-11-27 (`docs/reviews/2026-11-27-hostile-red-team-v1.1.0-audit.md`) caught and fixed non-mathematical documentation/tooling defects in `v1.0.2` (zero mathematical proofs in `lean/` were erroneous):
1. Fixed $\Phi_{2\alpha}$ / $\ln$ formula typo in `docs/glossary.md` (`D^{-1}` and `\log_2` replaced with exact paper Eq. (1)).
2. Fixed mis-indexed Lean target labels (`T1b`/`T1c`/`T1d`, `T3e`, `T5b`/`T5c`) in `CLAIMS.md`, `LIMITATIONS.md`, `docs/faq.md`, and `ROADMAP.md` to match `lean/Challenge.lean` 1-to-1.
3. Fixed wrong `SplitMix64/Xoshiro256++` attribution across docs to the true verbatim `tsotchke/quantum_rng` (`splitmix64` + `hadamard_mix`, MIT) attribution, and removed stale `ks31` copy-paste text from `third_party/{qgtl,moonlab}/PROVENANCE.md`.
4. Clarified `eshkol/magic_qgt_ad.esk` as an unexecuted source-level companion AD specification (not compiled in CI), removed unarchived `"2,000+"` / `"278"` numerical restart counts, upgraded `scripts/mutation_check.py` to true 9-mutant source mutation testing, upgraded `scripts/check_citations.py` to live title+author+retraction checking, brought `repo.yaml` into strict Draft 2020-12 schema compliance (honestly setting `B44: partial`), and added two new Lean 4.35.0 kernel-checked theorems (`n4_z4_bent_hyperplane_rupture_arbitrary_bent` and nontrivial $n=2$ `nonvacuity_pillar1_n2_mub_spectrum`).

## Pre-Release Defects Caught & Resolved Before `v1.0.0`

All defects discovered during formalization and the three-cycle forensic hardening audit are permanently documented with finding classes (`bug`, `error`, `issue`, `problem`, `concern`, `dilemma`, `conflict`, `gap`, `hole`, `blindspot`) in [HARDENING_LOG.md](HARDENING_LOG.md) and [docs/reviews/2026-11-26-three-cycle-forensic-audit.md](docs/reviews/2026-11-26-three-cycle-forensic-audit.md). Notable pre-release catches include:

1. **8th-digit truncation in $t^*$ (`0.37745687` vs. exact `0.3774568011835382`):** Caught by 50-digit `Decimal` Newton–Raphson; corrected in `eshkol/magic_qgt_ad.esk` and `node/moonlab_crosscheck.cjs` prior to `v1.0.0` freeze.
2. **Factor-of-2 & constant-term algebra errors in early drafts of `TwoStabilizerTower.lean`:** Caught immediately by the Lean 4.35.0 kernel; corrected and proved identically.
3. **Reducible cubic $t^3 - 2t - 1$ over $\mathbb{F}_3$:** Caught on $W(3)^{\otimes 3}$; replaced by irreducible $t^3 + 2t + 1 = 0$ and preserved permanently as Adversarial Refutation #8 (`refute_reducible_char3_poly`).

## Reporting an Erratum

If you find a mathematical, formalization, citation, or code error, please open a GitHub issue using the repository issue forms or email `0_0@0thernes.art`.
