<!-- SPDX-License-Identifier: CC-BY-4.0 -->
# Benchmarks & Performance Budgets

All timings below were measured locally on Windows 11 x86-64 (single-threaded unless noted, exact arithmetic release builds) during `v1.0.0` verification. No numbers are extrapolated or fabricated.

## 1. Measured Verification Timings & Budgets

| Component | Command | Measured Runtime | Performance Budget | Result |
|---|---|---|---|---|
| **Lean 4.35.0 full build** | `lake build` (17 jobs, zero-Mathlib) | `< 15 s` | `< 60 s` | PASS (0 warnings) |
| **Lean 4.35.0 `VerifyAxioms.lean`** | `lake env lean VerifyAxioms.lean` (36 decls) | `< 3 s` | `< 15 s` | PASS |
| **Rust release suite (`D <= 81`)** | `cargo test --release` (4 tests) | `0.01 s` | `< 5 s` | PASS (0 clippy warnings) |
| **Zig release exact check** | `zig run -OReleaseFast src/main.zig` | `< 0.05 s` | `< 5 s` | PASS |
| **ISO C11 FWHT-16 (200,000 calls)** | GCC `-std=c11 -O3` reference loop | `0.0033 s` | `< 0.1 s` | Baseline (`1.00×`) |
| **x86-64 NASM FWHT-16 (200,000 calls)** | `asm/fwht_x64.asm` (`fwht16_i64_asm`) | `0.0021 s` | `< 0.05 s` | **`1.56×` speedup** over `-O3` C11 |
| **C11 + NASM differential fuzzer** | `100,000` FWHT-16 + `25,000` FWHT-32 checks | `< 0.1 s` | `< 5 s` | PASS (0 mismatches) |
| **Python exact test suite** | `pytest -v tests/test_all.py` (162 tests) | `0.56 s` | `< 15 s` | PASS |
| **Moonlab WASM + QRNG twin** | `node node/moonlab_crosscheck.cjs` | `< 0.3 s` | `< 5 s` | PASS (`max_err = 1.33e-14`) |
| **QGTL Richardson QGT bridge** | `./build/qgtl_bridge` (20 points, `n=1..4`) | `< 0.05 s` | `< 5 s` | PASS (`max_rel_err = 1.224e-8`) |
| **Tectonic clean-room PDF build** | `python scripts/package_arxiv.py` | `< 10 s` | `< 60 s` | PASS (14 pages, 0 warnings) |

## 2. Algorithmic Performance Decisions

- **Radix-3 cyclotomic FFT in Lean (`Char3AlltopAndQGT.lean`):** Replacing naive $O(D^3)$ triple sums with a radix-3 butterfly FFT over $\mathbb{Z}[\zeta_9]$ achieved a **~9× reduction** in Lean kernel reduction steps on $W(3)^{\otimes 3}$ (`D = 27`), keeping proofs comfortably within Lean's default `maxHeartbeats` without raising kernel limits.
- **Balanced tree reductions (`SuperMubAnomalies.lean`):** Replacing linear left-folds over 256 elements with depth-4 balanced reductions eliminated `maxRecDepth` pressure during kernel evaluation of `psi44` and `v44`.
- **Regression Tracking (B27):** CI workflow job durations (Rust 3-OS matrix, Zig, C11+ASM+Fuzz, Python 3-OS matrix, Lean 6-kernel, Tectonic) are recorded automatically in GitHub Actions run history on every push to `main` (report-only, never blocking).
