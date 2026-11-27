# SPDX-License-Identifier: Apache-2.0
# Copyright (c) 2026 Alexander Stephen Donahue
"""Independent brute-force floating-point/exact reference oracle (zero shared code with src/)."""

from __future__ import annotations

import cmath
import math
from collections.abc import Sequence


def ref_pauli_phi_alpha(psi: Sequence[complex], n_qubits: int, alpha: float) -> float:
    """Direct O(4^n * 2^n) textbook Pauli sum Phi_{2*alpha}(psi) for differential validation."""
    dim = 1 << n_qubits
    assert len(psi) == dim
    norm = math.sqrt(sum(abs(z) ** 2 for z in psi))
    u = [z / norm for z in psi]
    total = 0.0
    for a in range(dim):
        for b in range(dim):
            c = 0j
            for x in range(dim):
                sign = -1.0 if (bin(b & x).count("1") & 1) else 1.0
                c += u[x].conjugate() * u[x ^ a] * sign
            total += (abs(c) ** 2) ** alpha
    return total


def ref_product_wh_phi_alpha(psi: Sequence[complex], dims: tuple[int, ...], alpha: float) -> float:
    """Direct textbook product Weyl-Heisenberg sum Phi_{2*alpha}(psi)."""
    dim = 1
    for d in dims:
        dim *= d
    assert len(psi) == dim
    norm = math.sqrt(sum(abs(z) ** 2 for z in psi))
    u = [z / norm for z in psi]

    def unpack(idx: int) -> tuple[int, ...]:
        res = []
        for d in reversed(dims):
            res.append(idx % d)
            idx //= d
        return tuple(reversed(res))

    def pack(t: Sequence[int]) -> int:
        val = 0
        for d, v in zip(dims, t):
            val = val * d + (v % d)
        return val

    total = 0.0
    for a in range(dim):
        au = unpack(a)
        for b in range(dim):
            bu = unpack(b)
            c = 0j
            for x in range(dim):
                xu = unpack(x)
                xa = pack([(xu[k] + au[k]) % dims[k] for k in range(len(dims))])
                ang = sum(2.0 * math.pi * bu[k] * xu[k] / dims[k] for k in range(len(dims)))
                c += u[x].conjugate() * u[xa] * cmath.exp(1j * ang)
            total += (abs(c) ** 2) ** alpha
    return total
