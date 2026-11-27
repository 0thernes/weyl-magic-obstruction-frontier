<!-- SPDX-License-Identifier: CC-BY-4.0 -->
# ADR 0001: Zero-Mathlib Lean 4.35.0 & Palomar Six-Kernel Architecture

- **Status:** Accepted
- **Date:** 2026-11-26

## Context

Formalizing finite-dimensional Weyl–Heisenberg obstructions, cyclotomic witnesses ($\mathbb{Z}[\zeta_8]$, $\mathbb{Z}[\zeta_9]$, $\mathbb{Z}[\zeta_5]$), bent-function degree bounds, and SOS inequalities in Lean 4 offers two architectural paths:
1. Depend on Mathlib4 (hundreds of thousands of declarations, multi-gigabyte `.olean` cache, version coupling, slower cold builds).
2. Build a completely self-contained zero-Mathlib Lean 4.35.0 formalization targeting only core `Init` and the Palomar Challenge/Solution comparator interface.

## Decision

We chose **zero-Mathlib Lean 4.35.0** with strict Palomar separation (`PalomarChallenge.lean`, `PalomarSolution.lean`, `comparator.json`, `formalization.yaml`, `lake-manifest.json`, and `module` headers in all Lean files) replayed across all **six bundled independent kernels** (`leanchecker`, `leanchecker-paranoid`, `lean4lean`, `nanoda`, `con-leche`, `con-ron`).

## Consequences

- **Positive:**
  - Full cold build takes seconds with zero external network downloads for Lean dependencies.
  - Minimizes the trusted computing base (TCB) to Lean 4.35.0 core `Init` and standard axioms `[propext, Classical.choice, Quot.sound]`; three headline theorems (`prove_t3c`, `prove_t3d`, `prove_t3e`) depend on **zero** axioms.
  - Enables fast `bwrap`-sandboxed 6-kernel replay (`lake check --paranoid` + `lake comparator --paranoid`) plus a tamper-injecting negative CI gate on every push.
- **Negative / Tradeoffs:**
  - Algebraic structures (`Gauss`, `Zeta8`, `Zeta9`, `Zeta5`, radix-3 FFT) are defined locally in `WeylMagic/Basic.lean` and `Char3AlltopAndQGT.lean` rather than reusing Mathlib's `CyclotomicField` or `ZMod`.
  - Mathlib-specific linters (`#lint`, `lake exe runLinter` from Batteries) are unavailable without adding Batteries; compensated by strict zero-warning builds, `VerifyAxioms.lean`, `NonVacuity.lean`, `AdversarialTests.lean`, and 6-kernel verification.
