#!/usr/bin/env python3
# SPDX-License-Identifier: Apache-2.0
# Copyright (c) 2026 Alexander Stephen Donahue
"""Quickstart demonstration verifying headline exact invariants across all five pillars."""

from __future__ import annotations

import sys
from fractions import Fraction
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[1] / "src"))

from weyl_magic import (  # noqa: E402
    PSI42_Z8,
    PSI44_Z8,
    V42_SUPER_MUB,
    V44_SUPER_MUB,
    ame_phi4_lower_bound,
    audit_all_f2_4_bent,
    char3_alltop_spectrum,
    char5_alltop_spectrum,
    n2_mub_phi4,
    n4_cubic_root_decimal,
    n5_rupture_exact,
    two_stab_qgt_metric,
    v2_valuation,
    wh_gauss_moments,
    wh_z8_spectrum,
)


def main() -> None:
    print("=== Weyl-Heisenberg Magic Obstruction Frontier: Quickstart ===")
    print(
        f"[Pillar 1] Odd n=3..9 2-adic valuations v_2(2^n(2^n-2)^2): "
        f"{[v2_valuation((2**n) * (2**n - 2) ** 2) for n in (3, 5, 7, 9)]} (all odd!)"
    )
    print(f"[Pillar 1] Sharpness n=2 WH-MUB Phi_4 = {n2_mub_phi4()}")

    b4 = audit_all_f2_4_bent()
    print(
        f"[Pillar 2] All 65,536 F_2^4 functions -> {b4['total_bent']} bent, "
        f"{b4['quad_bent']} deg<=2, {b4['bent_with_zero_triple']} zero-sum triples"
    )

    _, c42 = wh_z8_spectrum((4, 2), PSI42_Z8)
    _, c44 = wh_z8_spectrum((4, 4), PSI44_Z8)
    _, p4_42, p6_42, p8_42 = wh_gauss_moments((4, 2), V42_SUPER_MUB)
    _, p4_44, p6_44, p8_44 = wh_gauss_moments((4, 4), V44_SUPER_MUB)
    print(
        f"[Pillar 3] W(4)xW(2) MUB counts={c42}; Super-MUB Phi4={float(p4_42):.6f} < 15/8, "
        f"Phi6={float(p6_42):.6f} < 71/64, Phi8={float(p8_42):.6f} > 519/512"
    )
    print(
        f"[Pillar 3] W(4)xW(4) MUB counts={c44}; Super-MUB Phi4={float(p4_44):.6f} < 31/16, "
        f"Phi6={float(p6_44):.6f} < 271/256, Phi8={float(p8_44):.6f} > 4111/4096"
    )

    t_star, phi4_star, m2_star = n4_cubic_root_decimal(30)
    _, _, phi4_n5 = n5_rupture_exact()
    print(
        f"[Pillar 4] n=4 cubic root t* = {str(t_star)[:18]}, Phi_4* = {str(phi4_star)[:18]}, M_2* = {str(m2_star)[:18]}"
    )
    print(f"[Pillar 4] n=5 rupture witness Phi_4 = {phi4_n5} ({float(phi4_n5):.6f} < 3)")
    print(
        f"[Pillar 4] AME ceilings: AME(2,2) >= {ame_phi4_lower_bound(2, 2, 1)}, "
        f"AME(5,2) >= {ame_phi4_lower_bound(5, 2, 2)}, "
        f"AME(6,2) >= {ame_phi4_lower_bound(6, 2, 3)}"
    )

    print(f"[Pillar 5] Char-3 divided-power Alltop n=1..3: {[char3_alltop_spectrum(n) for n in (1, 2, 3)]}")
    print(f"[Pillar 5] Char-5 Alltop n=1..2: {[char5_alltop_spectrum(n) for n in (1, 2)]}")
    print(
        f"[Pillar 5] Exact QGT g_tt(D=16, pi/2) = {two_stab_qgt_metric(16, 1.5707963267948966):.10f} "
        f"(exact 15/64 = {float(Fraction(15, 64)):.10f})"
    )


if __name__ == "__main__":
    main()
