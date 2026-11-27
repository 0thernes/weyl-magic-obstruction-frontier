# SPDX-License-Identifier: Apache-2.0
# Copyright (c) 2026 Alexander Stephen Donahue
"""Exact rational, cyclotomic, and high-precision Decimal oracle across all five pillars."""

from __future__ import annotations

import math
from collections.abc import Sequence
from decimal import Decimal, getcontext
from fractions import Fraction

Gauss = tuple[int, int]
Zeta8 = tuple[int, int, int, int]
Zeta9 = tuple[int, int, int, int, int, int]
Zeta5 = tuple[int, int, int, int]

# ---- Pillar 3 Exact Witnesses ----------------------------------------------

PSI42_Z8: tuple[Zeta8, ...] = (
    (0, -1, 0, 0),
    (-1, 0, -1, 0),
    (1, 0, 0, 0),
    (0, 0, 0, 0),
    (0, 0, 0, -1),
    (0, 0, 0, 0),
    (0, 0, 1, 0),
    (0, 1, 0, -1),
)

PSI44_Z8: tuple[Zeta8, ...] = (
    (3, 0, 1, 0),
    (-1, 0, 3, 0),
    (-3, 0, -1, 0),
    (-1, 0, 3, 0),
    (0, 3, 0, 1),
    (0, 1, 0, 7),
    (0, 3, 0, 1),
    (0, 3, 0, 1),
    (-3, 0, -1, 0),
    (-1, 0, 3, 0),
    (-1, 0, -7, 0),
    (-5, 0, -5, 0),
    (0, -3, 0, -1),
    (0, -3, 0, -1),
    (0, 5, 0, -5),
    (0, 3, 0, 1),
)

V42_SUPER_MUB: tuple[Gauss, ...] = (
    (-2, 5),
    (-2, 5),
    (-9, 9),
    (-9, -10),
    (-11, -4),
    (-11, -4),
    (-1, -18),
    (0, 1),
)

V44_SUPER_MUB: tuple[Gauss, ...] = (
    (9, -10),
    (-7, -1),
    (4, 4),
    (2, 15),
    (1, 1),
    (-7, 0),
    (2, -1),
    (5, 2),
    (14, -7),
    (-6, 14),
    (3, 6),
    (-5, -1),
    (-2, 1),
    (0, -16),
    (3, 4),
    (-4, 13),
)

N5_RUPTURE_VEC: tuple[Gauss, ...] = (
    (1, -2),
    (-1, 0),
    (-2, -3),
    (-2, -3),
    (0, -1),
    (-5, 3),
    (-2, 2),
    (1, 1),
    (0, 1),
    (1, -2),
    (1, -1),
    (1, 0),
    (0, -1),
    (-2, -3),
    (-1, 0),
    (0, 3),
    (0, -1),
    (-1, 2),
    (-3, 2),
    (-5, -2),
    (-1, -1),
    (1, 0),
    (-3, 1),
    (2, 2),
    (0, 3),
    (1, 0),
    (-3, 3),
    (1, 1),
    (-3, 2),
    (3, -2),
    (-3, 0),
    (1, 3),
)

AME_CEILINGS: dict[str, tuple[int, int, int, Fraction]] = {
    "AME(2,2)": (2, 2, 1, Fraction(2, 1)),
    "AME(5,2)": (5, 2, 2, Fraction(1879, 918)),
    "AME(6,2)": (6, 2, 3, Fraction(13, 6)),
}

# ---- Pillar 1: 2-Adic Valuation & Sharpness --------------------------------


def v2_valuation(n: int) -> int:
    """Exact 2-adic valuation v_2(n) for nonzero integer n."""
    if n == 0:
        raise ValueError("v_2(0) is infinite")
    x = abs(n)
    k = 0
    while (x & 1) == 0:
        x >>= 1
        k += 1
    return k


def n2_mub_phi4() -> Fraction:
    """Exact Phi_4 for the 2-qubit WH-MUB fiducial (1, 1, 1, i)."""
    v: tuple[Gauss, ...] = ((1, 0), (1, 0), (1, 0), (0, 1))
    _, phi4, _, _ = wh_gauss_moments((2, 2), v)
    return phi4


# ---- Pillar 2: F_2^4 Exhaustive Bent Audit ---------------------------------


def _fwht_int(buf: list[int]) -> list[int]:
    arr = list(buf)
    n = len(arr)
    half = 1
    while half < n:
        step = half << 1
        for base in range(0, n, step):
            for k in range(half):
                x = arr[base + k]
                y = arr[base + k + half]
                arr[base + k] = x + y
                arr[base + k + half] = x - y
        half <<= 1
    return arr


def audit_all_f2_4_bent() -> dict[str, int]:
    """Exhaustively scan all 65,536 Boolean functions on F_2^4."""
    total_bent = 0
    quad_bent = 0
    deg_gt2_bent = 0
    zero_triple = 0
    for tt in range(65536):
        signs = [-1 if ((tt >> x) & 1) else 1 for x in range(16)]
        w = _fwht_int(signs)
        if not all(v in (4, -4) for v in w):
            continue
        total_bent += 1
        anf = [(tt >> x) & 1 for x in range(16)]
        for bit in range(4):
            step = 1 << bit
            for x in range(16):
                if x & step:
                    anf[x] ^= anf[x ^ step]
        max_deg = max((bin(m).count("1") for m in range(16) if anf[m]), default=0)
        if max_deg <= 2:
            quad_bent += 1
        else:
            deg_gt2_bent += 1
        ea = [0] * 16
        for a in range(1, 16):
            mask = 0
            for x in range(16):
                if ((tt >> x) & 1) == ((tt >> (x ^ a)) & 1):
                    mask |= 1 << x
            ea[a] = mask
        found = False
        for a in range(1, 16):
            for b in range(a + 1, 16):
                if (ea[a] ^ ea[b] ^ ea[a ^ b]) == 0:
                    found = True
                    break
            if found:
                break
        if found:
            zero_triple += 1
    return {
        "total_functions": 65536,
        "total_bent": total_bent,
        "quad_bent": quad_bent,
        "deg_gt2_bent": deg_gt2_bent,
        "bent_with_zero_triple": zero_triple,
    }


# ---- Pillar 3: Exact Z[zeta_8] & Z[i] Product WH Evaluators ----------------


def _unpack(x: int, dims: Sequence[int]) -> list[int]:
    out: list[int] = []
    for d in reversed(dims):
        out.append(x % d)
        x //= d
    out.reverse()
    return out


def _pack(tup: Sequence[int], dims: Sequence[int]) -> int:
    x = 0
    for d, v in zip(dims, tup):
        x = x * d + (v % d)
    return x


def _z8_add(a: Zeta8, b: Zeta8) -> Zeta8:
    return (a[0] + b[0], a[1] + b[1], a[2] + b[2], a[3] + b[3])


def _z8_conj(x: Zeta8) -> Zeta8:
    return (x[0], -x[3], -x[2], -x[1])


def _z8_mul(a: Zeta8, b: Zeta8) -> Zeta8:
    return (
        a[0] * b[0] - a[1] * b[3] - a[2] * b[2] - a[3] * b[1],
        a[0] * b[1] + a[1] * b[0] - a[2] * b[3] - a[3] * b[2],
        a[0] * b[2] + a[1] * b[1] + a[2] * b[0] - a[3] * b[3],
        a[0] * b[3] + a[1] * b[2] + a[2] * b[1] + a[3] * b[0],
    )


def _z8_mul_i(x: Zeta8, q: int) -> Zeta8:
    m = q & 3
    if m == 0:
        return x
    if m == 1:
        return (-x[2], -x[3], x[0], x[1])
    if m == 2:
        return (-x[0], -x[1], -x[2], -x[3])
    return (x[2], x[3], -x[0], -x[1])


def wh_z8_spectrum(dims: Sequence[int], vec: Sequence[Zeta8]) -> tuple[tuple[int, int], dict[tuple[int, int], int]]:
    """Exact squared norm and squared-expectation counts in Z[sqrt(2)] for dims in {2, 4}."""
    dim = 1
    for d in dims:
        dim *= d
    norm_r0 = 0
    norm_r1 = 0
    for v in vec:
        p = _z8_mul(v, _z8_conj(v))
        assert p[2] == 0 and p[3] == -p[1]
        norm_r0 += p[0]
        norm_r1 += p[1]
    counts: dict[tuple[int, int], int] = {}
    for a in range(dim):
        au = _unpack(a, dims)
        for b in range(dim):
            bu = _unpack(b, dims)
            s: Zeta8 = (0, 0, 0, 0)
            for x in range(dim):
                xu = _unpack(x, dims)
                xa = _pack([(xu[k] + au[k]) % dims[k] for k in range(len(dims))], dims)
                prod = _z8_mul(_z8_conj(vec[x]), vec[xa])
                q = sum((4 // dims[k]) * bu[k] * xu[k] for k in range(len(dims)))
                s = _z8_add(s, _z8_mul_i(prod, q))
            ns = _z8_mul(s, _z8_conj(s))
            assert ns[2] == 0 and ns[3] == -ns[1]
            key = (ns[0], ns[1])
            counts[key] = counts.get(key, 0) + 1
    return (norm_r0, norm_r1), counts


def wh_gauss_moments(dims: Sequence[int], vec: Sequence[Gauss]) -> tuple[int, Fraction, Fraction, Fraction]:
    """Exact norm^2 and rational (Phi_4, Phi_6, Phi_8) for a Z[i]^D vector."""
    dim = 1
    for d in dims:
        dim *= d
    norm2 = sum(r * r + im * im for r, im in vec)
    num4 = 0
    num6 = 0
    num8 = 0
    for a in range(dim):
        au = _unpack(a, dims)
        for b in range(dim):
            bu = _unpack(b, dims)
            sre = 0
            sim = 0
            for x in range(dim):
                xu = _unpack(x, dims)
                xa = _pack([(xu[k] + au[k]) % dims[k] for k in range(len(dims))], dims)
                cr = vec[x][0] * vec[xa][0] + vec[x][1] * vec[xa][1]
                ci = vec[x][0] * vec[xa][1] - vec[x][1] * vec[xa][0]
                q = sum((4 // dims[k]) * bu[k] * xu[k] for k in range(len(dims))) & 3
                if q == 1:
                    cr, ci = -ci, cr
                elif q == 2:
                    cr, ci = -cr, -ci
                elif q == 3:
                    cr, ci = ci, -cr
                sre += cr
                sim += ci
            m = sre * sre + sim * sim
            m2 = m * m
            num4 += m2
            num6 += m2 * m
            num8 += m2 * m2
    return (
        norm2,
        Fraction(num4, norm2**4),
        Fraction(num6, norm2**6),
        Fraction(num8, norm2**8),
    )


# ---- Pillar 4: Two-Stabilizer Tower, 4-Qubit Cubic, n=5 Rupture, AME -------


def two_stab_phi4_exact(dim: int, t: Fraction) -> Fraction:
    """Exact closed-form Phi_4(|Psi_n(theta)>) for D = 2^n and t = 1 - 1/(2 + 2 cos(theta)/sqrt(D))."""
    half = dim // 2
    s1 = t**4
    s2 = (1 - 2 * t) ** 4
    s3_sq = (Fraction(4, dim) * (1 - t) ** 2 - (1 - 2 * t) ** 2) ** 2
    return 1 + 2 * (dim - 1) * s1 + (dim - 1) * (half - 1) * s2 + (dim - 1) * half * s3_sq


def n4_cubic_root_decimal(prec: int = 60) -> tuple[Decimal, Decimal, Decimal]:
    """High-precision Decimal root t* of 453t^3 - 651t^2 + 311t - 49 = 0, Phi_4(t*), M_2(t*)."""
    getcontext().prec = prec + 10
    t = Decimal("0.37745680")
    for _ in range(30):
        f = Decimal(453) * t**3 - Decimal(651) * t**2 + Decimal(311) * t - Decimal(49)
        df = Decimal(1359) * t**2 - Decimal(1302) * t + Decimal(311)
        t = t - f / df
    phi4 = (
        Decimal(6795) * t**4 - Decimal(13020) * t**3 + Decimal(9330) * t**2 - Decimal(2940) * t + Decimal(347)
    ) / Decimal(2)
    m2 = (Decimal(16) / phi4).ln()
    getcontext().prec = prec
    return +t, +phi4, +m2


def n5_rupture_exact() -> tuple[int, int, Fraction]:
    """Exact norm^2, unnormalized num4, and rational Phi_4 of the 5-qubit rupture witness."""
    norm2 = sum(r * r + im * im for r, im in N5_RUPTURE_VEC)
    num4 = 0
    for a in range(32):
        re_arr = [
            N5_RUPTURE_VEC[x][0] * N5_RUPTURE_VEC[x ^ a][0] + N5_RUPTURE_VEC[x][1] * N5_RUPTURE_VEC[x ^ a][1]
            for x in range(32)
        ]
        im_arr = [
            N5_RUPTURE_VEC[x][0] * N5_RUPTURE_VEC[x ^ a][1] - N5_RUPTURE_VEC[x][1] * N5_RUPTURE_VEC[x ^ a][0]
            for x in range(32)
        ]
        fre = _fwht_int(re_arr)
        fim = _fwht_int(im_arr)
        for b in range(32):
            m = fre[b] * fre[b] + fim[b] * fim[b]
            num4 += m * m
    return norm2, num4, Fraction(num4, norm2**4)


def ame_phi4_lower_bound(n: int, d: int, k: int) -> Fraction:
    """Universal Cauchy-Schwarz Phi_4 lower bound for any k-uniform / AME(n, d) pure state."""
    z_zeros = sum(math.comb(n, w) * ((d * d - 1) ** w) for w in range(1, k + 1))
    n_rem = d ** (2 * n) - 1 - z_zeros
    return 1 + Fraction((d**n - 1) ** 2, n_rem)


# ---- Pillar 5: Divided-Power Char-3 & Char-5 Alltop, Exact QGT, QRNG -------


def _z9_pow(k: int) -> Zeta9:
    m = k % 9
    if m < 6:
        arr = [0] * 6
        arr[m] = 1
        return (arr[0], arr[1], arr[2], arr[3], arr[4], arr[5])
    arr = [0] * 6
    arr[m - 6] = -1
    arr[m - 3] = -1
    return (arr[0], arr[1], arr[2], arr[3], arr[4], arr[5])


def _z9_mul(a: Zeta9, b: Zeta9) -> Zeta9:
    t = [0] * 11
    for i in range(6):
        for j in range(6):
            t[i + j] += a[i] * b[j]
    for k in range(10, 5, -1):
        v = t[k]
        t[k - 3] -= v
        t[k - 6] -= v
    return (t[0], t[1], t[2], t[3], t[4], t[5])


def _z9_conj(x: Zeta9) -> Zeta9:
    return (x[0] - x[3], -x[2], -x[1], -x[3], x[5] - x[2], x[4] - x[1])


def char3_alltop_spectrum(n: int) -> tuple[int, int, int, int]:
    """Exact Z[zeta_9] spectrum counts (cId, cZero, cFlat, cOther) for W(3)^tensor-n (n=1..4)."""
    polys: dict[int, tuple[int, ...]] = {
        1: (1,),
        2: (2, 0),
        3: (2, 1, 0),
        4: (1, 2, 0, 0),
    }
    poly = polys[n]
    dim = 3**n

    def fmul(u: Sequence[int], v: Sequence[int]) -> list[int]:
        tmp = [0] * (2 * n - 1)
        for i in range(n):
            for j in range(n):
                tmp[i + j] = (tmp[i + j] + u[i] * v[j]) % 3
        for k in range(2 * n - 2, n - 1, -1):
            c = tmp[k]
            tmp[k] = 0
            if c:
                for i in range(n):
                    tmp[k - n + i] = (tmp[k - n + i] + c * poly[i]) % 3
        return tmp[:n]

    def ftrace(u: Sequence[int]) -> int:
        tr = 0
        for i in range(n):
            ei = [1 if j == i else 0 for j in range(n)]
            tr = (tr + fmul(u, ei)[i]) % 3
        return tr

    basis = [[1 if j == i else 0 for j in range(n)] for i in range(n)]
    ten = [[[ftrace(fmul(fmul(basis[i], basis[j]), basis[k])) for k in range(n)] for j in range(n)] for i in range(n)]
    vecs: list[list[int]] = []
    g: list[int] = []
    for x in range(dim):
        tmp = x
        xu = []
        for _ in range(n):
            xu.append(tmp % 3)
            tmp //= 3
        vecs.append(xu)
        val = sum(ten[i][i][i] * xu[i] for i in range(n))
        for i in range(n):
            for j in range(n):
                if i != j:
                    val += 3 * ten[i][i][j] * xu[i] * xu[i] * xu[j]
        for i in range(n):
            for j in range(i + 1, n):
                for k in range(j + 1, n):
                    val += 6 * ten[i][j][k] * xu[i] * xu[j] * xu[k]
        g.append(val % 9)

    ci = cz = cf = co = 0
    id_val = dim * dim
    for a in range(dim):
        va = vecs[a]
        for b in range(dim):
            vb = vecs[b]
            s = [0, 0, 0, 0, 0, 0]
            for x in range(dim):
                vx = vecs[x]
                xa = 0
                mult = 1
                bx = 0
                for i in range(n):
                    xa += ((vx[i] + va[i]) % 3) * mult
                    mult *= 3
                    bx += vb[i] * vx[i]
                p = _z9_pow((g[xa] + 9 - g[x] + 3 * bx) % 9)
                for r in range(6):
                    s[r] += p[r]
            st: Zeta9 = (s[0], s[1], s[2], s[3], s[4], s[5])
            ns = _z9_mul(st, _z9_conj(st))
            if any(ns[r] != 0 for r in range(1, 6)):
                co += 1
            elif ns[0] == id_val:
                ci += 1
            elif ns[0] == 0:
                cz += 1
            elif ns[0] == dim:
                cf += 1
            else:
                co += 1
    return (ci, cz, cf, co)


def _z5_pow(k: int) -> Zeta5:
    m = k % 5
    if m == 0:
        return (1, 0, 0, 0)
    if m == 1:
        return (0, 1, 0, 0)
    if m == 2:
        return (0, 0, 1, 0)
    if m == 3:
        return (0, 0, 0, 1)
    return (-1, -1, -1, -1)


def _z5_mul(a: Zeta5, b: Zeta5) -> Zeta5:
    t0 = a[0] * b[0]
    t1 = a[0] * b[1] + a[1] * b[0]
    t2 = a[0] * b[2] + a[1] * b[1] + a[2] * b[0]
    t3 = a[0] * b[3] + a[1] * b[2] + a[2] * b[1] + a[3] * b[0]
    t4 = a[1] * b[3] + a[2] * b[2] + a[3] * b[1]
    t5 = a[2] * b[3] + a[3] * b[2]
    t6 = a[3] * b[3]
    return (t0 + t5 - t4, t1 + t6 - t4, t2 - t4, t3 - t4)


def _z5_conj(x: Zeta5) -> Zeta5:
    return (x[0] - x[1], -x[1], x[3] - x[1], x[2] - x[1])


def char5_alltop_spectrum(n: int) -> tuple[int, int, int, int]:
    """Exact Z[zeta_5] spectrum counts for W(5)^tensor-n (n = 1, 2)."""
    if n == 1:
        dim = 5
        g = [(x**3) % 5 for x in range(5)]
        vecs = [[x] for x in range(5)]
    elif n == 2:
        dim = 25
        vecs = [[x % 5, x // 5] for x in range(25)]
        g = [(2 * v[0] ** 3 + 2 * v[0] * v[1] ** 2) % 5 for v in vecs]
    else:
        raise ValueError("n must be 1 or 2")
    ci = cz = cf = co = 0
    id_val = dim * dim
    for a in range(dim):
        va = vecs[a]
        for b in range(dim):
            vb = vecs[b]
            s = [0, 0, 0, 0]
            for x in range(dim):
                vx = vecs[x]
                xa = 0
                mult = 1
                bx = 0
                for i in range(n):
                    xa += ((vx[i] + va[i]) % 5) * mult
                    mult *= 5
                    bx += vb[i] * vx[i]
                p = _z5_pow((g[xa] + 5 - g[x] + bx) % 5)
                for r in range(4):
                    s[r] += p[r]
            st: Zeta5 = (s[0], s[1], s[2], s[3])
            ns = _z5_mul(st, _z5_conj(st))
            if any(ns[r] != 0 for r in range(1, 4)):
                co += 1
            elif ns[0] == id_val:
                ci += 1
            elif ns[0] == 0:
                cz += 1
            elif ns[0] == dim:
                cf += 1
            else:
                co += 1
    return (ci, cz, cf, co)


def two_stab_qgt_metric(dim: int, theta: float) -> float:
    """Exact closed-form Fubini-Study metric g_{theta,theta}(theta) along |Psi_n(theta)>."""
    norm_sq = 2.0 + 2.0 * math.cos(theta) / math.sqrt(float(dim))
    return (1.0 - 1.0 / float(dim)) / (norm_sq * norm_sq)


# ---- Deterministic QRNG Mixer Twin (MIT tsotchke/quantum_rng) --------------

_MASK64 = (1 << 64) - 1
_QRNG_FINE_STRUCTURE = 0x7297352743776A1B
_QRNG_PLANCK = 0x6955927086495225
_QRNG_GOLDEN_RATIO = 0x9E3779B97F4A7C15
_QRNG_SQRT2 = 0x6A09E667F3BCC908
_QRNG_HEISENBERG = 0xC13FA9A902A6328F
_QRNG_SCHRODINGER = 0x91E10DA5C79E7B1D
_QRNG_PAULI_X = 0x4C957F2D8A1E6B3C
_QRNG_PAULI_Y = 0xD3E99E3B6C1A4F78
_QRNG_PAULI_Z = 0x8F142FC07892A5B6


def _splitmix64(x: int) -> int:
    x &= _MASK64
    x ^= x >> 30
    x = (x * 0xBF58476D1CE4E5B9) & _MASK64
    x ^= x >> 27
    x = (x * 0x94D049BB133111EB) & _MASK64
    x ^= x >> 31
    x = (x * _QRNG_HEISENBERG) & _MASK64
    x ^= x >> 29
    return x


def _hadamard_mix(x: int) -> int:
    x = _splitmix64(x)
    x ^= (_QRNG_PAULI_X * (x >> 12)) & _MASK64
    x = (x * _QRNG_FINE_STRUCTURE) & _MASK64
    x ^= (_QRNG_PAULI_Y * (x >> 25)) & _MASK64
    x = (x * _QRNG_PLANCK) & _MASK64
    x ^= (_QRNG_PAULI_Z * (x >> 27)) & _MASK64
    x = (x * _QRNG_SCHRODINGER) & _MASK64
    x ^= x >> 13
    return x


def qrng_absorb_u64(seed: int) -> int:
    """Bit-exact Python port of wm_qrng_absorb_u64 (classical deterministic mixer)."""
    data = [(seed >> (8 * i)) & 0xFF for i in range(8)]
    h = _QRNG_SQRT2 ^ _splitmix64((8 + _QRNG_GOLDEN_RATIO) & _MASK64)
    for b in data:
        h ^= (b + _QRNG_GOLDEN_RATIO + ((h << 6) & _MASK64) + (h >> 2)) & _MASK64
        h = _hadamard_mix(h)
    return h ^ _splitmix64(8)


def qrng_stream_next(absorbed_state: int, index: int) -> int:
    """Bit-exact Python port of wm_qrng_stream_next."""
    return _hadamard_mix((absorbed_state + (index + 1) * _QRNG_GOLDEN_RATIO) & _MASK64)
