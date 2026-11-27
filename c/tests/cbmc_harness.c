/* SPDX-License-Identifier: Apache-2.0
 * Copyright (c) 2026 Alexander Stephen Donahue
 *
 * CBMC bounded model checking harness for the exact C11 FWHT-16 kernel.
 * Run with:
 *   cbmc --bounds-check --pointer-check --signed-overflow-check -Ic/include \
 *        c/src/weyl_magic.c c/tests/cbmc_harness.c
 * Also compiles cleanly as standalone ISO C11 sanity harness when __CPROVER__ is absent.
 */

#include <assert.h>
#include <stdint.h>
#include <stdio.h>
#include "weyl_magic.h"

#ifdef __CPROVER__
extern int64_t nondet_int64(void);
#endif

int main(void) {
    int64_t orig[16];
    int64_t buf[16];
    int64_t energy_orig = 0;
    int64_t energy_hat = 0;

    for (int i = 0; i < 16; ++i) {
#ifdef __CPROVER__
        int64_t v = nondet_int64();
        __CPROVER_assume(v >= -1000 && v <= 1000);
#else
        int64_t v = (int64_t)((i * 7 - 53) % 19);
#endif
        orig[i] = v;
        buf[i] = v;
        energy_orig += v * v;
    }

    fwht16_i64_c(buf);

    for (int i = 0; i < 16; ++i) {
        energy_hat += buf[i] * buf[i];
    }
    /* Parseval identity: sum (H x)^2 == 16 * sum x^2 */
    assert(energy_hat == 16 * energy_orig);

    /* Involution identity: H(H x) == 16 * x */
    fwht16_i64_c(buf);
    for (int i = 0; i < 16; ++i) {
        assert(buf[i] == 16 * orig[i]);
    }

#ifndef __CPROVER__
    printf("[cbmc_harness] PASS: FWHT-16 Parseval & involution bounded check clean\n");
#endif
    return 0;
}
