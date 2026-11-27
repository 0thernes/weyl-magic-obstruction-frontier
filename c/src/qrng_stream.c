/* SPDX-License-Identifier: Apache-2.0 AND MIT */
/* Copyright (c) 2026 Alexander Stephen Donahue (counter-mode wrapper) */
/* Upstream mixer block: MIT License, Copyright (c) 2024 Tsotchke (tsotchke/quantum_rng) */
/*
 * HONEST LABELLING: These mixers are deterministic 64-bit classical integer
 * arithmetic copied verbatim from tsotchke/quantum_rng (commit 1a77e77f).
 * They are NOT quantum randomness, NOT a hardware entropy source, and carry
 * no physical or cryptographic claim. They provide a cross-platform bit-exact
 * deterministic seed stream shared across C, C++, Rust, Zig, Python, and Node.js.
 */

#include "weyl_magic.h"

/* ---- BEGIN UPSTREAM (verbatim from tsotchke/quantum_rng) ---------------- */
#define QRNG_FINE_STRUCTURE 0x7297352743776A1BULL
#define QRNG_PLANCK         0x6955927086495225ULL
#define QRNG_GOLDEN_RATIO   0x9E3779B97F4A7C15ULL
#define QRNG_SQRT2          0x6A09E667F3BCC908ULL
#define QRNG_HEISENBERG     0xC13FA9A902A6328FULL
#define QRNG_SCHRODINGER    0x91E10DA5C79E7B1DULL
#define QRNG_PAULI_X        0x4C957F2D8A1E6B3CULL
#define QRNG_PAULI_Y        0xD3E99E3B6C1A4F78ULL
#define QRNG_PAULI_Z        0x8F142FC07892A5B6ULL

static inline uint64_t splitmix64(uint64_t x) {
    x ^= x >> 30;
    x *= 0xbf58476d1ce4e5b9ULL;
    x ^= x >> 27;
    x *= 0x94d049bb133111ebULL;
    x ^= x >> 31;
    x *= QRNG_HEISENBERG;
    x ^= x >> 29;
    return x;
}

static inline uint64_t hadamard_mix(uint64_t x) {
    x = splitmix64(x);
    x ^= QRNG_PAULI_X * (x >> 12);
    x *= QRNG_FINE_STRUCTURE;
    x ^= QRNG_PAULI_Y * (x >> 25);
    x *= QRNG_PLANCK;
    x ^= QRNG_PAULI_Z * (x >> 27);
    x *= QRNG_SCHRODINGER;
    x ^= x >> 13;
    return x;
}

static uint64_t absorb_seed(const uint8_t *seed, size_t seed_len) {
    uint64_t h = QRNG_SQRT2 ^ splitmix64((uint64_t)seed_len + QRNG_GOLDEN_RATIO);
    for (size_t i = 0; i < seed_len; i++) {
        h ^= (uint64_t)seed[i] + QRNG_GOLDEN_RATIO + (h << 6) + (h >> 2);
        h = hadamard_mix(h);
    }
    return h ^ splitmix64((uint64_t)seed_len);
}
/* ---- END UPSTREAM ------------------------------------------------------- */

uint64_t wm_qrng_absorb_u64(uint64_t seed) {
    uint8_t le[8];
    for (int i = 0; i < 8; i++) {
        le[i] = (uint8_t)((seed >> (8 * i)) & 0xFFU);
    }
    return absorb_seed(le, 8U);
}

uint64_t wm_qrng_stream_next(uint64_t absorbed_state, uint64_t index) {
    return hadamard_mix(absorbed_state + (index + 1ULL) * QRNG_GOLDEN_RATIO);
}
