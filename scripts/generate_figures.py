#!/usr/bin/env python3
# SPDX-License-Identifier: Apache-2.0
# Copyright (c) 2026 Alexander Stephen Donahue
"""Generate 5 publication-grade Okabe-Ito vector PDF figures and GitHub social-preview PNG."""

from __future__ import annotations

import json
import math
from pathlib import Path

import matplotlib

matplotlib.use("Agg")
import matplotlib.pyplot as plt  # noqa: E402
import numpy as np  # noqa: E402

ROOT = Path(__file__).resolve().parents[1]
DATA = ROOT / "data"
FIG_DIR = ROOT / "paper" / "figures"
MEDIA_DIR = ROOT / "docs" / "media"

# Okabe-Ito colorblind-safe palette
OKABE = {
    "orange": "#E69F00",
    "sky": "#56B4E9",
    "green": "#009E73",
    "yellow": "#F0E442",
    "blue": "#0072B2",
    "vermilion": "#D55E00",
    "purple": "#CC79A7",
    "black": "#111827",
    "gray": "#6B7280",
}

plt.rcParams.update(
    {
        "font.family": "serif",
        "font.size": 9.5,
        "axes.titlesize": 10.5,
        "axes.labelsize": 9.5,
        "legend.fontsize": 8.2,
        "xtick.labelsize": 8.5,
        "ytick.labelsize": 8.5,
        "axes.spines.top": False,
        "axes.spines.right": False,
        "pdf.fonttype": 42,
        "ps.fonttype": 42,
    }
)


def fig1_order16_phase_diagram() -> None:
    cpp_path = DATA / "cpp_search_phase_diagram.json"
    cpp = json.loads(cpp_path.read_text(encoding="utf-8-sig"))
    gmap = {row["group"]: row for row in cpp["groups"]}

    labels = [
        r"$\mathbb{Z}_{16}$" + "\n(Zauner SIC)",
        r"$\mathbb{Z}_4 \times \mathbb{Z}_4$" + "\n(Super-MUB)",
        r"$\mathbb{Z}_4 \times \mathbb{Z}_2^2$" + "\n(Exact WH-MUB)",
        r"$\mathbb{Z}_8 \times \mathbb{Z}_2$" + "\n(Sub-MUB)",
        r"$\mathbb{Z}_2^4$" + "\n(4-Qubit Cubic)",
    ]
    keys = ["Z16", "Z4xZ4", "Z4xZ2^2", "Z8xZ2", "Z2^4"]
    phi4_vals = [gmap[k]["best_phi4"] for k in keys]
    colors = [
        OKABE["blue"],
        OKABE["vermilion"],
        OKABE["green"],
        OKABE["orange"],
        OKABE["purple"],
    ]

    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(9.2, 3.6), gridspec_kw={"width_ratios": [1.55, 1.0]})

    x = np.arange(len(keys))
    bars = ax1.bar(x, phi4_vals, width=0.58, color=colors, edgecolor="#1F2937", linewidth=0.7)
    ax1.axhline(32 / 17, color=OKABE["blue"], ls="--", lw=1.0, alpha=0.8, label=r"Welch SIC $32/17 \approx 1.8824$")
    ax1.axhline(31 / 16, color=OKABE["green"], ls="-.", lw=1.1, alpha=0.9, label=r"WH-MUB $31/16 = 1.9375$")
    ax1.set_xticks(x)
    ax1.set_xticklabels(labels, fontsize=8.0)
    ax1.set_ylabel(r"Minimal 4th Moment $\Phi_4$ (lower = higher $M_2$)")
    ax1.set_ylim(1.82, 2.22)
    ax1.set_title("(a) Complete Order-16 Abelian Phase Diagram ($D=16$)")
    for b, v in zip(bars, phi4_vals):
        ax1.text(b.get_x() + b.get_width() / 2, v + 0.008, f"{v:.4f}", ha="center", va="bottom", fontsize=7.8)
    ax1.legend(loc="upper left", frameon=True, framealpha=0.9)
    ax1.grid(axis="y", ls=":", alpha=0.35)

    # Panel (b): Order-8 phase diagram
    labels8 = [
        r"$\mathbb{Z}_8$" + "\n(SIC)",
        r"$\mathbb{Z}_2^3$" + "\n(Hoggar)",
        r"$\mathbb{Z}_4 \times \mathbb{Z}_2$" + "\n(Super-MUB)",
    ]
    keys8 = ["Z8", "Z2^3", "Z4xZ2"]
    vals8 = [gmap[k]["best_phi4"] for k in keys8]
    c8 = [OKABE["blue"], OKABE["sky"], OKABE["vermilion"]]
    x8 = np.arange(len(keys8))
    b8 = ax2.bar(x8, vals8, width=0.52, color=c8, edgecolor="#1F2937", linewidth=0.7)
    ax2.axhline(16 / 9, color=OKABE["blue"], ls="--", lw=1.0, alpha=0.8, label=r"Welch SIC $16/9 \approx 1.7778$")
    ax2.axhline(15 / 8, color=OKABE["green"], ls="-.", lw=1.1, alpha=0.9, label=r"WH-MUB $15/8 = 1.8750$")
    ax2.set_xticks(x8)
    ax2.set_xticklabels(labels8, fontsize=8.2)
    ax2.set_ylim(1.74, 1.92)
    ax2.set_title("(b) Complete Order-8 Phase Diagram ($D=8$)")
    for b, v in zip(b8, vals8):
        ax2.text(b.get_x() + b.get_width() / 2, v + 0.004, f"{v:.4f}", ha="center", va="bottom", fontsize=7.8)
    ax2.legend(loc="lower right", frameon=True, framealpha=0.9)
    ax2.grid(axis="y", ls=":", alpha=0.35)

    fig.tight_layout()
    fig.savefig(FIG_DIR / "fig1_abelian_phase_diagram.pdf", bbox_inches="tight")
    plt.close(fig)


def fig2_alpha_crossover() -> None:
    rows = json.loads((DATA / "alpha_crossover_curves.json").read_text(encoding="utf-8"))
    alphas = np.array([r["alpha"] for r in rows])
    d42 = np.array([r["v42_delta_M"] for r in rows])
    d44 = np.array([r["v44_delta_M"] for r in rows])

    fig, ax = plt.subplots(figsize=(7.6, 3.6))
    ax.axhline(0.0, color=OKABE["black"], lw=1.0, ls="--", label="WH-MUB baseline ($\\Delta M_\\alpha = 0$)")
    ax.plot(alphas, d42, color=OKABE["vermilion"], lw=2.0, label=r"$v_{4,2} \in \mathbb{Z}[i]^8$ in $W(4)\otimes W(2)$")
    ax.plot(
        alphas,
        d44,
        color=OKABE["blue"],
        lw=2.0,
        ls="-.",
        label=r"$v_{4,4} \in \mathbb{Z}[i]^{16}$ in $W(4)\otimes W(4)$",
    )

    # Highlight certified integer alpha = 2, 3, 4 points
    for al, col in [(2.0, OKABE["green"]), (3.0, OKABE["green"]), (4.0, OKABE["purple"])]:
        idx = int(round((al - 1.5) / 0.1))
        ax.scatter([al, al], [d42[idx], d44[idx]], color=col, s=36, zorder=5, edgecolor="white", linewidth=0.6)

    ax.fill_between(alphas, 0, np.maximum(d42, 0), color=OKABE["vermilion"], alpha=0.10)
    ax.fill_between(alphas, np.minimum(d42, 0), 0, color=OKABE["purple"], alpha=0.08)
    ax.annotate(r"Super-MUB beats WH-MUB ($\alpha = 2, 3$)", xy=(2.2, 0.014), fontsize=8.5, color=OKABE["vermilion"])
    ax.annotate(r"Fixed-witness crossover ($\alpha = 4$)", xy=(3.55, -0.0034), fontsize=8.3, color=OKABE["purple"])
    ax.set_ylim(-0.0048, 0.039)

    ax.set_xlabel("Stabilizer Rényi Index $\\alpha$")
    ax.set_ylabel(r"Magic Excess $\Delta M_\alpha = M_\alpha(v) - M_\alpha(\mathrm{WH\text{-}MUB})$")
    ax.set_title(r"Exact $\mathbb{Z}[i]$ Super-MUB Excess and Fixed-Witness $\alpha$-Crossover (T3c, T3d)")
    ax.legend(loc="upper right", frameon=True)
    ax.grid(ls=":", alpha=0.35)
    fig.tight_layout()
    fig.savefig(FIG_DIR / "fig2_super_mub_alpha_crossover.pdf", bbox_inches="tight")
    plt.close(fig)


def fig3_two_stabilizer_tower_and_rupture() -> None:
    rows = json.loads((DATA / "two_stabilizer_tower_curves.json").read_text(encoding="utf-8"))
    th = np.array([r["theta"] for r in rows])
    th_pi = th / math.pi

    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(9.2, 3.6))

    ax1.plot(th_pi, [r["phi4_n2"] for r in rows], color=OKABE["green"], lw=1.8, label=r"$n=2$ (min $7/4$, WH-MUB)")
    ax1.plot(th_pi, [r["phi4_n3"] for r in rows], color=OKABE["blue"], lw=1.8, label=r"$n=3$ (min $16/9$, Hoggar SIC)")
    ax1.plot(th_pi, [r["phi4_n4"] for r in rows], color=OKABE["orange"], lw=2.1, label=r"$n=4$ (cubic min $2.1505$)")
    ax1.plot(
        th_pi,
        [r["phi4_n5"] for r in rows],
        color=OKABE["vermilion"],
        lw=2.0,
        ls="--",
        label=r"$n=5$ (SOS floor $\geq 3$)",
    )
    ax1.axhline(
        693568064 / 260144641,
        color=OKABE["purple"],
        lw=1.6,
        ls=":",
        label=r"$n=5$ $\mathbb{Z}[i]^{32}$ rupture ($2.6661$)",
    )
    ax1.set_xlim(0.0, 1.0)
    ax1.set_ylim(1.5, 4.6)
    ax1.set_xlabel(r"Relative Phase $\theta / \pi$")
    ax1.set_ylabel(r"Pauli 4th Moment $\Phi_4(|\Psi_n(\theta)\rangle)$")
    ax1.set_title(r"(a) Two-Stabilizer Tower Unification ($n \leq 4$) & $n=5$ Rupture")
    ax1.legend(loc="upper left", fontsize=7.6, frameon=True)
    ax1.grid(ls=":", alpha=0.35)

    # Panel (b): QGT Fubini-Study metric g_{theta,theta}(theta)
    for n, col in [(1, OKABE["gray"]), (2, OKABE["green"]), (3, OKABE["blue"]), (4, OKABE["orange"])]:
        ax2.plot(th_pi, [r[f"gtt_n{n}"] for r in rows], color=col, lw=1.8, label=rf"$n={n}$ ($D={1 << n}$)")
    ax2.set_xlim(0.0, 1.0)
    ax2.set_xlabel(r"Relative Phase $\theta / \pi$")
    ax2.set_ylabel("Fubini–Study QGT Metric $g_{\\theta\\theta}(\\theta)$")
    ax2.set_title(r"(b) Exact QGT Metric $g_{\theta\theta} = (1-D^{-1}) / (2 + 2 D^{-1/2}\cos\theta)^2$")
    ax2.legend(loc="upper left", frameon=True)
    ax2.grid(ls=":", alpha=0.35)

    fig.tight_layout()
    fig.savefig(FIG_DIR / "fig3_two_stab_tower_and_qgt.pdf", bbox_inches="tight")
    plt.close(fig)


def fig4_ame_ceiling_vs_mub() -> None:
    ns = [2, 3, 4, 5, 6]
    mub_vals = [2.0 - 1.0 / (2**n) for n in ns]
    # Exact AME(n, 2) lower bounds where AME exists (n=2,3,5,6; no AME(4,2) exists, use 1-uniform for n=4)
    ame_x = [2, 3, 5, 6]
    ame_k = [1, 1, 2, 3]
    ame_vals = []
    for n, k in zip(ame_x, ame_k):
        z = sum(math.comb(n, w) * (3**w) for w in range(1, k + 1))
        ame_vals.append(1.0 + ((2**n - 1) ** 2) / (4**n - 1 - z))

    fig, ax = plt.subplots(figsize=(7.4, 3.5))
    ax.plot(ns, mub_vals, marker="o", color=OKABE["green"], lw=2.0, label=r"WH-MUB threshold $2 - 2^{-n}$")
    ax.scatter(
        ame_x,
        ame_vals,
        color=OKABE["vermilion"],
        s=65,
        zorder=5,
        label="Exact $\\mathrm{AME}(n,2)$ Cauchy–Schwarz floor (T4d)",
    )
    for x, y, dx, lbl in [
        (2, ame_vals[0], 0.08, r"$\mathrm{AME}(2,2)\geq 2$"),
        (3, ame_vals[1], -0.30, r"$\mathrm{AME}(3,2)\geq \frac{97}{54}$"),
        (5, ame_vals[2], -0.35, r"$\mathrm{AME}(5,2)\geq \frac{1879}{918}$"),
        (6, ame_vals[3], -0.45, r"$\mathrm{AME}(6,2)\geq \frac{13}{6}$"),
    ]:
        ax.annotate(lbl, xy=(x, y), xytext=(x + dx, y + 0.045), fontsize=8.0, color=OKABE["vermilion"])
    ax.scatter(
        [4],
        [2.150520],
        marker="D",
        color=OKABE["purple"],
        s=55,
        zorder=5,
        label=r"4-qubit cubic $|\Psi_4(\theta^*)\rangle$ ($2.1505$)",
    )
    ax.scatter(
        [5],
        [693568064 / 260144641],
        marker="s",
        color=OKABE["blue"],
        s=55,
        zorder=5,
        label=r"5-qubit $\mathbb{Z}[i]^{32}$ witness ($2.6661$)",
    )

    ax.set_xticks(ns)
    ax.set_xlabel(r"Number of Qubits $n$")
    ax.set_ylabel(r"Pauli 4th Moment $\Phi_4$")
    ax.set_ylim(1.65, 2.80)
    ax.set_title("Entanglement–Magic Ceiling: $\\mathrm{AME}(n,2)$ Bounds vs. WH-MUB Threshold")
    ax.legend(loc="upper left", fontsize=8.0, frameon=True)
    ax.grid(ls=":", alpha=0.35)
    fig.tight_layout()
    fig.savefig(FIG_DIR / "fig4_ame_magic_ceiling.pdf", bbox_inches="tight")
    plt.close(fig)


def fig5_prime_power_landscape() -> None:
    # Exact M_2 comparison across characteristic p = 2, 3, 5
    fig, ax = plt.subplots(figsize=(7.6, 3.5))
    dims_p3 = [3, 9, 27, 81]
    m2_p3 = [math.log(d * d / (2 * d - 1)) for d in dims_p3]
    dims_p5 = [5, 25]
    m2_p5 = [math.log(d * d / (2 * d - 1)) for d in dims_p5]
    dims_p2_obs = [4, 8, 16, 32]
    m2_p2_best = [
        math.log(4 / (7 / 4)),
        math.log(8 / (16 / 9)),
        math.log(16 / 2.1505201547139396),
        math.log(32 / (693568064 / 260144641)),
    ]
    m2_p2_mub_ref = [math.log(d * d / (2 * d - 1)) for d in dims_p2_obs]

    ax.plot(
        dims_p3,
        m2_p3,
        marker="o",
        color=OKABE["blue"],
        lw=2.0,
        label=r"Char $p=3$ divided-power $\mathbb{Z}_9$ Alltop ($W(3)^{\otimes n}$, exact)",
    )
    ax.plot(
        dims_p5, m2_p5, marker="^", color=OKABE["green"], lw=2.0, label=r"Char $p=5$ Alltop ($W(5)^{\otimes n}$, exact)"
    )
    ax.plot(
        dims_p2_obs, m2_p2_mub_ref, ls="--", color=OKABE["gray"], lw=1.3, label=r"Ideal WH-MUB curve $\ln[D^2/(2D-1)]$"
    )
    ax.plot(
        dims_p2_obs,
        m2_p2_best,
        marker="s",
        color=OKABE["vermilion"],
        lw=2.0,
        label=r"Char $p=2$ multiqubit best ($W(2)^{\otimes n}$, obstructed $n\geq 3$)",
    )

    ax.set_xscale("log", base=2)
    ax.set_xlabel(r"Hilbert Space Dimension $D = p^n$ ($\log_2$ scale)")
    ax.set_ylabel("Stabilizer Rényi Entropy $M_2$ (nats)")
    ax.set_title(r"Characteristic-2 Obstruction vs. Odd-Prime Divided-Power Alltop Tower")
    ax.legend(loc="upper left", fontsize=7.8, frameon=True)
    ax.grid(ls=":", alpha=0.35)
    fig.tight_layout()
    fig.savefig(FIG_DIR / "fig5_char_landscape.pdf", bbox_inches="tight")
    plt.close(fig)


def generate_social_preview() -> None:
    MEDIA_DIR.mkdir(parents=True, exist_ok=True)
    cpp = json.loads((DATA / "cpp_search_phase_diagram.json").read_text(encoding="utf-8-sig"))
    gmap = {row["group"]: row for row in cpp["groups"]}
    keys = ["Z16", "Z4xZ4", "Z4xZ2^2", "Z8xZ2", "Z2^4"]
    labels = ["Z16\n(SIC)", "Z4xZ4\n(Super-MUB)", "Z4xZ2^2\n(WH-MUB)", "Z8xZ2\n(Sub-MUB)", "Z2^4\n(4-Qubit)"]
    vals = [gmap[k]["best_phi4"] for k in keys]
    cols = [OKABE["sky"], OKABE["vermilion"], OKABE["green"], OKABE["orange"], OKABE["purple"]]

    fig = plt.figure(figsize=(12.8, 6.4), dpi=100, facecolor="#0B1120")
    ax = fig.add_axes((0.08, 0.16, 0.86, 0.50), facecolor="#111827")
    x = np.arange(len(keys))
    bars = ax.bar(x, vals, width=0.55, color=cols, edgecolor="#E5E7EB", linewidth=1.1)
    ax.axhline(31 / 16, color=OKABE["green"], ls="--", lw=1.5, label="WH-MUB threshold (31/16 = 1.9375)")
    ax.axhline(32 / 17, color=OKABE["sky"], ls=":", lw=1.5, label="Welch SIC bound (32/17 = 1.8824)")
    ax.set_xticks(x)
    ax.set_xticklabels(labels, color="#F3F4F6", fontsize=11)
    ax.tick_params(axis="y", colors="#D1D5DB", labelsize=10)
    ax.set_ylabel("Minimal 4th Moment Phi_4", color="#F3F4F6", fontsize=11)
    ax.set_ylim(1.82, 2.22)
    for b, v in zip(bars, vals):
        ax.text(
            b.get_x() + b.get_width() / 2,
            v + 0.01,
            f"{v:.4f}",
            ha="center",
            color="#F9FAFB",
            fontsize=11,
            fontweight="bold",
        )
    ax.legend(loc="upper left", facecolor="#1F2937", edgecolor="#374151", labelcolor="#F9FAFB", fontsize=10)
    for spine in ("bottom", "left"):
        ax.spines[spine].set_color("#4B5563")

    fig.text(
        0.08,
        0.87,
        "WEYL-HEISENBERG MAGIC OBSTRUCTION FRONTIER",
        color="#38BDF8",
        fontsize=22,
        fontweight="bold",
        family="sans-serif",
    )
    fig.text(
        0.08,
        0.79,
        "2-Adic Odd-Qubit Obstruction  |  n=4 Bent-Hyperplane Rupture  |  "
        "Super-MUB Torsion Anomalies  |  Char-3 Alltop",
        color="#E5E7EB",
        fontsize=12.5,
        family="sans-serif",
    )
    fig.text(
        0.08,
        0.72,
        "Zero-Mathlib Lean 4.35.0 (6 Kernels, 23 Palomar Targets)  +  "
        "Rust, Zig, C11, C++20, x86-64 ASM, QGTL, Moonlab",
        color="#9CA3AF",
        fontsize=11,
        family="sans-serif",
    )
    fig.text(
        0.08,
        0.04,
        "0TH-2026-020  |  Alexander Stephen Donahue (ORCID 0009-0006-8168-9648)  |  "
        "github.com/0thernes/weyl-magic-obstruction-frontier",
        color="#64748B",
        fontsize=10,
        family="sans-serif",
    )
    fig.savefig(MEDIA_DIR / "social-preview.png", dpi=100, facecolor=fig.get_facecolor())
    plt.close(fig)


def main() -> None:
    FIG_DIR.mkdir(parents=True, exist_ok=True)
    fig1_order16_phase_diagram()
    fig2_alpha_crossover()
    fig3_two_stabilizer_tower_and_rupture()
    fig4_ame_ceiling_vs_mub()
    fig5_prime_power_landscape()
    generate_social_preview()
    print("[generate_figures] Generated 5 PDF figures + docs/media/social-preview.png")


if __name__ == "__main__":
    main()
