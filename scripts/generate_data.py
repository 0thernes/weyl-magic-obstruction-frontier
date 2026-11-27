#!/usr/bin/env python3
# SPDX-License-Identifier: Apache-2.0
# Copyright (c) 2026 Alexander Stephen Donahue
"""Generate canonical frozen JSON data tables in data/ from exact arithmetic + C++20 search."""

from __future__ import annotations

import json
import math
import sys
from fractions import Fraction
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / "src"))
sys.path.insert(0, str(ROOT))

from reference.oracle import ref_product_wh_phi_alpha  # noqa: E402
from weyl_magic import (  # noqa: E402
    N5_RUPTURE_VEC,
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
    two_stab_phi4_exact,
    two_stab_qgt_metric,
    v2_valuation,
    wh_gauss_moments,
    wh_z8_spectrum,
)


def main() -> None:
    data_dir = ROOT / "data"
    data_dir.mkdir(exist_ok=True)

    # 1. Exact Summary of All Five Pillars
    t_star, phi4_star, m2_star = n4_cubic_root_decimal(50)
    n42_norm, p4_42, p6_42, p8_42 = wh_gauss_moments((4, 2), V42_SUPER_MUB)
    n44_norm, p4_44, p6_44, p8_44 = wh_gauss_moments((4, 4), V44_SUPER_MUB)
    n5_norm, n5_num4, n5_phi4 = n5_rupture_exact()
    _, c42 = wh_z8_spectrum((4, 2), PSI42_Z8)
    _, c44 = wh_z8_spectrum((4, 4), PSI44_Z8)

    summary = {
        "schema_version": "1.0",
        "id": "0TH-2026-020",
        "pillar1_two_adic": {
            "odd_n_samples": [
                {"n": n, "v2": v2_valuation((2**n) * ((2**n - 2) ** 2)), "odd_v2": True}
                for n in (3, 5, 7, 9, 11, 13, 15)
            ],
            "n2_mub_phi4": str(n2_mub_phi4()),
        },
        "pillar2_bent4": audit_all_f2_4_bent(),
        "pillar3_super_mub": {
            "w42_z8_mub": {"norm2": 8, "counts": {f"{k[0]}": v for k, v in c42.items()}},
            "w44_z8_mub": {"norm2": 320, "counts": {f"{k[0]}": v for k, v in c44.items()}},
            "v42": {
                "norm2": n42_norm,
                "phi4_exact": str(p4_42),
                "phi4_float": float(p4_42),
                "phi6_exact": str(p6_42),
                "phi6_float": float(p6_42),
                "phi8_exact": str(p8_42),
                "phi8_float": float(p8_42),
                "mub_phi4": "15/8",
                "mub_phi6": "71/64",
                "mub_phi8": "519/512",
            },
            "v44": {
                "norm2": n44_norm,
                "phi4_exact": str(p4_44),
                "phi4_float": float(p4_44),
                "phi6_exact": str(p6_44),
                "phi6_float": float(p6_44),
                "phi8_exact": str(p8_44),
                "phi8_float": float(p8_44),
                "mub_phi4": "31/16",
                "mub_phi6": "271/256",
                "mub_phi8": "4111/4096",
            },
        },
        "pillar4_two_stab_and_ame": {
            "n1_sic_phi4": "4/3",
            "n2_mub_phi4": str(two_stab_phi4_exact(4, Fraction(1, 2))),
            "n3_hoggar_phi4": str(two_stab_phi4_exact(8, Fraction(1, 3))),
            "n4_cubic_t_star": str(t_star),
            "n4_cubic_phi4_star": str(phi4_star),
            "n4_cubic_M2_star": str(m2_star),
            "n5_tower_sos_floor": "3",
            "n5_rupture_norm2": n5_norm,
            "n5_rupture_num4": str(n5_num4),
            "n5_rupture_phi4_exact": str(n5_phi4),
            "n5_rupture_phi4_float": float(n5_phi4),
            "n5_rupture_M2_float": math.log(32.0 / float(n5_phi4)),
            "ame_ceilings": {
                "AME(2,2)": {
                    "exact": str(ame_phi4_lower_bound(2, 2, 1)),
                    "float": float(ame_phi4_lower_bound(2, 2, 1)),
                    "mub": 7 / 4,
                },
                "AME(5,2)": {
                    "exact": str(ame_phi4_lower_bound(5, 2, 2)),
                    "float": float(ame_phi4_lower_bound(5, 2, 2)),
                    "mub": 63 / 32,
                },
                "AME(6,2)": {
                    "exact": str(ame_phi4_lower_bound(6, 2, 3)),
                    "float": float(ame_phi4_lower_bound(6, 2, 3)),
                    "mub": 127 / 64,
                },
            },
        },
        "pillar5_char3_char5_qgt": {
            "char3_alltop": [
                {"n": n, "D": 3**n, "counts": list(char3_alltop_spectrum(n)), "phi4": f"{2 * (3**n) - 1}/{3**n}"}
                for n in (1, 2, 3)
            ],
            "char5_alltop": [
                {"n": n, "D": 5**n, "counts": list(char5_alltop_spectrum(n)), "phi4": f"{2 * (5**n) - 1}/{5**n}"}
                for n in (1, 2)
            ],
            "qgt_n4_at_theta_star": two_stab_qgt_metric(16, math.acos(2.0 * (1.0 / (1.0 - float(t_star)) - 2.0))),
        },
    }
    with (data_dir / "exact_frontier_summary.json").open("w", encoding="utf-8", newline="\n") as f:
        f.write(json.dumps(summary, indent=2) + "\n")

    # 2. Alpha-Crossover Curve Data for Figure 2 (alpha in [1.5, 5.0])
    v42_c = [complex(r, im) for r, im in V42_SUPER_MUB]
    v44_c = [complex(r, im) for r, im in V44_SUPER_MUB]
    alphas = [round(1.5 + 0.1 * k, 2) for k in range(36)]
    alpha_rows = []
    for al in alphas:
        mub8 = 1.0 + 56.0 * ((1.0 / 8.0) ** al)
        mub16 = 1.0 + 240.0 * ((1.0 / 16.0) ** al)
        p42 = ref_product_wh_phi_alpha(v42_c, (4, 2), al)
        p44 = ref_product_wh_phi_alpha(v44_c, (4, 4), al)
        alpha_rows.append(
            {
                "alpha": al,
                "v42_phi": p42,
                "mub8_phi": mub8,
                "v42_delta_M": (math.log(8.0 / p42) - math.log(8.0 / mub8)) / (al - 1.0),
                "v44_phi": p44,
                "mub16_phi": mub16,
                "v44_delta_M": (math.log(16.0 / p44) - math.log(16.0 / mub16)) / (al - 1.0),
            }
        )
    with (data_dir / "alpha_crossover_curves.json").open("w", encoding="utf-8", newline="\n") as f:
        f.write(json.dumps(alpha_rows, indent=2) + "\n")

    # 3. Two-Stabilizer Tower Curves (n = 1..5) & QGT Metric
    tower_rows = []
    for step in range(181):
        theta = math.pi * step / 180.0
        row: dict[str, float] = {"theta": theta}
        for n in (1, 2, 3, 4, 5):
            dim = 1 << n
            denom = 2.0 + 2.0 * math.cos(theta) / math.sqrt(float(dim))
            t = 1.0 - 1.0 / denom
            half = dim / 2.0
            s3 = (4.0 / dim) * ((1.0 - t) ** 2) - ((1.0 - 2.0 * t) ** 2)
            phi4 = (
                1.0
                + 2.0 * (dim - 1.0) * (t**4)
                + (dim - 1.0) * (half - 1.0) * ((1.0 - 2.0 * t) ** 4)
                + (dim - 1.0) * half * (s3**2)
            )
            row[f"phi4_n{n}"] = phi4
            row[f"M2_n{n}"] = math.log(float(dim) / phi4)
            row[f"gtt_n{n}"] = two_stab_qgt_metric(dim, theta)
        tower_rows.append(row)
    with (data_dir / "two_stabilizer_tower_curves.json").open("w", encoding="utf-8", newline="\n") as f:
        f.write(json.dumps(tower_rows, indent=2) + "\n")
    print(f"[generate_data] Wrote 3 frozen JSON datasets to {data_dir}")
    print(f"[generate_data] N5 witness length check: {len(N5_RUPTURE_VEC)}")


if __name__ == "__main__":
    main()
