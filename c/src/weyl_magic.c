/* SPDX-License-Identifier: Apache-2.0 */
/* Copyright (c) 2026 Alexander Stephen Donahue */

#include "weyl_magic.h"
#include <string.h>

void fwht16_i64_c(int64_t *buf) {
    for (int half = 1; half < 16; half <<= 1) {
        int step = half << 1;
        for (int base = 0; base < 16; base += step) {
            for (int k = 0; k < half; k++) {
                int64_t x = buf[base + k];
                int64_t y = buf[base + k + half];
                buf[base + k] = x + y;
                buf[base + k + half] = x - y;
            }
        }
    }
}

void fwht32_i64_c(int64_t *buf) {
    for (int half = 1; half < 32; half <<= 1) {
        int step = half << 1;
        for (int base = 0; base < 32; base += step) {
            for (int k = 0; k < half; k++) {
                int64_t x = buf[base + k];
                int64_t y = buf[base + k + half];
                buf[base + k] = x + y;
                buf[base + k + half] = x - y;
            }
        }
    }
}

static inline wm_gauss_t g_add(wm_gauss_t a, wm_gauss_t b) {
    wm_gauss_t r = {a.re + b.re, a.im + b.im};
    return r;
}

static inline wm_gauss_t g_conj(wm_gauss_t a) {
    wm_gauss_t r = {a.re, -a.im};
    return r;
}

static inline wm_gauss_t g_mul(wm_gauss_t a, wm_gauss_t b) {
    wm_gauss_t r = {a.re * b.re - a.im * b.im, a.re * b.im + a.im * b.re};
    return r;
}

static inline wm_gauss_t g_mul_i(wm_gauss_t x, int q) {
    int m = q & 3;
    if (m == 0) return x;
    if (m == 1) { wm_gauss_t r = {-x.im, x.re}; return r; }
    if (m == 2) { wm_gauss_t r = {-x.re, -x.im}; return r; }
    { wm_gauss_t r = {x.im, -x.re}; return r; }
}

static inline wm_zeta8_t z8_add(wm_zeta8_t a, wm_zeta8_t b) {
    wm_zeta8_t r = {a.c0 + b.c0, a.c1 + b.c1, a.c2 + b.c2, a.c3 + b.c3};
    return r;
}

static inline wm_zeta8_t z8_conj(wm_zeta8_t x) {
    wm_zeta8_t r = {x.c0, -x.c3, -x.c2, -x.c1};
    return r;
}

static inline wm_zeta8_t z8_mul(wm_zeta8_t a, wm_zeta8_t b) {
    wm_zeta8_t r = {
        a.c0 * b.c0 - a.c1 * b.c3 - a.c2 * b.c2 - a.c3 * b.c1,
        a.c0 * b.c1 + a.c1 * b.c0 - a.c2 * b.c3 - a.c3 * b.c2,
        a.c0 * b.c2 + a.c1 * b.c1 + a.c2 * b.c0 - a.c3 * b.c3,
        a.c0 * b.c3 + a.c1 * b.c2 + a.c2 * b.c1 + a.c3 * b.c0
    };
    return r;
}

static inline wm_zeta8_t z8_mul_i(wm_zeta8_t x, int q) {
    int m = q & 3;
    if (m == 0) return x;
    if (m == 1) { wm_zeta8_t r = {-x.c2, -x.c3, x.c0, x.c1}; return r; }
    if (m == 2) { wm_zeta8_t r = {-x.c0, -x.c1, -x.c2, -x.c3}; return r; }
    { wm_zeta8_t r = {x.c2, x.c3, -x.c0, -x.c1}; return r; }
}

/* Exhaustive scan of all 65,536 Boolean functions on F_2^4. */
wm_bent4_audit_t wm_audit_all_65536_f2_4(int use_asm) {
    wm_bent4_audit_t res = {0, 0, 0, 0};
    int64_t buf[16];
    uint8_t anf[16];

    for (uint32_t tt = 0; tt < 65536U; tt++) {
        for (int x = 0; x < 16; x++) {
            buf[x] = ((tt >> x) & 1U) ? -1 : 1;
        }
#ifdef WEYL_MAGIC_HAS_ASM
        if (use_asm) {
            fwht16_i64_asm(buf);
        } else {
            fwht16_i64_c(buf);
        }
#else
        (void)use_asm;
        fwht16_i64_c(buf);
#endif
        int is_bent = 1;
        for (int u = 0; u < 16; u++) {
            if (buf[u] != 4 && buf[u] != -4) {
                is_bent = 0;
                break;
            }
        }
        if (!is_bent) continue;
        res.total_bent++;

        /* Fast Mobius transform for ANF degree */
        for (int x = 0; x < 16; x++) {
            anf[x] = (uint8_t)((tt >> x) & 1U);
        }
        for (int bit = 0; bit < 4; bit++) {
            int step = 1 << bit;
            for (int x = 0; x < 16; x++) {
                if (x & step) anf[x] ^= anf[x ^ step];
            }
        }
        int max_deg = 0;
        for (int m = 0; m < 16; m++) {
            if (anf[m]) {
                int w = (m & 1) + ((m >> 1) & 1) + ((m >> 2) & 1) + ((m >> 3) & 1);
                if (w > max_deg) max_deg = w;
            }
        }
        if (max_deg <= 2) res.quad_bent++;
        else res.deg_gt2_bent++;

        /* Check 3-hyperplane zero-sum triple existence */
        uint16_t ea[16];
        for (int a = 1; a < 16; a++) {
            uint16_t mask = 0;
            for (int x = 0; x < 16; x++) {
                uint32_t fx = (tt >> x) & 1U;
                uint32_t fxa = (tt >> (x ^ a)) & 1U;
                if (fx == fxa) mask = (uint16_t)(mask | (uint16_t)(1U << x));
            }
            ea[a] = mask;
        }
        int found = 0;
        for (int a = 1; a < 16 && !found; a++) {
            for (int b = a + 1; b < 16; b++) {
                int c = a ^ b;
                if ((ea[a] ^ ea[b] ^ ea[c]) == 0) {
                    found = 1;
                    break;
                }
            }
        }
        if (found) res.bent_with_zero_triple++;
    }
    return res;
}

wm_z8_spectrum_t wm_verify_w42_z8_mub(void) {
    static const wm_zeta8_t psi[8] = {
        {0, -1, 0, 0}, {-1, 0, -1, 0}, {1, 0, 0, 0}, {0, 0, 0, 0},
        {0, 0, 0, -1}, {0, 0, 0, 0}, {0, 0, 1, 0}, {0, 1, 0, -1}
    };
    wm_z8_spectrum_t out = {0, 0, 0, 0, 0, 0};
    for (int x = 0; x < 8; x++) {
        wm_zeta8_t p = z8_mul(psi[x], z8_conj(psi[x]));
        out.norm2_r0 += p.c0;
        out.norm2_r1 += p.c1;
    }
    for (int a = 0; a < 8; a++) {
        int a0 = a / 2, a1 = a % 2;
        for (int b = 0; b < 8; b++) {
            int b0 = b / 2, b1 = b % 2;
            wm_zeta8_t s = {0, 0, 0, 0};
            for (int x = 0; x < 8; x++) {
                int x0 = x / 2, x1 = x % 2;
                int xa = 2 * ((x0 + a0) % 4) + ((x1 + a1) % 2);
                wm_zeta8_t prod = z8_mul(z8_conj(psi[x]), psi[xa]);
                s = z8_add(s, z8_mul_i(prod, b0 * x0 + 2 * b1 * x1));
            }
            wm_zeta8_t ns = z8_mul(s, z8_conj(s));
            if (ns.c1 != 0 || ns.c2 != 0 || ns.c3 != 0) out.n_other++;
            else if (ns.c0 == 64) out.n_id++;
            else if (ns.c0 == 0) out.n_zero++;
            else if (ns.c0 == 8) out.n_flat++;
            else out.n_other++;
        }
    }
    return out;
}

wm_z8_spectrum_t wm_verify_w44_z8_mub(void) {
    static const wm_zeta8_t psi[16] = {
        {3, 0, 1, 0}, {-1, 0, 3, 0}, {-3, 0, -1, 0}, {-1, 0, 3, 0},
        {0, 3, 0, 1}, {0, 1, 0, 7}, {0, 3, 0, 1}, {0, 3, 0, 1},
        {-3, 0, -1, 0}, {-1, 0, 3, 0}, {-1, 0, -7, 0}, {-5, 0, -5, 0},
        {0, -3, 0, -1}, {0, -3, 0, -1}, {0, 5, 0, -5}, {0, 3, 0, 1}
    };
    wm_z8_spectrum_t out = {0, 0, 0, 0, 0, 0};
    for (int x = 0; x < 16; x++) {
        wm_zeta8_t p = z8_mul(psi[x], z8_conj(psi[x]));
        out.norm2_r0 += p.c0;
        out.norm2_r1 += p.c1;
    }
    for (int a = 0; a < 16; a++) {
        int a0 = a / 4, a1 = a % 4;
        for (int b = 0; b < 16; b++) {
            int b0 = b / 4, b1 = b % 4;
            wm_zeta8_t s = {0, 0, 0, 0};
            for (int x = 0; x < 16; x++) {
                int x0 = x / 4, x1 = x % 4;
                int xa = 4 * ((x0 + a0) % 4) + ((x1 + a1) % 4);
                wm_zeta8_t prod = z8_mul(z8_conj(psi[x]), psi[xa]);
                s = z8_add(s, z8_mul_i(prod, b0 * x0 + b1 * x1));
            }
            wm_zeta8_t ns = z8_mul(s, z8_conj(s));
            if (ns.c1 != 0 || ns.c2 != 0 || ns.c3 != 0) out.n_other++;
            else if (ns.c0 == 102400) out.n_id++;
            else if (ns.c0 == 0) out.n_zero++;
            else if (ns.c0 == 6400) out.n_flat++;
            else out.n_other++;
        }
    }
    return out;
}

wm_moments_t wm_verify_w42_super_mub(void) {
    static const wm_gauss_t v[8] = {
        {-2, 5}, {-2, 5}, {-9, 9}, {-9, -10},
        {-11, -4}, {-11, -4}, {-1, -18}, {0, 1}
    };
    wm_moments_t out = {0, 0, 0, 0};
    for (int x = 0; x < 8; x++) out.norm2 += v[x].re * v[x].re + v[x].im * v[x].im;
    for (int a = 0; a < 8; a++) {
        int a0 = a / 2, a1 = a % 2;
        for (int b = 0; b < 8; b++) {
            int b0 = b / 2, b1 = b % 2;
            wm_gauss_t s = {0, 0};
            for (int x = 0; x < 8; x++) {
                int x0 = x / 2, x1 = x % 2;
                int xa = 2 * ((x0 + a0) % 4) + ((x1 + a1) % 2);
                wm_gauss_t prod = g_mul(g_conj(v[x]), v[xa]);
                s = g_add(s, g_mul_i(prod, b0 * x0 + 2 * b1 * x1));
            }
            wm_i128 m = (wm_i128)s.re * (wm_i128)s.re + (wm_i128)s.im * (wm_i128)s.im;
            wm_i128 m2 = m * m;
            out.num4 += m2;
            out.num6 += m2 * m;
            out.num8 += m2 * m2;
        }
    }
    return out;
}

wm_moments_t wm_verify_w44_super_mub(void) {
    static const wm_gauss_t v[16] = {
        {9, -10}, {-7, -1}, {4, 4}, {2, 15},
        {1, 1}, {-7, 0}, {2, -1}, {5, 2},
        {14, -7}, {-6, 14}, {3, 6}, {-5, -1},
        {-2, 1}, {0, -16}, {3, 4}, {-4, 13}
    };
    wm_moments_t out = {0, 0, 0, 0};
    for (int x = 0; x < 16; x++) out.norm2 += v[x].re * v[x].re + v[x].im * v[x].im;
    for (int a = 0; a < 16; a++) {
        int a0 = a / 4, a1 = a % 4;
        for (int b = 0; b < 16; b++) {
            int b0 = b / 4, b1 = b % 4;
            wm_gauss_t s = {0, 0};
            for (int x = 0; x < 16; x++) {
                int x0 = x / 4, x1 = x % 4;
                int xa = 4 * ((x0 + a0) % 4) + ((x1 + a1) % 4);
                wm_gauss_t prod = g_mul(g_conj(v[x]), v[xa]);
                s = g_add(s, g_mul_i(prod, b0 * x0 + b1 * x1));
            }
            wm_i128 m = (wm_i128)s.re * (wm_i128)s.re + (wm_i128)s.im * (wm_i128)s.im;
            wm_i128 m2 = m * m;
            out.num4 += m2;
            out.num6 += m2 * m;
            out.num8 += m2 * m2;
        }
    }
    return out;
}

wm_moments_t wm_verify_n5_rupture(int use_asm) {
    static const wm_gauss_t v[32] = {
        {1,-2}, {-1,0}, {-2,-3}, {-2,-3}, {0,-1}, {-5,3}, {-2,2}, {1,1},
        {0,1}, {1,-2}, {1,-1}, {1,0}, {0,-1}, {-2,-3}, {-1,0}, {0,3},
        {0,-1}, {-1,2}, {-3,2}, {-5,-2}, {-1,-1}, {1,0}, {-3,1}, {2,2},
        {0,3}, {1,0}, {-3,3}, {1,1}, {-3,2}, {3,-2}, {-3,0}, {1,3}
    };
    wm_moments_t out = {0, 0, 0, 0};
    for (int x = 0; x < 32; x++) out.norm2 += v[x].re * v[x].re + v[x].im * v[x].im;
    int64_t re_buf[32], im_buf[32];
    for (int a = 0; a < 32; a++) {
        for (int x = 0; x < 32; x++) {
            wm_gauss_t prod = g_mul(g_conj(v[x]), v[x ^ a]);
            re_buf[x] = prod.re;
            im_buf[x] = prod.im;
        }
#ifdef WEYL_MAGIC_HAS_ASM
        if (use_asm) {
            fwht32_i64_asm(re_buf);
            fwht32_i64_asm(im_buf);
        } else {
            fwht32_i64_c(re_buf);
            fwht32_i64_c(im_buf);
        }
#else
        (void)use_asm;
        fwht32_i64_c(re_buf);
        fwht32_i64_c(im_buf);
#endif
        for (int b = 0; b < 32; b++) {
            wm_i128 m = (wm_i128)re_buf[b] * (wm_i128)re_buf[b] +
                        (wm_i128)im_buf[b] * (wm_i128)im_buf[b];
            wm_i128 m2 = m * m;
            out.num4 += m2;
            out.num6 += m2 * m;
            out.num8 += m2 * m2;
        }
    }
    return out;
}

/* Exact Z[zeta_9] arithmetic for Pillar 5 (n = 1, 2, 3, 4; D up to 81). */
typedef struct { int64_t c[6]; } wm_z9_t;

static wm_z9_t z9_pow(int k) {
    wm_z9_t r = {{0, 0, 0, 0, 0, 0}};
    int m = ((k % 9) + 9) % 9;
    if (m < 6) {
        r.c[m] = 1;
    } else {
        r.c[m - 6] = -1;
        r.c[m - 3] = -1;
    }
    return r;
}

static wm_z9_t z9_conj(wm_z9_t x) {
    wm_z9_t r = {{x.c[0] - x.c[3], -x.c[2], -x.c[1], -x.c[3], x.c[5] - x.c[2], x.c[4] - x.c[1]}};
    return r;
}

static wm_z9_t z9_mul(wm_z9_t a, wm_z9_t b) {
    int64_t t[11] = {0};
    for (int i = 0; i < 6; i++) {
        for (int j = 0; j < 6; j++) t[i + j] += a.c[i] * b.c[j];
    }
    for (int k = 10; k >= 6; k--) {
        int64_t v = t[k];
        t[k - 3] -= v;
        t[k - 6] -= v;
    }
    wm_z9_t r = {{t[0], t[1], t[2], t[3], t[4], t[5]}};
    return r;
}

static void f3_mul(int n, const int *poly, const int *u, const int *v, int *out) {
    int tmp[8] = {0};
    for (int i = 0; i < n; i++) {
        for (int j = 0; j < n; j++) tmp[i + j] = (tmp[i + j] + u[i] * v[j]) % 3;
    }
    for (int k = 2 * n - 2; k >= n; k--) {
        int c = tmp[k];
        tmp[k] = 0;
        if (c) {
            for (int i = 0; i < n; i++) {
                tmp[k - n + i] = (tmp[k - n + i] + c * poly[i]) % 3;
            }
        }
    }
    for (int i = 0; i < n; i++) out[i] = tmp[i] % 3;
}

static int f3_trace(int n, const int *poly, const int *u) {
    int tr = 0;
    for (int i = 0; i < n; i++) {
        int ei[4] = {0}, p[4] = {0};
        ei[i] = 1;
        f3_mul(n, poly, u, ei, p);
        tr = (tr + p[i]) % 3;
    }
    return tr;
}

int wm_verify_char3_alltop(int n, int *out_id, int *out_zero, int *out_flat, int *out_other) {
    /* Irreducible monic polynomials t^n = sum c_i t^i over F_3:
     * n=1: t = 1 (t + 2 = 0); n=2: t^2 = 2 (t^2 + 1 = 0);
     * n=3: t^3 = 2 + t (t^3 + 2t + 1 = 0); n=4: t^4 = 1 + 2t (t^4 + t + 2 = 0). */
    static const int poly1[4] = {1, 0, 0, 0};
    static const int poly2[4] = {2, 0, 0, 0};
    static const int poly3[4] = {2, 1, 0, 0};
    static const int poly4[4] = {1, 2, 0, 0};
    const int *poly = NULL;
    int D = 1;
    if (n == 1) { poly = poly1; D = 3; }
    else if (n == 2) { poly = poly2; D = 9; }
    else if (n == 3) { poly = poly3; D = 27; }
    else if (n == 4) { poly = poly4; D = 81; }
    else return -1;

    int T[4][4][4];
    memset(T, 0, sizeof(T));
    for (int i = 0; i < n; i++) {
        int ei[4] = {0}; ei[i] = 1;
        for (int j = 0; j < n; j++) {
            int ej[4] = {0}, eij[4] = {0}; ej[j] = 1;
            f3_mul(n, poly, ei, ej, eij);
            for (int k = 0; k < n; k++) {
                int ek[4] = {0}, eijk[4] = {0}; ek[k] = 1;
                f3_mul(n, poly, eij, ek, eijk);
                T[i][j][k] = f3_trace(n, poly, eijk);
            }
        }
    }

    int g[81];
    int vecs[81][4];
    for (int x = 0; x < D; x++) {
        int tmp = x;
        for (int i = 0; i < n; i++) { vecs[x][i] = tmp % 3; tmp /= 3; }
        int val = 0;
        for (int i = 0; i < n; i++) val += T[i][i][i] * vecs[x][i];
        for (int i = 0; i < n; i++) {
            for (int j = 0; j < n; j++) {
                if (i != j) val += 3 * T[i][i][j] * vecs[x][i] * vecs[x][i] * vecs[x][j];
            }
        }
        for (int i = 0; i < n; i++) {
            for (int j = i + 1; j < n; j++) {
                for (int k = j + 1; k < n; k++) {
                    val += 6 * T[i][j][k] * vecs[x][i] * vecs[x][j] * vecs[x][k];
                }
            }
        }
        g[x] = ((val % 9) + 9) % 9;
    }

    int cI = 0, cZ = 0, cF = 0, cO = 0;
    int64_t id_val = (int64_t)D * (int64_t)D;
    for (int a = 0; a < D; a++) {
        for (int b = 0; b < D; b++) {
            wm_z9_t s = {{0, 0, 0, 0, 0, 0}};
            for (int x = 0; x < D; x++) {
                int xa = 0, mult = 1, bx = 0;
                for (int i = 0; i < n; i++) {
                    xa += ((vecs[x][i] + vecs[a][i]) % 3) * mult;
                    mult *= 3;
                    bx += vecs[b][i] * vecs[x][i];
                }
                int e = (g[xa] + 9 - g[x] + 3 * bx) % 9;
                wm_z9_t p = z9_pow(e);
                for (int r = 0; r < 6; r++) s.c[r] += p.c[r];
            }
            wm_z9_t ns = z9_mul(s, z9_conj(s));
            int pure_int = (ns.c[1] == 0 && ns.c[2] == 0 && ns.c[3] == 0 &&
                            ns.c[4] == 0 && ns.c[5] == 0);
            if (!pure_int) cO++;
            else if (ns.c[0] == id_val) cI++;
            else if (ns.c[0] == 0) cZ++;
            else if (ns.c[0] == D) cF++;
            else cO++;
        }
    }
    if (out_id) *out_id = cI;
    if (out_zero) *out_zero = cZ;
    if (out_flat) *out_flat = cF;
    if (out_other) *out_other = cO;
    return (cI == 1 && cZ == D - 1 && cF == D * (D - 1) && cO == 0) ? 0 : 1;
}
