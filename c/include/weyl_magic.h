/* SPDX-License-Identifier: Apache-2.0 */
/* Copyright (c) 2026 Alexander Stephen Donahue */

#ifndef WEYL_MAGIC_H
#define WEYL_MAGIC_H

#include <stddef.h>
#include <stdint.h>

#ifdef __cplusplus
extern "C" {
#endif

/* Exact 64-bit integer FWHT kernels (scalar C11 and x86-64 NASM assembly). */
void fwht16_i64_c(int64_t *buf);
void fwht32_i64_c(int64_t *buf);

#ifdef WEYL_MAGIC_HAS_ASM
void fwht16_i64_asm(int64_t *buf);
void fwht32_i64_asm(int64_t *buf);
#endif

/* Exact Gaussian integer (re + im * i) and 8th-cyclotomic Z[zeta_8]. */
typedef struct {
    int64_t re;
    int64_t im;
} wm_gauss_t;

typedef struct {
    int64_t c0;
    int64_t c1;
    int64_t c2;
    int64_t c3;
} wm_zeta8_t;

__extension__ typedef __int128 wm_i128;

typedef struct {
    int64_t norm2;
    wm_i128 num4;
    wm_i128 num6;
    wm_i128 num8;
} wm_moments_t;

typedef struct {
    int n_id;
    int n_zero;
    int n_flat;
    int n_other;
    int64_t norm2_r0;
    int64_t norm2_r1;
} wm_z8_spectrum_t;

typedef struct {
    uint32_t total_bent;
    uint32_t quad_bent;
    uint32_t deg_gt2_bent;
    uint32_t bent_with_zero_triple;
} wm_bent4_audit_t;

/* Pillar 2: Exhaustive scan of all 65,536 Boolean functions on F_2^4. */
wm_bent4_audit_t wm_audit_all_65536_f2_4(int use_asm);

/* Pillar 3: Exact Z[zeta_8] WH-MUB fiducials and Z[i] Super-MUB witnesses. */
wm_z8_spectrum_t wm_verify_w42_z8_mub(void);
wm_z8_spectrum_t wm_verify_w44_z8_mub(void);
wm_moments_t wm_verify_w42_super_mub(void);
wm_moments_t wm_verify_w44_super_mub(void);

/* Pillar 4: Exact 5-qubit Z[i]^32 rupture witness (using C or ASM FWHT-32). */
wm_moments_t wm_verify_n5_rupture(int use_asm);

/* Pillar 5: Exact Z[zeta_9] char-3 divided-power Alltop for n = 1, 2, 3, 4. */
int wm_verify_char3_alltop(int n, int *out_id, int *out_zero, int *out_flat, int *out_other);

/* Deterministic counter-mode stream using verbatim MIT tsotchke/quantum_rng mixers.
 * HONEST LABELLING: deterministic 64-bit classical integer mixer, NOT quantum randomness. */
uint64_t wm_qrng_absorb_u64(uint64_t seed);
uint64_t wm_qrng_stream_next(uint64_t absorbed_state, uint64_t index);

#ifdef __cplusplus
}
#endif

#endif /* WEYL_MAGIC_H */
