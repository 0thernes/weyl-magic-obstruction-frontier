#!/usr/bin/env python3
# SPDX-License-Identifier: Apache-2.0
# Copyright (c) 2026 Alexander Stephen Donahue
"""True isolated source-code mutation testing for src/weyl_magic/oracle.py.

Copies the production package into an isolated temporary directory, verifies the
unmutated baseline passes pytest, then injects 9 real production-code mutants
spanning all five pillars and asserts that the real pytest suite kills 100% of
them (exit code != 0). Never mutates the working tree.
"""

from __future__ import annotations

import os
import shutil
import subprocess
import sys
import tempfile
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SRC_PKG = ROOT / "src" / "weyl_magic"

# (id, description, target_snippet, replacement_snippet)
MUTANTS: list[tuple[str, str, str, str]] = [
    (
        "M1-P1-v2",
        "Pillar 1: corrupt v2_valuation step (k += 1 -> k += 2)",
        "        x >>= 1\n        k += 1",
        "        x >>= 1\n        k += 2",
    ),
    (
        "M2-P2-deg",
        "Pillar 2: corrupt F_2^4 ANF degree threshold (<= 2 -> <= 1)",
        "        if max_deg <= 2:\n            quad_bent += 1",
        "        if max_deg <= 1:\n            quad_bent += 1",
    ),
    (
        "M3-P2-triple",
        "Pillar 2: corrupt 3-hyperplane zero-sum triple test (== 0 -> == 1)",
        "                if (ea[a] ^ ea[b] ^ ea[a ^ b]) == 0:",
        "                if (ea[a] ^ ea[b] ^ ea[a ^ b]) == 1:",
    ),
    (
        "M4-P3-z8mul",
        "Pillar 3: corrupt Z[zeta_8] cyclotomic reduction sign (- a[3]*b[1] -> + a[3]*b[1])",
        "        a[0] * b[0] - a[1] * b[3] - a[2] * b[2] - a[3] * b[1],",
        "        a[0] * b[0] - a[1] * b[3] - a[2] * b[2] + a[3] * b[1],",
    ),
    (
        "M5-P3-num4",
        "Pillar 3: corrupt Gaussian 4th-moment accumulator (+1)",
        "            num4 += m2\n            num6 += m2 * m",
        "            num4 += m2 + 1\n            num6 += m2 * m",
    ),
    (
        "M6-P4-tower",
        "Pillar 4: corrupt two-stabilizer Stratum II term ((1 - 2*t)^4 -> (1 - 3*t)^4)",
        "    s2 = (1 - 2 * t) ** 4",
        "    s2 = (1 - 3 * t) ** 4",
    ),
    (
        "M7-P4-n5",
        "Pillar 4: corrupt n=5 rupture FWHT accumulator (+1)",
        "            m = fre[b] * fre[b] + fim[b] * fim[b]\n            num4 += m * m",
        "            m = fre[b] * fre[b] + fim[b] * fim[b]\n            num4 += m * m + 1",
    ),
    (
        "M8-P5-char3",
        "Pillar 5: corrupt char-3 Z[zeta_9] Alltop phase exponent (+ x)",
        "                p = _z9_pow((g[xa] + 9 - g[x] + 3 * bx) % 9)",
        "                p = _z9_pow((g[xa] + 9 - g[x] + 3 * bx + x) % 9)",
    ),
    (
        "M9-P5-qgt",
        "Pillar 5: corrupt QGT numerator sign (1 - 1/D -> 1 + 1/D)",
        "    return (1.0 - 1.0 / float(dim)) / (norm_sq * norm_sq)",
        "    return (1.0 + 1.0 / float(dim)) / (norm_sq * norm_sq)",
    ),
]


def run_pytest(src_dir: Path) -> subprocess.CompletedProcess[str]:
    env = os.environ.copy()
    env["WEYL_MAGIC_MUTANT_SRC"] = str(src_dir)
    env["PYTHONPATH"] = f"{src_dir}{os.pathsep}{ROOT}"
    return subprocess.run(
        [sys.executable, "-m", "pytest", "-q", "-x", "tests/test_all.py"],
        cwd=str(ROOT),
        env=env,
        capture_output=True,
        text=True,
        timeout=120,
        check=False,
    )


def main() -> int:
    with tempfile.TemporaryDirectory(prefix="wm_mutation_") as td:
        tmp_src = Path(td) / "src"
        shutil.copytree(SRC_PKG, tmp_src / "weyl_magic")
        oracle_path = tmp_src / "weyl_magic" / "oracle.py"
        original_src = oracle_path.read_text(encoding="utf-8")

        # Sanity check: ensure isolated copy is actually imported & unmutated baseline passes
        probe = subprocess.run(
            [sys.executable, "-c", "import weyl_magic.oracle as o; print(o.__file__)"],
            cwd=str(ROOT),
            env={**os.environ, "PYTHONPATH": f"{tmp_src}{os.pathsep}{ROOT}"},
            capture_output=True,
            text=True,
            check=True,
        )
        imported_file = Path(probe.stdout.strip()).resolve()
        if imported_file != oracle_path.resolve():
            print(f"[mutation_check] ERROR: imported {imported_file}, expected {oracle_path}", file=sys.stderr)
            return 1

        base_res = run_pytest(tmp_src)
        if base_res.returncode != 0:
            print("[mutation_check] ERROR: unmutated baseline failed pytest!", file=sys.stderr)
            print(base_res.stdout, base_res.stderr, file=sys.stderr)
            return 1
        print("[mutation_check] Baseline pytest PASS on isolated source copy.")

        killed = 0
        for mid, desc, target, replacement in MUTANTS:
            count = original_src.count(target)
            if count != 1:
                print(
                    f"[mutation_check] ERROR: mutant {mid} target matched {count} times (must match exactly once)",
                    file=sys.stderr,
                )
                return 1
            mutated = original_src.replace(target, replacement, 1)
            oracle_path.write_text(mutated, encoding="utf-8")
            # Clear cached bytecode so Python always compiles the mutated file
            pycache = oracle_path.parent / "__pycache__"
            if pycache.exists():
                shutil.rmtree(pycache)
            res = run_pytest(tmp_src)
            if res.returncode != 0:
                killed += 1
                print(f"[mutation_check] KILLED   {mid}: {desc}")
            else:
                print(f"[mutation_check] SURVIVED {mid}: {desc}", file=sys.stderr)

        oracle_path.write_text(original_src, encoding="utf-8")

    total = len(MUTANTS)
    if killed != total:
        print(f"[mutation_check] FAIL: killed {killed}/{total} real source mutants", file=sys.stderr)
        return 1
    print(f"[mutation_check] PASS: {killed}/{total} real source-code mutants killed by pytest (100.0%)")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
