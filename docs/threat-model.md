<!-- SPDX-License-Identifier: CC-BY-4.0 -->
# Threat Model (`weyl-magic-obstruction-frontier`)

## Assets to Protect

1. **Formal Mathematical Soundness:** Truth and specification fidelity of the 23 Palomar theorem targets (`T1a`–`T5d`) and 36 audited Lean 4.35.0 declarations.
2. **Exact Computational Witness Integrity:** Exact integer/cyclotomic consensus across Rust, Zig, C11, NASM, and Python.
3. **Artifact & Timestamp Provenance:** Integrity of frozen PDFs, arXiv source tarball, JSON datasets, and cryptographic timestamps.
4. **Browser Client Safety:** Zero XSS, zero tracking, and zero supply-chain script injection on the static GitHub Pages Observatory & Blueprint.

## STRIDE Analysis & Mitigations

| Category | Threat Scenario | Mitigation Implemented | Verification |
|---|---|---|---|
| **Spoofing** | False theorem statement in `PalomarSolution.lean` differing subtly from `PalomarChallenge.lean`, or false author/entity identity. | Isolated `PalomarChallenge.lean` verified by `lake comparator --config comparator.json --paranoid`; ORCID-anchored author identity (`Independent Researcher`, zero corporate entity claims). | CI `lean-6kernel` + tamper-injecting negative test; `Audit-Repo.ps1`. |
| **Tampering** | Injection of `sorry`, `admit`, `native_decide`, custom axioms, metaprogramming kernel exploits (cf. Lean #14576), or silent PDF/dataset edits. | Zero-Mathlib core; `bwrap`-sandboxed replay across **6 independent kernels** (`leanchecker`, `leanchecker-paranoid`, `lean4lean`, `nanoda`, `con-leche`, `con-ron`); `MANIFEST.sha256`, RFC 3161 `.tsr`, OpenTimestamps `.ots`, SLSA provenance. | CI `lean-6kernel` (including deliberate `sorry` + bogus-axiom rejection test) + `sha256sum -c`. |
| **Repudiation** | Dispute over creation date or build origin of frozen manuscript and formal proofs. | Independent DigiCert RFC 3161 `.tsr` + Bitcoin OpenTimestamps `.ots` + GitHub Sigstore SLSA attestations + Software Heritage snapshot. | `openssl ts -verify` / `ots verify` / `gh attestation verify`. |
| **Information Disclosure** | Accidental commit of API keys, tokens, or personal data. | No runtime secrets or personal data collected; regex secret scan in `Audit-Repo.ps1` and CI `lint-audit-security`; `.env.example` documents zero required secrets. | `Audit-Repo.ps1` (`A24`) + CI secret scan. |
| **Denial of Service (Memory / Build)** | Buffer overflows, signed integer overflows, or ABI register clobbering in C11 / C++20 / NASM; infinite recursion in Lean kernel. | `-Wall -Wextra -Wpedantic -Werror -Wshadow -Wconversion`, AddressSanitizer + UndefinedBehaviorSanitizer in CI, 100k differential fuzzing, CBMC bounded model checking (`cbmc_harness.c`), `.note.GNU-stack` non-exec stack, radix-3 FFT keeping Lean heartbeats low. | CI `c11-asm-cpp-qgtl` + `scripts/verify_site.py`. |
| **Elevation of Privilege (Client Web / CI)** | Third-party CDN compromise or XSS in GitHub Pages Observatory / Blueprint; over-privileged CI tokens. | Zero external CDNs; strict CSP (`default-src 'none'; script-src 'unsafe-inline'; style-src 'unsafe-inline'; img-src 'self' data:`) verified by `scripts/verify_site.py`; least-privilege `permissions: contents: read` on CI jobs. | `scripts/verify_site.py` + static inspection of `.github/workflows/*.yml`. |
