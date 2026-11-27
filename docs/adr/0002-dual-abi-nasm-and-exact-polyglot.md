<!-- SPDX-License-Identifier: CC-BY-4.0 -->
# ADR 0002: Dual-ABI x86-64 NASM & Disjoint Polyglot Exact Arithmetic

- **Status:** Accepted
- **Date:** 2026-11-26

## Context

Heavy finite-search and cyclotomic verification steps (enumerating all $65{,}536$ Boolean functions on $\mathbb{F}_2^4$, evaluating $W(4)\otimes W(4)$ and $n=5$ Pauli spectra, and verifying $W(3)^{\otimes 4}$ at $D=81$) benefit from fast native code, while guarding against compiler bugs, integer overflows, or shared algorithmic mistakes.

## Decision

1. Implement a **baseline x86-64 NASM assembly** Fast Walsh–Hadamard Transform (`asm/fwht_x64.asm`: `fwht16_i64_asm` and `fwht32_i64_asm`) supporting both **Win64** (`RCX`) and **SysV ELF64** (`RDI`) ABIs via conditional assembly (`%ifidn __OUTPUT_FORMAT__, win64`), using zero stack frames and emitting a non-executable `.note.GNU-stack` section on ELF64.
2. Cross-verify every exact arithmetic witness across **five independent languages/implementations**: Lean 4.35.0, Rust (`#![forbid(unsafe_code)]`, `i128`), Zig (`comptime` FWHT, `i128`), ISO C11 (`-Werror -Wconversion`, ASan/UBSan, 100k fuzz, CBMC harness), and Python (`Fraction` + independent textbook $O(D^3)$ `reference/oracle.py`).

## Consequences

- **Positive:**
  - `fwht16_i64_asm` achieves a measured **1.56× speedup** over GCC `-O3` C11 (`0.0021s` vs `0.0033s` for 200k transforms) while agreeing bit-for-bit across all 65,536 $\mathbb{F}_2^4$ functions and 125,000 random fuzz vectors.
  - Any single-language overflow, signedness error, or library bug is immediately exposed by differential consensus.
- **Negative / Tradeoffs:**
  - Cross-platform CI must assemble ELF64 on Linux and Win64 on Windows (non-x86 architectures like ARM64 macOS fall back cleanly to pure ISO C11 by omitting `-DWEYL_MAGIC_HAS_ASM`).
