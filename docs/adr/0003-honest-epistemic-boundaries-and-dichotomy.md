<!-- SPDX-License-Identifier: CC-BY-4.0 -->
# ADR 0003: Honest Epistemic Boundaries & Classical Cross-Check Labelling

- **Status:** Accepted
- **Date:** 2026-11-26

## Context

Independent AI-assisted mathematical repositories face severe credibility risks when floating-point heuristics are presented as proofs, classical CPU simulators are conflated with quantum hardware, prior literature is under-credited, or non-existent legal entities are listed as affiliations.

## Decision

Adopt the **Defensible Independent AI Research Playbook v1.3** and **Build Standard v1.2.0** standards unconditionally:
1. Tag every claim in `README.md`, `CLAIMS.md`, `paper/main.tex`, and `docs/site/` with one of `[LEAN-6K]`, `[EXACT-COMP]`, `[NUMERICAL-APPROX]`, or `[OPEN]`.
2. Explicitly label `third_party/qgtl`, `third_party/moonlab`, `eshkol/magic_qgt_ad.esk`, and `c/src/qrng_stream.c` as **deterministic classical CPU** cross-checks.
3. Explicitly list `Alexander Stephen Donahue (Independent Researcher, Spokane, WA, USA; ORCID 0009-0006-8168-9648)` everywhere with dual Apache-2.0 / CC-BY-4.0 REUSE 3.3 licensing and zero corporate entity claims.
4. Preserve honest open boundaries: credit Damski et al. (`arXiv:2603.15550`) for Galois-ring $\mathrm{GR}(9,n)$ char-3 MUB existence, state Pillar 3 as an exact WH-MUB/Super-MUB dichotomy plus empirical $\alpha$-dependence, and keep non-equimodular $n=4$ global optimality and even $n \ge 6$ strong form marked `[OPEN]`.

## Consequences

- **Positive:** Every claim withstands hostile mathematical, computational, and academic scrutiny without overstatement.
- **Negative / Tradeoffs:** Requires extra diligence in every audit pass to prevent prose drift across paper, README, site, and metadata manifests.
