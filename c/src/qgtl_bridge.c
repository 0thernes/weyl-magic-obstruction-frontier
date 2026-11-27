/* SPDX-License-Identifier: Apache-2.0 */
/* Copyright (c) 2026 Alexander Stephen Donahue */
/*
 * QGTL Fubini-Study metric cross-check along the Two-Stabilizer Magic Tower |Psi_n(theta)>.
 * Links unmodified vendored third_party/qgtl/src/quantum_geometric/distributed/differential_geometry.c
 * (tsotchke/quantum_geometric_tensor v0.777, MIT License, Copyright (c) 2024 Tsotchke).
 *
 * HONEST LABELLING: Ordinary double-precision classical arithmetic computing
 * finite-difference Fubini-Study line elements ds^2 / dtheta^2 via QGTL's diffgeo_distance
 * against our Lean-verified exact closed form g_{theta,theta}(theta) = (1 - 1/D) / (2 + 2 cos(theta)/sqrt(D))^2.
 * Not a formal proof and not executed on quantum hardware.
 */

#include "quantum_geometric/distributed/differential_geometry.h"
#include <math.h>
#include <stdio.h>
#include <stdlib.h>

static void build_two_stab_state(int n, double theta, ComplexDouble *psi) {
    int D = 1 << n;
    double inv_sqrtD = 1.0 / sqrt((double)D);
    double ct = cos(theta);
    double st = sin(theta);
    double norm = sqrt(2.0 + 2.0 * inv_sqrtD * ct);
    for (int x = 0; x < D; x++) {
        double re = inv_sqrtD * ct + (x == 0 ? 1.0 : 0.0);
        double im = inv_sqrtD * st;
        psi[x].real = re / norm;
        psi[x].imag = im / norm;
    }
}

int main(void) {
    printf("[qgtl] QGTL diffgeo Fubini-Study cross-check (classical double-precision arithmetic, no quantum hardware)\n");
    diffgeo_engine_t *eng = diffgeo_engine_create();
    if (!eng) {
        fprintf(stderr, "[qgtl] FAIL: diffgeo_engine_create returned NULL\n");
        return 1;
    }

    const double thetas[5] = {0.3, 0.9, 1.5707963267948966, 2.2, 2.5877844097111044};
    const double eps1 = 1e-3;
    const double eps2 = 5e-4;
    double max_rel_err = 0.0;
    int checks = 0;

    for (int n = 1; n <= 4; n++) {
        int D = 1 << n;
        ComplexDouble psi_m1[16], psi_p1[16], psi_m2[16], psi_p2[16];
        for (int ti = 0; ti < 5; ti++) {
            double th = thetas[ti];
            build_two_stab_state(n, th - eps1, psi_m1);
            build_two_stab_state(n, th + eps1, psi_p1);
            build_two_stab_state(n, th - eps2, psi_m2);
            build_two_stab_state(n, th + eps2, psi_p2);
            diffgeo_point_t *pm1 = diffgeo_point_create(eng, psi_m1, (size_t)D);
            diffgeo_point_t *pp1 = diffgeo_point_create(eng, psi_p1, (size_t)D);
            diffgeo_point_t *pm2 = diffgeo_point_create(eng, psi_m2, (size_t)D);
            diffgeo_point_t *pp2 = diffgeo_point_create(eng, psi_p2, (size_t)D);
            if (!pm1 || !pp1 || !pm2 || !pp2) {
                fprintf(stderr, "[qgtl] FAIL: diffgeo_point_create\n");
                return 1;
            }
            double d1 = diffgeo_distance(eng, pm1, pp1);
            double d2 = diffgeo_distance(eng, pm2, pp2);
            double g1 = (d1 / (2.0 * eps1)) * (d1 / (2.0 * eps1));
            double g2 = (d2 / (2.0 * eps2)) * (d2 / (2.0 * eps2));
            /* Richardson extrapolation eliminates O(eps^2) curvature error while avoiding acos(1) loss */
            double g_num = (4.0 * g2 - g1) / 3.0;
            double N = 2.0 + 2.0 * cos(th) / sqrt((double)D);
            double g_exact = (1.0 - 1.0 / (double)D) / (N * N);
            double rel_err = fabs(g_num - g_exact) / g_exact;
            if (rel_err > max_rel_err) max_rel_err = rel_err;
            checks++;
            diffgeo_point_destroy(pm1);
            diffgeo_point_destroy(pp1);
            diffgeo_point_destroy(pm2);
            diffgeo_point_destroy(pp2);
        }
    }
    diffgeo_engine_destroy(eng);

    printf("[qgtl] checks=%d max_rel_err=%.3e\n", checks, max_rel_err);
    if (max_rel_err > 1e-6) {
        printf("[qgtl] FAIL: relative error exceeds 1e-6\n");
        return 1;
    }
    printf("[qgtl] PASS: QGTL Fubini-Study metric matches exact closed form across n=1..4\n");
    return 0;
}
