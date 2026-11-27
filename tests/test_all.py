# SPDX-License-Identifier: Apache-2.0
# Copyright (c) 2026 Alexander Stephen Donahue
"""Comprehensive unit, property (Hypothesis), metamorphic, differential, and mutation-killing suite."""

from __future__ import annotations

import json
import math
import os
import re
import sys
from fractions import Fraction
from pathlib import Path

import pytest
import yaml
from jsonschema import Draft202012Validator

try:
    from hypothesis import given, settings
    from hypothesis import strategies as st

    HAS_HYPOTHESIS = True
except ImportError:
    HAS_HYPOTHESIS = False

ROOT = Path(__file__).resolve().parents[1]
_MUTANT_SRC = os.environ.get("WEYL_MAGIC_MUTANT_SRC")
if _MUTANT_SRC:
    sys.path.insert(0, _MUTANT_SRC)
else:
    sys.path.append(str(ROOT / "src"))
if str(ROOT) not in sys.path:
    sys.path.append(str(ROOT))

from reference.oracle import ref_pauli_phi_alpha, ref_product_wh_phi_alpha  # noqa: E402
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
    qrng_absorb_u64,
    qrng_stream_next,
    two_stab_phi4_exact,
    two_stab_qgt_metric,
    v2_valuation,
    wh_gauss_moments,
    wh_z8_spectrum,
)

# ---- Pillar 1 Tests --------------------------------------------------------


if HAS_HYPOTHESIS:

    @given(k=st.integers(min_value=1, max_value=40))
    @settings(max_examples=40)
    def test_pillar1_odd_two_adic_valuation_always_odd(k: int) -> None:
        n = 2 * k + 1  # odd n >= 3
        lhs = (2**n) * ((2**n - 2) ** 2)
        val = v2_valuation(lhs)
        assert val == n + 2
        assert (val & 1) == 1
        root = math.isqrt(lhs)
        assert root * root != lhs

else:

    @pytest.mark.parametrize("k", list(range(1, 41)))
    def test_pillar1_odd_two_adic_valuation_always_odd(k: int) -> None:
        n = 2 * k + 1  # odd n >= 3
        lhs = (2**n) * ((2**n - 2) ** 2)
        val = v2_valuation(lhs)
        assert val == n + 2
        assert (val & 1) == 1
        root = math.isqrt(lhs)
        assert root * root != lhs


def test_pillar1_sharpness_n1_n2() -> None:
    assert (2**1) * ((2**1 - 2) ** 2) == 0
    assert (2**2) * ((2**2 - 2) ** 2) == 16 == 4 * 4
    assert n2_mub_phi4() == Fraction(7, 4)


# ---- Pillar 2 Tests --------------------------------------------------------


def test_pillar2_exhaustive_65536_f2_4() -> None:
    res = audit_all_f2_4_bent()
    assert res["total_functions"] == 65536
    assert res["total_bent"] == 896
    assert res["quad_bent"] == 896
    assert res["deg_gt2_bent"] == 0
    assert res["bent_with_zero_triple"] == 896


if HAS_HYPOTHESIS:

    @given(m=st.integers(min_value=0, max_value=5))
    def test_pillar2_fermat_gaussian_pow2_locking(m: int) -> None:
        target = 1 << (2 * m)
        bound = 1 << m
        sols = [
            (r, im) for r in range(-bound, bound + 1) for im in range(-bound, bound + 1) if r * r + im * im == target
        ]
        assert set(sols) == {(bound, 0), (-bound, 0), (0, bound), (0, -bound)}

else:

    @pytest.mark.parametrize("m", [0, 1, 2, 3, 4, 5])
    def test_pillar2_fermat_gaussian_pow2_locking(m: int) -> None:
        target = 1 << (2 * m)
        bound = 1 << m
        sols = [
            (r, im) for r in range(-bound, bound + 1) for im in range(-bound, bound + 1) if r * r + im * im == target
        ]
        assert set(sols) == {(bound, 0), (-bound, 0), (0, bound), (0, -bound)}


# ---- Pillar 3 Tests & Differential Checks ----------------------------------


def test_pillar3_z8_mubs_exact() -> None:
    norm42, c42 = wh_z8_spectrum((4, 2), PSI42_Z8)
    assert norm42 == (8, 0)
    assert c42 == {(64, 0): 1, (0, 0): 7, (8, 0): 56}

    norm44, c44 = wh_z8_spectrum((4, 4), PSI44_Z8)
    assert norm44 == (320, 0)
    assert c44 == {(102400, 0): 1, (0, 0): 15, (6400, 0): 240}


def test_pillar3_super_mub_and_alpha_crossover() -> None:
    n42, p4_42, p6_42, p8_42 = wh_gauss_moments((4, 2), V42_SUPER_MUB)
    assert n42 == 1001
    assert p4_42 < Fraction(15, 8)
    assert p6_42 < Fraction(71, 64)
    assert p8_42 > Fraction(519, 512)

    n44, p4_44, p6_44, p8_44 = wh_gauss_moments((4, 4), V44_SUPER_MUB)
    assert n44 == 1596
    assert p4_44 < Fraction(31, 16)
    assert p6_44 < Fraction(271, 256)
    assert p8_44 > Fraction(4111, 4096)

    # Differential check against completely independent textbook complex reference oracle
    v42_c = [complex(r, im) for r, im in V42_SUPER_MUB]
    assert abs(ref_product_wh_phi_alpha(v42_c, (4, 2), 2.0) - float(p4_42)) < 1e-12
    assert abs(ref_product_wh_phi_alpha(v42_c, (4, 2), 3.0) - float(p6_42)) < 1e-12
    assert abs(ref_product_wh_phi_alpha(v42_c, (4, 2), 4.0) - float(p8_42)) < 1e-12


def test_pillar3_metamorphic_global_phase_and_scale_invariance() -> None:
    # Multiplying state by Gaussian integer (2 + 3i) leaves exact Phi_4, Phi_6, Phi_8 invariant!
    scaled = [(2 * r - 3 * im, 3 * r + 2 * im) for r, im in V42_SUPER_MUB]
    _, p4_a, p6_a, p8_a = wh_gauss_moments((4, 2), V42_SUPER_MUB)
    _, p4_b, p6_b, p8_b = wh_gauss_moments((4, 2), scaled)
    assert (p4_a, p6_a, p8_a) == (p4_b, p6_b, p8_b)


# ---- Pillar 4 Tests --------------------------------------------------------


def test_pillar4_two_stab_unification_and_n4_cubic() -> None:
    assert two_stab_phi4_exact(4, Fraction(1, 2)) == Fraction(7, 4)
    assert two_stab_phi4_exact(8, Fraction(1, 3)) == Fraction(16, 9)

    t_star, phi4_star, m2_star = n4_cubic_root_decimal(50)
    assert Fraction(3774568, 10**7) < Fraction(t_star) < Fraction(3774569, 10**7)
    assert abs(float(phi4_star) - 2.1505201547139396) < 1e-13
    assert abs(float(m2_star) - 2.0068789769360514) < 1e-13

    # Differential check against textbook 4-qubit Pauli sum on |Psi_4(theta*)>
    theta_star = math.acos(2.0 * (1.0 / (1.0 - float(t_star)) - 2.0))
    psi4 = [
        complex(0.25 * math.cos(theta_star) + (1.0 if x == 0 else 0.0), 0.25 * math.sin(theta_star)) for x in range(16)
    ]
    assert abs(ref_pauli_phi_alpha(psi4, 4, 2.0) - float(phi4_star)) < 1e-12


if HAS_HYPOTHESIS:

    @given(
        p=st.integers(min_value=-50, max_value=50),
        q=st.integers(min_value=1, max_value=50),
    )
    def test_pillar4_n5_sos_floor_property(p: int, q: int) -> None:
        assert two_stab_phi4_exact(32, Fraction(p, q)) >= Fraction(3, 1)

else:

    @pytest.mark.parametrize(
        "p,q",
        [(p, q) for p in range(-10, 11) for q in (1, 2, 3, 5, 7)],
    )
    def test_pillar4_n5_sos_floor_property(p: int, q: int) -> None:
        assert two_stab_phi4_exact(32, Fraction(p, q)) >= Fraction(3, 1)


def test_pillar4_n5_rupture_and_ame_ceilings() -> None:
    norm2, num4, phi4 = n5_rupture_exact()
    assert norm2 == 254
    assert num4 == 11097089024
    assert phi4 == Fraction(693568064, 260144641)
    assert phi4 < Fraction(3, 1)

    assert ame_phi4_lower_bound(2, 2, 1) == Fraction(2, 1) > Fraction(7, 4)
    assert ame_phi4_lower_bound(5, 2, 2) == Fraction(1879, 918) > Fraction(63, 32)
    assert ame_phi4_lower_bound(6, 2, 3) == Fraction(13, 6) > Fraction(127, 64)


# ---- Pillar 5 Tests & Cross-Engine Differential Checks ---------------------


def test_pillar5_char3_char5_and_qgt() -> None:
    assert char3_alltop_spectrum(1) == (1, 2, 6, 0)
    assert char3_alltop_spectrum(2) == (1, 8, 72, 0)
    assert char3_alltop_spectrum(3) == (1, 26, 702, 0)
    assert char5_alltop_spectrum(1) == (1, 4, 20, 0)
    assert char5_alltop_spectrum(2) == (1, 24, 600, 0)

    # Exact QGT vs Richardson-extrapolated Fubini-Study line element
    for n in (1, 2, 3, 4):
        dim = 1 << n
        th = 1.1
        s = 1.0 / math.sqrt(dim)

        def state(ang: float, d_cur: int = dim, s_cur: float = s) -> list[complex]:
            nrm = math.sqrt(2.0 + 2.0 * s_cur * math.cos(ang))
            return [
                complex(s_cur * math.cos(ang) + (1.0 if x == 0 else 0.0), s_cur * math.sin(ang)) / nrm
                for x in range(d_cur)
            ]

        def g_at(eps: float, angle: float = th) -> float:
            pm = state(angle - eps)
            pp = state(angle + eps)
            ov = abs(sum(a.conjugate() * b for a, b in zip(pm, pp)))
            ds = math.acos(min(1.0, ov))
            return (ds / (2.0 * eps)) ** 2

        g_fd = (4.0 * g_at(5e-4) - g_at(1e-3)) / 3.0
        g_ex = two_stab_qgt_metric(dim, th)
        assert abs(g_fd - g_ex) / g_ex < 1e-7


def test_qrng_bit_exact_cross_language_known_answers() -> None:
    # Matches C11 (c/src/qrng_stream.c) and JS BigInt (node/moonlab_crosscheck.cjs) bit-for-bit!
    st_val = qrng_absorb_u64(1)
    assert f"{st_val:016x}" == "532662e3dcf55ef7"
    assert f"{qrng_stream_next(st_val, 0):016x}" == "5df9ef9ba7cdcca2"
    assert f"{qrng_stream_next(st_val, 1):016x}" == "ddb5674ec90579d9"


def test_all_frozen_json_datasets_consistent() -> None:
    rust_json = ROOT / "data" / "rust_exact_crosscheck.json"
    assert rust_json.exists(), "missing data/rust_exact_crosscheck.json"
    data = json.loads(rust_json.read_text(encoding="utf-8-sig"))
    assert data["bent4"] == {"total": 896, "quad": 896, "deg_gt2": 0, "zero_triple": 896}
    assert data["w42_z8_mub"] == {"norm2": 8, "counts": [1, 7, 56, 0]}
    assert data["w44_z8_mub"] == {"norm2": 320, "counts": [1, 15, 240, 0]}
    assert data["w42_super_mub"]["num4"] == "1851540086824"
    assert data["w44_super_mub"]["num4"] == "12399519780160"
    assert data["n5_rupture"] == {"norm2": 254, "num4": "11097089024"}
    assert data["char3_alltop"] == [
        {"n": 1, "counts": [1, 2, 6, 0]},
        {"n": 2, "counts": [1, 8, 72, 0]},
        {"n": 3, "counts": [1, 26, 702, 0]},
        {"n": 4, "counts": [1, 80, 6480, 0]},
    ]

    summary = json.loads((ROOT / "data" / "exact_frontier_summary.json").read_text(encoding="utf-8-sig"))
    assert summary["id"] == "0TH-2026-022"
    assert summary["pillar2_bent4"]["total_bent"] == 896
    assert summary["pillar4_two_stab_and_ame"]["n5_rupture_num4"] == "11097089024"

    cpp = json.loads((ROOT / "data" / "cpp_search_phase_diagram.json").read_text(encoding="utf-8-sig"))
    assert cpp["starts_per_group"] == 64
    gmap = {row["group"]: row for row in cpp["groups"]}
    assert set(gmap.keys()) == {"Z8", "Z4xZ2", "Z2^3", "Z16", "Z8xZ2", "Z4xZ4", "Z4xZ2^2", "Z2^4"}
    assert gmap["Z4xZ2"]["best_phi4"] < 15 / 8
    assert gmap["Z4xZ4"]["best_phi4"] < 31 / 16
    assert abs(gmap["Z2^4"]["best_phi4"] - 2.150520154714) < 1e-9

    alpha_rows = json.loads((ROOT / "data" / "alpha_crossover_curves.json").read_text(encoding="utf-8-sig"))
    assert len(alpha_rows) == 36
    row2 = next(r for r in alpha_rows if r["alpha"] == 2.0)
    row4 = next(r for r in alpha_rows if r["alpha"] == 4.0)
    assert row2["v42_delta_M"] > 0 and row2["v44_delta_M"] > 0
    assert row4["v42_delta_M"] < 0 and row4["v44_delta_M"] < 0

    tower_rows = json.loads((ROOT / "data" / "two_stabilizer_tower_curves.json").read_text(encoding="utf-8-sig"))
    assert len(tower_rows) == 181
    assert all(r["phi4_n5"] >= 3.0 - 1e-12 for r in tower_rows)


def test_repo_yaml_draft2020_12_schema_valid() -> None:
    schema = json.loads((ROOT / "repo-standard.schema.json").read_text(encoding="utf-8"))
    manifest = yaml.safe_load((ROOT / "repo.yaml").read_text(encoding="utf-8"))
    validator = Draft202012Validator(schema)
    errors = sorted(validator.iter_errors(manifest), key=lambda e: list(e.path))
    assert errors == [], [f"{list(e.path)}: {e.message}" for e in errors]
    assert manifest["items"]["B44"]["status"] == "partial"


def test_citation_cff_and_version_single_source_of_truth() -> None:
    version = (ROOT / "VERSION").read_text(encoding="utf-8").strip()
    assert re.fullmatch(r"\d+\.\d+\.\d+", version)

    cff = yaml.safe_load((ROOT / "CITATION.cff").read_text(encoding="utf-8"))
    assert cff["cff-version"] == "1.2.0"
    assert cff["version"] == version
    assert cff["authors"][0]["orcid"] == "https://orcid.org/0009-0006-8168-9648"
    assert any(
        ident.get("type") == "swh" and str(ident.get("value", "")).startswith("swh:1:")
        for ident in cff["identifiers"]
    )

    assert f'version = "{version}"' in (ROOT / "pyproject.toml").read_text(encoding="utf-8")
    assert f'version = "{version}"' in (ROOT / "rust" / "Cargo.toml").read_text(encoding="utf-8")
    assert f'version = "{version}"' in (ROOT / "lean" / "lakefile.toml").read_text(encoding="utf-8")
    assert f'version: "{version}"' in (ROOT / "lean" / "formalization.yaml").read_text(encoding="utf-8")
    assert f"`v{version}`" in (ROOT / "README.md").read_text(encoding="utf-8")
    assert f"Version {version}" in (ROOT / "paper" / "main.tex").read_text(encoding="utf-8")


# ---- Mutation-Killing Tests (ensure witnesses are genuinely sensitive) -----


def test_mutation_killing_perturbed_witnesses_fail_mub() -> None:
    bad_psi42 = list(PSI42_Z8)
    bad_psi42[0] = (1, -1, 0, 0)
    _, counts = wh_z8_spectrum((4, 2), bad_psi42)
    assert counts != {(64, 0): 1, (0, 0): 7, (8, 0): 56}

    # Perturbing n5 vector drastically increases Phi_4
    bad_n5 = [(1, 0)] + [(0, 0)] * 31
    _, p4_stab, _, _ = wh_gauss_moments((2, 2, 2, 2, 2), bad_n5)
    assert p4_stab == Fraction(32, 1) > Fraction(3, 1)
    assert len(N5_RUPTURE_VEC) == 32
