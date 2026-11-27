# SPDX-License-Identifier: Apache-2.0
# Copyright (c) 2026 Alexander Stephen Donahue
"""Exact arithmetic oracle for the Weyl-Heisenberg Magic Obstruction Frontier."""

from .oracle import (
    AME_CEILINGS,
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

__all__ = [
    "AME_CEILINGS",
    "N5_RUPTURE_VEC",
    "PSI42_Z8",
    "PSI44_Z8",
    "V42_SUPER_MUB",
    "V44_SUPER_MUB",
    "ame_phi4_lower_bound",
    "audit_all_f2_4_bent",
    "char3_alltop_spectrum",
    "char5_alltop_spectrum",
    "n2_mub_phi4",
    "n4_cubic_root_decimal",
    "n5_rupture_exact",
    "qrng_absorb_u64",
    "qrng_stream_next",
    "two_stab_phi4_exact",
    "two_stab_qgt_metric",
    "v2_valuation",
    "wh_gauss_moments",
    "wh_z8_spectrum",
]
