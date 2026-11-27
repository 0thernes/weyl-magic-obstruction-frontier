/* SPDX-License-Identifier: Apache-2.0 */
/* Copyright (c) 2026 Alexander Stephen Donahue */

#include "weyl_magic.h"
#include <inttypes.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>

static void print_i128(wm_i128 v) {
    if (v == 0) { printf("0"); return; }
    if (v < 0) { printf("-"); v = -v; }
    char buf[48];
    int pos = 0;
    while (v > 0) {
        buf[pos++] = (char)('0' + (int)(v % 10));
        v /= 10;
    }
    while (pos > 0) putchar(buf[--pos]);
}

static wm_i128 ipow128(int64_t base, int exp) {
    wm_i128 r = 1;
    for (int i = 0; i < exp; i++) r *= (wm_i128)base;
    return r;
}

#ifdef WEYL_MAGIC_HAS_ASM
static double now_sec(void) {
    struct timespec ts;
    timespec_get(&ts, TIME_UTC);
    return (double)ts.tv_sec + (double)ts.tv_nsec * 1e-9;
}
#endif

int main(void) {
    int fails = 0;

    /* 1. Pillar 2: Exhaustive scan of all 65,536 F_2^4 Boolean functions (C11 & ASM) */
    wm_bent4_audit_t a_c = wm_audit_all_65536_f2_4(0);
    if (a_c.total_bent != 896 || a_c.quad_bent != 896 ||
        a_c.deg_gt2_bent != 0 || a_c.bent_with_zero_triple != 896) {
        fprintf(stderr, "[c11] FAIL bent4_c: total=%u quad=%u gt2=%u triple=%u\n",
                a_c.total_bent, a_c.quad_bent, a_c.deg_gt2_bent, a_c.bent_with_zero_triple);
        fails++;
    } else {
        printf("[c11] PASS bent4_c: 65536 scanned -> 896 bent (all deg<=2, all 896 have zero-sum triple)\n");
    }

#ifdef WEYL_MAGIC_HAS_ASM
    wm_bent4_audit_t a_asm = wm_audit_all_65536_f2_4(1);
    if (memcmp(&a_c, &a_asm, sizeof(a_c)) != 0) {
        fprintf(stderr, "[c11+asm] FAIL bent4 ASM vs C mismatch\n");
        fails++;
    } else {
        printf("[c11+asm] PASS bent4_asm: bit-exact match with scalar C11\n");
    }

    /* Honest microbenchmark: 100,000 calls to fwht16_i64_c vs fwht16_i64_asm */
    int64_t b1[16], b2[16];
    for (int i = 0; i < 16; i++) b1[i] = b2[i] = (int64_t)((i * 7 - 5) & 15) - 7;
    fwht16_i64_c(b1);
    fwht16_i64_asm(b2);
    if (memcmp(b1, b2, sizeof(b1)) != 0) {
        fprintf(stderr, "[c11+asm] FAIL fwht16 single-vector mismatch\n");
        fails++;
    }
    double t0 = now_sec();
    volatile int64_t sink_c = 0;
    for (int it = 0; it < 200000; it++) {
        b1[0] = (int64_t)(it & 7);
        fwht16_i64_c(b1);
        sink_c += b1[0];
    }
    double dt_c = now_sec() - t0;
    double t1 = now_sec();
    volatile int64_t sink_a = 0;
    for (int it = 0; it < 200000; it++) {
        b2[0] = (int64_t)(it & 7);
        fwht16_i64_asm(b2);
        sink_a += b2[0];
    }
    double dt_a = now_sec() - t1;
    (void)sink_c; (void)sink_a;
    printf("[bench] fwht16 x200k: c11=%.4fs asm=%.4fs ratio=%.2fx\n",
           dt_c, dt_a, dt_a > 0.0 ? dt_c / dt_a : 0.0);
#endif

    /* 2. Pillar 3: Exact Z[zeta_8] WH-MUBs */
    wm_z8_spectrum_t s42 = wm_verify_w42_z8_mub();
    if (s42.norm2_r0 != 8 || s42.norm2_r1 != 0 ||
        s42.n_id != 1 || s42.n_zero != 7 || s42.n_flat != 56 || s42.n_other != 0) {
        fprintf(stderr, "[c11] FAIL w42_z8_mub\n");
        fails++;
    } else {
        printf("[c11] PASS w42_z8_mub: norm2=8, counts=(1,7,56,0)\n");
    }

    wm_z8_spectrum_t s44 = wm_verify_w44_z8_mub();
    if (s44.norm2_r0 != 320 || s44.norm2_r1 != 0 ||
        s44.n_id != 1 || s44.n_zero != 15 || s44.n_flat != 240 || s44.n_other != 0) {
        fprintf(stderr, "[c11] FAIL w44_z8_mub\n");
        fails++;
    } else {
        printf("[c11] PASS w44_z8_mub: norm2=320, counts=(1,15,240,0)\n");
    }

    /* 3. Pillar 3: Exact Z[i] Super-MUB witnesses + alpha=2,3->4 reversal */
    wm_moments_t m42 = wm_verify_w42_super_mub();
    if (m42.norm2 != 1001 ||
        !(8 * m42.num4 < 15 * ipow128(1001, 4)) ||
        !(64 * m42.num6 < 71 * ipow128(1001, 6)) ||
        !(512 * m42.num8 > 519 * ipow128(1001, 8))) {
        fprintf(stderr, "[c11] FAIL w42_super_mub\n");
        fails++;
    } else {
        printf("[c11] PASS w42_super_mub: norm2=%" PRId64 " num4=", m42.norm2);
        print_i128(m42.num4);
        printf(" (beats a=2,3; reverses a=4)\n");
    }

    wm_moments_t m44 = wm_verify_w44_super_mub();
    if (m44.norm2 != 1596 ||
        !(16 * m44.num4 < 31 * ipow128(1596, 4)) ||
        !(256 * m44.num6 < 271 * ipow128(1596, 6)) ||
        !(4096 * m44.num8 > 4111 * ipow128(1596, 8))) {
        fprintf(stderr, "[c11] FAIL w44_super_mub\n");
        fails++;
    } else {
        printf("[c11] PASS w44_super_mub: norm2=%" PRId64 " num4=", m44.norm2);
        print_i128(m44.num4);
        printf(" (beats a=2,3; reverses a=4)\n");
    }

    /* 4. Pillar 4: 5-qubit rupture witness (C & ASM) */
    wm_moments_t m5_c = wm_verify_n5_rupture(0);
    if (m5_c.norm2 != 254 || m5_c.num4 != (wm_i128)11097089024LL ||
        !(m5_c.num4 < 3 * ipow128(254, 4))) {
        fprintf(stderr, "[c11] FAIL n5_rupture_c\n");
        fails++;
    } else {
        printf("[c11] PASS n5_rupture_c: norm2=254 num4=11097089024 < 3*254^4\n");
    }
#ifdef WEYL_MAGIC_HAS_ASM
    wm_moments_t m5_a = wm_verify_n5_rupture(1);
    if (m5_c.norm2 != m5_a.norm2 || m5_c.num4 != m5_a.num4 ||
        m5_c.num6 != m5_a.num6 || m5_c.num8 != m5_a.num8) {
        fprintf(stderr, "[c11+asm] FAIL n5_rupture ASM vs C mismatch\n");
        fails++;
    } else {
        printf("[c11+asm] PASS n5_rupture_asm: bit-exact match with scalar C11\n");
    }
#endif

    /* 5. Pillar 5: Exact Z[zeta_9] char-3 Alltop for n = 1, 2, 3, 4 (D = 3, 9, 27, 81) */
    for (int n = 1; n <= 4; n++) {
        int cI = 0, cZ = 0, cF = 0, cO = 0;
        int rc = wm_verify_char3_alltop(n, &cI, &cZ, &cF, &cO);
        if (rc != 0) {
            fprintf(stderr, "[c11] FAIL char3_alltop n=%d counts=(%d,%d,%d,%d)\n",
                    n, cI, cZ, cF, cO);
            fails++;
        } else {
            printf("[c11] PASS char3_alltop n=%d: counts=(%d,%d,%d,%d)\n",
                   n, cI, cZ, cF, cO);
        }
    }

    /* 6. Deterministic QRNG stream bit-exact known-answer assertion */
    uint64_t st = wm_qrng_absorb_u64(1ULL);
    uint64_t w0 = wm_qrng_stream_next(st, 0ULL);
    uint64_t w1 = wm_qrng_stream_next(st, 1ULL);
    if (st != 0x532662e3dcf55ef7ULL || w0 != 0x5df9ef9ba7cdcca2ULL || w1 != 0xddb5674ec90579d9ULL) {
        fprintf(stderr, "[qrng] FAIL deterministic seed=1 mismatch: state=%016" PRIx64 " w0=%016" PRIx64 " w1=%016" PRIx64 "\n",
                st, w0, w1);
        fails++;
    } else {
        printf("[qrng] PASS deterministic seed=1: state=%016" PRIx64 " w0=%016" PRIx64 " w1=%016" PRIx64 "\n",
               st, w0, w1);
    }

    return fails == 0 ? 0 : 1;
}
