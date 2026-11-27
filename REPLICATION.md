<!-- SPDX-License-Identifier: CC-BY-4.0 -->
# REPLICATION.md — Clean-Room Replication Protocol

This protocol allows any independent researcher or automated CI container to reproduce every formal proof, exact arithmetic computation, numerical cross-check, dataset, vector figure, and the AMS-LaTeX PDF from a fresh clone.

> **Honest Replication Status (`B44: partial`):** All verifiers, builds, and clean-room PDF compilations have been replicated by the author locally (Windows 11 x86-64) and inside clean-room GitHub Actions CI containers (Ubuntu, macOS, Windows). **Independent third-party human replication has not yet been recorded**; external replication reports are warmly invited below.

## 1. Prerequisites

| Tool | Tested Version | Required For |
|---|---|---|
| `elan` / Lean 4 | `leanprover/lean4:v4.35.0` | `[LEAN-6K]` formal proofs & 6-kernel replay (`bwrap` on Linux for sandboxed `lake check`/`lake comparator`) |
| Python | `3.9`–`3.12` + `requirements.lock.txt` | Exact oracle, pytest/Hypothesis suite, true source mutation testing, data, figures, citation & axiom checks |
| Rust (`cargo`) | Stable (`1.80+`, `clippy`) | Exact `i128` verifier (`D <= 81`) |
| Zig | `0.14.1`–`0.17.0` | Comptime FWHT + `i128` verifier |
| GCC / G++ / NASM | GCC 11+, NASM 2.15+ | C11, dual-ABI x86-64 NASM, ASan/UBSan, 100k fuzz, CBMC harness, QGTL, C++20 L-BFGS |
| Node.js | `20+` | Moonlab WASM CPU simulator & bit-exact QRNG twin |
| Tectonic | `0.15+` | Zero-warning AMS-LaTeX PDF & clean-room arXiv tarball verification |

*(Note: `eshkol/magic_qgt_ad.esk` is a source-level Eshkol AD companion specification and is NOT required to run or pass this replication protocol because no Eshkol compiler binary is installed on standard CI runners.)*

## 2. Step-by-Step Clean-Room Procedure

```bash
git clone https://github.com/0thernes/weyl-magic-obstruction-frontier.git
cd weyl-magic-obstruction-frontier

# Step 1: Verify cryptographic digests of frozen artifacts
sha256sum -c data/MANIFEST.sha256
sha256sum -c MANIFEST.sha256

# Step 2: Zero-Mathlib Lean 4.35.0 build, axiom audit & 6-kernel replay
cd lean
rm -rf .lake
lake build
lake build PalomarChallenge
lake env lean VerifyAxioms.lean > /tmp/replicated_axioms.txt
diff -u --strip-trailing-cr ../results/lean_axioms.txt /tmp/replicated_axioms.txt
lake env leanchecker --fresh PalomarSolution
lake env leanchecker-paranoid --fresh PalomarSolution
# Linux with bubblewrap (omit --inadvisably-no-sandbox on Linux!):
lake check --paranoid
lake comparator --config comparator.json --paranoid
cd ..

# Step 3: Polyglot exact & classical cross-checks
cd rust && cargo clippy --all-targets -- -D warnings && cargo test --release && cd ..
cd zig && zig test src/main.zig && zig run -OReleaseFast src/main.zig && cd ..
just verify-c
node node/moonlab_crosscheck.cjs

# Step 4: Python exact oracle, differential/property/mutation tests & axiom anti-drift
pip install -r requirements.lock.txt
python examples/quickstart_demo.py
pytest -v tests/test_all.py
python scripts/mutation_check.py
python scripts/check_readme_axioms.py
python scripts/verify_site.py

# Step 5: Clean-room AMS-LaTeX compilation from dist/arxiv_submission.tar.gz
mkdir -p /tmp/arxiv_verify/out
tar -xzf dist/arxiv_submission.tar.gz -C /tmp/arxiv_verify
tectonic -X compile /tmp/arxiv_verify/main.tex --outdir /tmp/arxiv_verify/out --keep-logs
! grep -E "Overfull|Underfull|Undefined|Error" /tmp/arxiv_verify/out/main.log
```

## 3. Expected Pass Criteria

- `VerifyAxioms.lean` prints **38 declarations**, all strictly within `[propext, Classical.choice, Quot.sound]`, matching `results/lean_axioms.txt` byte-for-byte (modulo line endings).
- `lake check --paranoid` and `lake comparator --config comparator.json --paranoid` exit `0` across all 6 independent kernels.
- Rust (`4/4` tests), Zig (`1/1` test), C11+ASM (`896` bent, `v42`, `v44`, `n=5` rupture, `char-3 n=1..4`, QRNG assertions), 100k differential fuzz, QGTL (`max_rel_err < 1e-7`), Moonlab WASM (`max_err < 1e-13`, QRNG assertions), Python (`pytest -v tests/test_all.py`: 16 tests including 3 Hypothesis property suites + Draft 2020-12 `repo.yaml` schema check), and true source mutation testing (`9/9` mutants killed) all exit `0`.
- Clean-room arXiv compilation produces a zero-warning PDF with **0** TeX warnings and **0** overfull/underfull hboxes/vboxes.

## 4. Replication Log

*Independent third-party replications are warmly invited; open an issue with your environment, commit SHA, and pass/fail summary to be added below.*

| Date | Replicator | Environment | Commit / Tag | Scope Verified | Outcome |
|---|---|---|---|---|---|
| 2026-11-26 | Alexander Stephen Donahue (author self-replication) | Windows 11 x86-64 (Lean 4.35.0, Rust, Zig 0.17.0, GCC, NASM, Node 20, Python 3.9, Tectonic) | `v1.0.0`–`v1.0.2` | Lean 4.35.0 (6 kernels), Rust, Zig, C11+NASM+Fuzz+QGTL, C++20, Moonlab WASM, Python, Clean-room Tectonic PDF | **PASS** (0 warnings, 0 failures) |
| 2026-11-27 | GitHub Actions Clean-Room CI (`ci.yml`) | Ubuntu / macOS / Windows runners (`bwrap` sandboxed 6-kernel Lean 4.35.0 + polyglot matrix + SLSA) | `v1.0.2` (`688f23a`) | All 12/12 CI jobs + tamper-injecting negative comparator gate + Pages deploy | **PASS** (run `46006772561`) |
| 2026-11-27 | Alexander Stephen Donahue (author self-replication — hostile red-team upgrade) | Windows 11 x86-64 + GitHub Actions clean-room CI | `v1.1.0` | Upgraded 38-decl Lean 4.35.0 (6 kernels), 8 executed polyglot engines, true 9/9 source mutation suite, Draft 2020-12 `repo.yaml` schema, live title+retraction citation audit, clean-room PDF | **PASS** (recorded upon `v1.1.0` freeze) |
| *Open* | *Third-party human researcher* | *Any independent environment* | `v1.1.0` | *Independent external replication (`B44`)* | **OPEN** |
