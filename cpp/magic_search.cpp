// SPDX-License-Identifier: Apache-2.0
// Copyright (c) 2026 Alexander Stephen Donahue
//
// Zero-dependency C++20 high-speed Riemannian L-BFGS / Armijo optimizer for
// Stabilizer Renyi Entropy Phi_{2*alpha} across all five order-16 abelian
// product Weyl-Heisenberg groups (Z_16, Z_8xZ_2, Z_4xZ_4, Z_4xZ_2^2, Z_2^4)
// and all three order-8 groups (Z_8, Z_4xZ_2, Z_2^3), deterministically seeded
// by the verbatim MIT tsotchke/quantum_rng integer mixer (classical arithmetic).

#include "weyl_magic.h"
#include <algorithm>
#include <array>
#include <cmath>
#include <complex>
#include <cstdint>
#include <cstdio>
#include <cstdlib>
#include <iomanip>
#include <iostream>
#include <string>
#include <vector>

namespace {

using cd = std::complex<double>;

struct GroupSpec {
    std::string name;
    std::vector<int> dims;
    int D;
    std::vector<std::vector<int>> shift_tbl; // [a][x] = x +_G a
    std::vector<std::vector<cd>> phase_tbl;  // [b][x] = prod omega_{d_k}^{b_k x_k}
};

std::vector<int> unpack_idx(int x, const std::vector<int>& dims) {
    std::vector<int> r(dims.size());
    for (int k = static_cast<int>(dims.size()) - 1; k >= 0; --k) {
        r[static_cast<size_t>(k)] = x % dims[static_cast<size_t>(k)];
        x /= dims[static_cast<size_t>(k)];
    }
    return r;
}

int pack_idx(const std::vector<int>& tup, const std::vector<int>& dims) {
    int x = 0;
    for (size_t k = 0; k < dims.size(); ++k) {
        x = x * dims[k] + (tup[k] % dims[k]);
    }
    return x;
}

GroupSpec make_group(const std::string& name, const std::vector<int>& dims) {
    GroupSpec g;
    g.name = name;
    g.dims = dims;
    g.D = 1;
    for (int d : dims) g.D *= d;
    g.shift_tbl.assign(static_cast<size_t>(g.D), std::vector<int>(static_cast<size_t>(g.D)));
    g.phase_tbl.assign(static_cast<size_t>(g.D), std::vector<cd>(static_cast<size_t>(g.D)));
    const double two_pi = 6.283185307179586476925286766559;
    for (int a = 0; a < g.D; ++a) {
        auto au = unpack_idx(a, dims);
        for (int x = 0; x < g.D; ++x) {
            auto xu = unpack_idx(x, dims);
            std::vector<int> xau(dims.size());
            double ang = 0.0;
            for (size_t k = 0; k < dims.size(); ++k) {
                xau[k] = (xu[k] + au[k]) % dims[k];
                ang += two_pi * static_cast<double>((au[k] * xu[k]) % dims[k]) /
                       static_cast<double>(dims[k]);
            }
            g.shift_tbl[static_cast<size_t>(a)][static_cast<size_t>(x)] = pack_idx(xau, dims);
            g.phase_tbl[static_cast<size_t>(a)][static_cast<size_t>(x)] =
                cd(std::cos(ang), std::sin(ang));
        }
    }
    return g;
}

// Evaluates Phi_{2*alpha}(psi) and exact Euclidean gradient dPhi/dpsi* (2*D real entries)
// on normalized psi (||psi|| = 1), projected onto the tangent space of the unit sphere.
double eval_phi_and_grad(const GroupSpec& g, const std::vector<cd>& psi, int alpha,
                         std::vector<cd>& grad_out) {
    const int D = g.D;
    std::vector<cd> g_euc(static_cast<size_t>(D), cd(0.0, 0.0));
    double phi = 0.0;

    for (int a = 0; a < D; ++a) {
        const auto& sh = g.shift_tbl[static_cast<size_t>(a)];
        for (int b = 0; b < D; ++b) {
            const auto& ph = g.phase_tbl[static_cast<size_t>(b)];
            cd c(0.0, 0.0);
            for (int x = 0; x < D; ++x) {
                c += std::conj(psi[static_cast<size_t>(x)]) *
                     psi[static_cast<size_t>(sh[static_cast<size_t>(x)])] *
                     ph[static_cast<size_t>(x)];
            }
            const double m2 = std::norm(c);
            double m_pow = 1.0;
            for (int p = 0; p < alpha - 1; ++p) m_pow *= m2;
            phi += m_pow * m2;
            const double factor = 2.0 * static_cast<double>(alpha) * m_pow;
            // d(|c|^2)/dpsi_x^* = c^* * psi[x+a] * ph[x] + c * psi[x-a] * conj(ph[x-a])
            const cd fc_conj = factor * std::conj(c);
            const cd fc = factor * c;
            for (int x = 0; x < D; ++x) {
                const int xa = sh[static_cast<size_t>(x)];
                g_euc[static_cast<size_t>(x)] +=
                    fc_conj * psi[static_cast<size_t>(xa)] * ph[static_cast<size_t>(x)];
                g_euc[static_cast<size_t>(xa)] +=
                    fc * psi[static_cast<size_t>(x)] * std::conj(ph[static_cast<size_t>(x)]);
            }
        }
    }
    // Project onto tangent space of unit sphere: g_tan = g_euc - Re<psi|g_euc> * psi
    double proj = 0.0;
    for (int x = 0; x < D; ++x) {
        proj += std::real(std::conj(psi[static_cast<size_t>(x)]) * g_euc[static_cast<size_t>(x)]);
    }
    grad_out.resize(static_cast<size_t>(D));
    for (int x = 0; x < D; ++x) {
        grad_out[static_cast<size_t>(x)] = g_euc[static_cast<size_t>(x)] - proj * psi[static_cast<size_t>(x)];
    }
    return phi;
}

double eval_phi_only(const GroupSpec& g, const std::vector<cd>& psi, int alpha) {
    const int D = g.D;
    double phi = 0.0;
    for (int a = 0; a < D; ++a) {
        const auto& sh = g.shift_tbl[static_cast<size_t>(a)];
        for (int b = 0; b < D; ++b) {
            const auto& ph = g.phase_tbl[static_cast<size_t>(b)];
            cd c(0.0, 0.0);
            for (int x = 0; x < D; ++x) {
                c += std::conj(psi[static_cast<size_t>(x)]) *
                     psi[static_cast<size_t>(sh[static_cast<size_t>(x)])] *
                     ph[static_cast<size_t>(x)];
            }
            const double m2 = std::norm(c);
            double m_pow = m2;
            for (int p = 1; p < alpha; ++p) m_pow *= m2;
            phi += m_pow;
        }
    }
    return phi;
}

double u64_to_unit_normal(uint64_t u1, uint64_t u2) {
    // Box-Muller using two 53-bit uniform draws from deterministic mixer
    const double inv53 = 1.0 / 9007199254740992.0;
    double a = (static_cast<double>(u1 >> 11) + 0.5) * inv53;
    double b = (static_cast<double>(u2 >> 11) + 0.5) * inv53;
    return std::sqrt(-2.0 * std::log(a)) * std::cos(6.2831853071795864769 * b);
}

void normalize_state(std::vector<cd>& psi) {
    double n2 = 0.0;
    for (const auto& z : psi) n2 += std::norm(z);
    const double inv = 1.0 / std::sqrt(n2);
    for (auto& z : psi) z *= inv;
}

// Compact Riemannian L-BFGS (m=8) on unit sphere S^{2D-1}
double optimize_start(const GroupSpec& g, std::vector<cd>& psi, int alpha, int max_iters) {
    const int D = g.D;
    const int M = 8;
    std::vector<std::vector<cd>> s_hist, y_hist;
    std::vector<double> rho_hist;
    std::vector<cd> grad, prev_psi, prev_grad, dir(static_cast<size_t>(D)), trial(static_cast<size_t>(D));

    normalize_state(psi);
    double f = eval_phi_and_grad(g, psi, alpha, grad);

    auto dot_r = [D](const std::vector<cd>& u, const std::vector<cd>& v) {
        double s = 0.0;
        for (int i = 0; i < D; ++i) {
            s += u[static_cast<size_t>(i)].real() * v[static_cast<size_t>(i)].real() +
                 u[static_cast<size_t>(i)].imag() * v[static_cast<size_t>(i)].imag();
        }
        return s;
    };

    for (int it = 0; it < max_iters; ++it) {
        const double gnorm2 = dot_r(grad, grad);
        if (gnorm2 < 1e-22) break;

        // Two-loop L-BFGS recursion
        std::vector<cd> q = grad;
        const int k = static_cast<int>(s_hist.size());
        std::vector<double> alphas(static_cast<size_t>(k), 0.0);
        for (int i = k - 1; i >= 0; --i) {
            alphas[static_cast<size_t>(i)] = rho_hist[static_cast<size_t>(i)] * dot_r(s_hist[static_cast<size_t>(i)], q);
            for (int j = 0; j < D; ++j) {
                q[static_cast<size_t>(j)] -= alphas[static_cast<size_t>(i)] * y_hist[static_cast<size_t>(i)][static_cast<size_t>(j)];
            }
        }
        double gamma = 1.0;
        if (k > 0) {
            const double yy = dot_r(y_hist.back(), y_hist.back());
            if (yy > 1e-30) gamma = dot_r(s_hist.back(), y_hist.back()) / yy;
        }
        for (int j = 0; j < D; ++j) dir[static_cast<size_t>(j)] = -gamma * q[static_cast<size_t>(j)];
        for (int i = 0; i < k; ++i) {
            const double beta = rho_hist[static_cast<size_t>(i)] * dot_r(y_hist[static_cast<size_t>(i)], dir);
            for (int j = 0; j < D; ++j) {
                dir[static_cast<size_t>(j)] += (alphas[static_cast<size_t>(i)] - beta) * s_hist[static_cast<size_t>(i)][static_cast<size_t>(j)];
            }
        }
        // Fallback to steepest descent if not a descent direction
        double slope = dot_r(grad, dir);
        if (slope >= 0.0) {
            for (int j = 0; j < D; ++j) dir[static_cast<size_t>(j)] = -grad[static_cast<size_t>(j)];
            slope = -gnorm2;
            s_hist.clear(); y_hist.clear(); rho_hist.clear();
        }

        // Backtracking Armijo line search on the sphere
        double step = 1.0;
        double f_new = f;
        bool accepted = false;
        for (int ls = 0; ls < 24; ++ls) {
            for (int j = 0; j < D; ++j) trial[static_cast<size_t>(j)] = psi[static_cast<size_t>(j)] + step * dir[static_cast<size_t>(j)];
            normalize_state(trial);
            f_new = eval_phi_only(g, trial, alpha);
            if (f_new <= f + 1e-4 * step * slope) {
                accepted = true;
                break;
            }
            step *= 0.5;
        }
        if (!accepted) break;

        prev_psi = psi;
        prev_grad = grad;
        psi = trial;
        f = eval_phi_and_grad(g, psi, alpha, grad);

        std::vector<cd> s_vec(static_cast<size_t>(D)), y_vec(static_cast<size_t>(D));
        for (int j = 0; j < D; ++j) {
            s_vec[static_cast<size_t>(j)] = psi[static_cast<size_t>(j)] - prev_psi[static_cast<size_t>(j)];
            y_vec[static_cast<size_t>(j)] = grad[static_cast<size_t>(j)] - prev_grad[static_cast<size_t>(j)];
        }
        const double sy = dot_r(s_vec, y_vec);
        if (sy > 1e-24) {
            if (static_cast<int>(s_hist.size()) == M) {
                s_hist.erase(s_hist.begin());
                y_hist.erase(y_hist.begin());
                rho_hist.erase(rho_hist.begin());
            }
            s_hist.push_back(std::move(s_vec));
            y_hist.push_back(std::move(y_vec));
            rho_hist.push_back(1.0 / sy);
        }
    }
    return f;
}

} // namespace

int main(int argc, char** argv) {
    int starts = 64;
    if (argc > 1) starts = std::max(4, std::atoi(argv[1]));
    const int max_iters = 220;

    std::vector<GroupSpec> groups = {
        make_group("Z8", {8}),
        make_group("Z4xZ2", {4, 2}),
        make_group("Z2^3", {2, 2, 2}),
        make_group("Z16", {16}),
        make_group("Z8xZ2", {8, 2}),
        make_group("Z4xZ4", {4, 4}),
        make_group("Z4xZ2^2", {4, 2, 2}),
        make_group("Z2^4", {2, 2, 2, 2}),
    };

    const uint64_t absorbed = wm_qrng_absorb_u64(0x5745594C2026ULL);
    uint64_t stream_idx = 0;

    std::cout << std::fixed << std::setprecision(12);
    std::cout << "{\n  \"starts_per_group\": " << starts << ",\n  \"groups\": [\n";

    for (size_t gi = 0; gi < groups.size(); ++gi) {
        const auto& g = groups[gi];
        double best_a2 = 1e30, best_a3 = 1e30, best_a4 = 1e30;
        std::vector<cd> best_psi_a2(static_cast<size_t>(g.D));

        // Optimize alpha = 2 across all starts
        for (int s = 0; s < starts; ++s) {
            std::vector<cd> psi(static_cast<size_t>(g.D));
            for (int x = 0; x < g.D; ++x) {
                uint64_t u1 = wm_qrng_stream_next(absorbed, stream_idx++);
                uint64_t u2 = wm_qrng_stream_next(absorbed, stream_idx++);
                uint64_t u3 = wm_qrng_stream_next(absorbed, stream_idx++);
                uint64_t u4 = wm_qrng_stream_next(absorbed, stream_idx++);
                psi[static_cast<size_t>(x)] = cd(u64_to_unit_normal(u1, u2),
                                                 u64_to_unit_normal(u3, u4));
            }
            double val = optimize_start(g, psi, 2, max_iters);
            if (val < best_a2) {
                best_a2 = val;
                best_psi_a2 = psi;
            }
        }
        // Also optimize alpha = 3 and alpha = 4 (fewer starts for speed)
        const int high_starts = std::max(8, starts / 4);
        for (int s = 0; s < high_starts; ++s) {
            std::vector<cd> psi3(static_cast<size_t>(g.D)), psi4(static_cast<size_t>(g.D));
            for (int x = 0; x < g.D; ++x) {
                uint64_t u1 = wm_qrng_stream_next(absorbed, stream_idx++);
                uint64_t u2 = wm_qrng_stream_next(absorbed, stream_idx++);
                uint64_t u3 = wm_qrng_stream_next(absorbed, stream_idx++);
                uint64_t u4 = wm_qrng_stream_next(absorbed, stream_idx++);
                psi3[static_cast<size_t>(x)] = cd(u64_to_unit_normal(u1, u2),
                                                  u64_to_unit_normal(u3, u4));
                psi4[static_cast<size_t>(x)] = psi3[static_cast<size_t>(x)];
            }
            best_a3 = std::min(best_a3, optimize_start(g, psi3, 3, max_iters));
            best_a4 = std::min(best_a4, optimize_start(g, psi4, 4, max_iters));
        }

        const double mub_a2 = 2.0 - 1.0 / static_cast<double>(g.D);
        const double mub_a3 = 1.0 + static_cast<double>(g.D - 1) / static_cast<double>(g.D * g.D);
        const double mub_a4 = 1.0 + static_cast<double>(g.D - 1) / static_cast<double>(g.D * g.D * g.D);
        const double sic_a2 = 2.0 * static_cast<double>(g.D) / static_cast<double>(g.D + 1);
        const double m2_best = std::log(static_cast<double>(g.D) / best_a2);

        std::cout << "    {\"group\": \"" << g.name << "\", \"D\": " << g.D
                  << ", \"best_phi4\": " << best_a2
                  << ", \"best_M2\": " << m2_best
                  << ", \"best_phi6\": " << best_a3
                  << ", \"best_phi8\": " << best_a4
                  << ", \"mub_phi4\": " << mub_a2
                  << ", \"mub_phi6\": " << mub_a3
                  << ", \"mub_phi8\": " << mub_a4
                  << ", \"sic_phi4\": " << sic_a2 << "}"
                  << (gi + 1 < groups.size() ? "," : "") << "\n";
    }
    std::cout << "  ]\n}\n";
    return 0;
}
