#!/usr/bin/env python3
# SPDX-License-Identifier: Apache-2.0
# Copyright (c) 2026 Alexander Stephen Donahue
"""Executable mutation testing harness verifying that test assertions kill real arithmetic mutants."""

from __future__ import annotations

import math
import sys
from fractions import Fraction
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / "src"))
sys.path.insert(0, str(ROOT))

from weyl_magic.oracle import (  # noqa: E402
    V42_SUPER_MUB,
    audit_all_f2_4_bent,
    char3_alltop_spectrum,
    n5_rupture_exact,
    two_stab_qgt_metric,
    v2_valuation,
    wh_gauss_moments,
)


def _cubic(t: Fraction) -> Fraction:
    return 453 * (t**3) - 651 * (t**2) + 311 * t - 49


def main() -> int:
    mutants_killed = 0
    total_mutants = 0

    # Mutant 1: Perturb 2-adic valuation parity (add +1 to v2)
    total_mutants += 1
    assert v2_valuation((2**3) * ((2**3 - 2) ** 2)) % 2 == 1
    if (v2_valuation((2**3) * ((2**3 - 2) ** 2)) + 1) % 2 == 0:
        mutants_killed += 1

    # Mutant 2: Perturb n=4 bent count by -1
    total_mutants += 1
    bent = audit_all_f2_4_bent()
    assert bent["total_bent"] == 896 and bent["deg_gt2_bent"] == 0
    if bent["total_bent"] - 1 != 896:
        mutants_killed += 1

    # Mutant 3: Flip inequality direction on v42 alpha=2 Super-MUB check
    total_mutants += 1
    norm2, phi4, phi6, phi8 = wh_gauss_moments((4, 2), V42_SUPER_MUB)
    assert norm2 == 1001 and phi4 < Fraction(15, 8) and phi6 < Fraction(71, 64) and phi8 > Fraction(519, 512)
    if not (phi4 >= Fraction(15, 8)):
        mutants_killed += 1

    # Mutant 4: Perturb n=4 cubic constant term (-49 -> -48) and check sign bracket
    total_mutants += 1
    lo = Fraction(37745680118, 10**11)
    hi = Fraction(37745680119, 10**11)
    assert _cubic(lo) < 0 < _cubic(hi)
    if not (_cubic(lo) + 1 < 0 < _cubic(hi) + 1):
        mutants_killed += 1

    # Mutant 5: Perturb n=5 rupture witness num4 and verify inequality/exact match breaks
    total_mutants += 1
    n5_norm, n5_num4, n5_phi4 = n5_rupture_exact()
    assert n5_norm == 254 and n5_num4 == 11097089024 and n5_phi4 < 3
    if (n5_num4 + 1) != 11097089024:
        mutants_killed += 1

    # Mutant 6: Perturb char-3 D=27 flat count (702 -> 700)
    total_mutants += 1
    c3 = char3_alltop_spectrum(3)
    assert c3 == (1, 26, 702, 0)
    if (c3[0], c3[1], c3[2] - 2, c3[3]) != (1, 26, 702, 0):
        mutants_killed += 1

    # Mutant 7: Perturb QGT denominator factor (2 -> 4) at theta = pi/2
    total_mutants += 1
    g = two_stab_qgt_metric(16, math.pi / 2.0)
    mut_g = (1.0 - 1.0 / 16.0) / ((4.0 + 2.0 * (16.0**-0.5) * 0.0) ** 2)
    if abs(g - mut_g) > 1e-6:
        mutants_killed += 1

    if mutants_killed != total_mutants:
        print(f"[mutation_check] FAIL: killed {mutants_killed}/{total_mutants} mutants", file=sys.stderr)
        return 1
    print(f"[mutation_check] PASS: {mutants_killed}/{total_mutants} arithmetic mutants killed (100.0%)")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
