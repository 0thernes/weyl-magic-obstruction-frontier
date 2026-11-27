/* SPDX-License-Identifier: Apache-2.0 */
/* Copyright (c) 2026 Alexander Stephen Donahue */
/*
 * Deterministic 100,000-iteration fuzz & differential property harness for
 * exact FWHT-16, FWHT-32 (C11 vs ASM), and Parseval energy invariants.
 */

#include "weyl_magic.h"
#include <inttypes.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

static int64_t signed_small(uint64_t r) {
    return (int64_t)(r % 2001ULL) - 1000;
}

#ifdef LIBFUZZER
#include <stddef.h>
int LLVMFuzzerTestOneInput(const uint8_t *data, size_t size) {
    if (size < 16) return 0;
    int64_t a16[16], orig[16];
    wm_i128 e_in = 0, e_out = 0;
    for (int i = 0; i < 16; i++) {
        int64_t v = (int64_t)((int8_t)data[i]);
        orig[i] = a16[i] = v;
        e_in += (wm_i128)v * (wm_i128)v;
    }
    fwht16_i64_c(a16);
    for (int i = 0; i < 16; i++) e_out += (wm_i128)a16[i] * (wm_i128)a16[i];
    if (e_out != 16 * e_in) abort();
    fwht16_i64_c(a16);
    for (int i = 0; i < 16; i++) {
        if (a16[i] != 16 * orig[i]) abort();
    }
    return 0;
}
#else
int main(void) {
    uint64_t st = wm_qrng_absorb_u64(0x20260420ULL);
    uint64_t idx = 0;

    for (int iter = 0; iter < 100000; iter++) {
        int64_t a16[16], b16[16];
        wm_i128 e_in = 0, e_out = 0;
        for (int i = 0; i < 16; i++) {
            int64_t v = signed_small(wm_qrng_stream_next(st, idx++));
            a16[i] = b16[i] = v;
            e_in += (wm_i128)v * (wm_i128)v;
        }
        fwht16_i64_c(a16);
#ifdef WEYL_MAGIC_HAS_ASM
        fwht16_i64_asm(b16);
        if (memcmp(a16, b16, sizeof(a16)) != 0) {
            fprintf(stderr, "[fuzz] FAIL fwht16 ASM/C divergence at iter=%d\n", iter);
            return 1;
        }
#endif
        for (int i = 0; i < 16; i++) e_out += (wm_i128)a16[i] * (wm_i128)a16[i];
        if (e_out != 16 * e_in) {
            fprintf(stderr, "[fuzz] FAIL fwht16 Parseval at iter=%d\n", iter);
            return 1;
        }
        /* Involution check: FWHT(FWHT(x)) == 16 * x */
        fwht16_i64_c(a16);
        for (int i = 0; i < 16; i++) {
            int64_t orig = signed_small(wm_qrng_stream_next(st, idx - 16 + (uint64_t)i));
            if (a16[i] != 16 * orig) {
                fprintf(stderr, "[fuzz] FAIL fwht16 involution at iter=%d\n", iter);
                return 1;
            }
        }

        if ((iter & 3) == 0) {
            int64_t a32[32], b32[32];
            wm_i128 e32_in = 0, e32_out = 0;
            for (int i = 0; i < 32; i++) {
                int64_t v = signed_small(wm_qrng_stream_next(st, idx++));
                a32[i] = b32[i] = v;
                e32_in += (wm_i128)v * (wm_i128)v;
            }
            fwht32_i64_c(a32);
#ifdef WEYL_MAGIC_HAS_ASM
            fwht32_i64_asm(b32);
            if (memcmp(a32, b32, sizeof(a32)) != 0) {
                fprintf(stderr, "[fuzz] FAIL fwht32 ASM/C divergence at iter=%d\n", iter);
                return 1;
            }
#endif
            for (int i = 0; i < 32; i++) e32_out += (wm_i128)a32[i] * (wm_i128)a32[i];
            if (e32_out != 32 * e32_in) {
                fprintf(stderr, "[fuzz] FAIL fwht32 Parseval at iter=%d\n", iter);
                return 1;
            }
        }
    }

    printf("[fuzz] PASS: 100,000 fwht16 + 25,000 fwht32 differential/Parseval/involution checks\n");
    return 0;
}
#endif
