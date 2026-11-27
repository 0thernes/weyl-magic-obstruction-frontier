<!-- SPDX-License-Identifier: CC-BY-4.0 -->
# QGTL Provenance and Scope

Upstream: [tsotchke/quantum_geometric_tensor](https://github.com/tsotchke/quantum_geometric_tensor).
Pinned commit: [`770994aa8ddd858e6bb16eebb25250a7b9f67c96`](https://github.com/tsotchke/quantum_geometric_tensor/tree/770994aa8ddd858e6bb16eebb25250a7b9f67c96)
(upstream commit description: v0.777 beta release).

Verified against the vendored files in this repository via `git hash-object` on 2026-11-27:

| Local/upstream path | Git blob SHA-1 |
|---|---|
| `src/quantum_geometric/distributed/differential_geometry.c` | `f2f92a68a92f7d4866eea24e6e9a810c21b94e6a` |
| `include/quantum_geometric/distributed/differential_geometry.h` | `0222e4dbeb60fd2e003f025466d7ffa1ec424c60` |
| `LICENSE` | `e42af9827970b426259e4e453b321b2ebcd6321c` |

These files match upstream verbatim after LF normalization, and the upstream MIT license
is retained. The one local compatibility file is `stub/cblas.h`, an empty header explicitly
labeled as local; the compiled translation unit makes zero calls to BLAS, so no BLAS
routine is replaced or emulated.

In `weyl-magic-obstruction-frontier`, one program links this source:
[`c/src/qgtl_bridge.c`](../../c/src/qgtl_bridge.c) calls `diffgeo_engine_create`,
`diffgeo_point_create`, and `diffgeo_distance` (the Fubini–Study geodesic distance
$\arccos|\langle\psi|\phi\rangle|$ on caller-normalized pure states) to compute
Richardson-extrapolated Fubini–Study metric values $g_{\theta\theta}(\theta)$ along the
Two-Stabilizer Magic Tower $|\Psi_n(\theta)\rangle$ across $n = 1, 2, 3, 4$ (20 test
points), comparing against the Lean-verified closed form
$(1 - D^{-1})/(2 + 2 D^{-1/2}\cos\theta)^2$ (`T5d`). Only this classical double-precision
differential-geometry kernel is exercised; the broader QGTL library, distributed backends,
and GPU paths are neither built nor validated here.
