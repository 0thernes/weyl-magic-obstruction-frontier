<!-- SPDX-License-Identifier: CC-BY-4.0 -->
# Security Policy

## Scope & Attack Surface

`weyl-magic-obstruction-frontier` is an offline formal mathematics and deterministic scientific verification repository. It runs no network daemon, stores no personal data, and loads zero third-party CDNs or remote scripts in its GitHub Pages site (`docs/site/` enforces a strict Content Security Policy with `default-src 'none'`).

Relevant security and integrity surfaces include:

1. **Proof-kernel soundness / specification tampering:** Hidden axioms, metaprogramming exploits, or mismatches between `PalomarChallenge.lean` and `PalomarSolution.lean`. Mitigated by `bwrap`-sandboxed 6-kernel replay (`lake comparator --paranoid`) and a tamper-injecting negative CI gate.
2. **Native C11 / C++20 / NASM memory safety:** Buffer overruns, signed integer overflow, or ABI violations in `asm/fwht_x64.asm`, `c/`, or `cpp/`. Mitigated by `-Werror -Wconversion`, AddressSanitizer + UndefinedBehaviorSanitizer in CI, 100k differential fuzzing, and CBMC bounded verification.
3. **Supply-chain & artifact provenance:** Tampering with frozen PDFs, arXiv tarballs, or datasets. Mitigated by `MANIFEST.sha256`, RFC 3161 `.tsr`, OpenTimestamps `.ots`, and GitHub SLSA Build Provenance attestations.

See [docs/threat-model.md](docs/threat-model.md) for the complete STRIDE threat model.

## Supported Versions

| Version | Supported |
|---|---|
| `1.0.x` | Yes |

## Reporting a Vulnerability or Proof Exploit

Please report security vulnerabilities, memory-safety bugs, or Lean kernel / specification exploits privately by emailing **`0_0@0thernes.art`** with the subject `[SECURITY] weyl-magic-obstruction-frontier`. You will receive an acknowledgement within 72 hours, and verified issues will be disclosed transparently in [ERRATA.md](ERRATA.md) and [CHANGELOG.md](CHANGELOG.md) once patched.
