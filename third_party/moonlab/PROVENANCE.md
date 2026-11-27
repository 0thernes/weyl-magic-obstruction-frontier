<!-- SPDX-License-Identifier: CC-BY-4.0 -->
# Moonlab Provenance and Scope

Upstream: [tsotchke/moonlab](https://github.com/tsotchke/moonlab).
Pinned commit: [`cd3b2347e3739327548708073d7e4ac710cc6a6c`](https://github.com/tsotchke/moonlab/tree/cd3b2347e3739327548708073d7e4ac710cc6a6c).
Upstream `VERSION.txt` at that commit is `1.2.1`.

Verified against the vendored files in this repository via `git hash-object` on 2026-11-27:

| Local file | Upstream path | Git blob SHA-1 |
|---|---|---|
| `moonlab.js` | `docs/moonlab.js` | `0881441708dd08062bd2addace26b14f224274ec` |
| `moonlab.wasm` | `docs/moonlab.wasm` | `3c356543328855a45ee954a8fc930d3108cee160` |
| `LICENSE` | `LICENSE` | `60548d1cce27eee2c91f88e03ac5ec51cad9f661` |

The JavaScript wrapper and MIT license match upstream verbatim after LF normalization; the
WASM binary is byte-identical. This is a pinned prebuilt WASM artifact; this repository
does not rebuild `moonlab.wasm` from C/Emscripten source.

In `weyl-magic-obstruction-frontier`, Moonlab is used strictly as a **classical CPU
state-vector simulator** under Node.js by [`node/moonlab_crosscheck.cjs`](../../node/moonlab_crosscheck.cjs).
No quantum hardware, hardware entropy, or physical quantum computation is involved. The
wrapper's WASM32 struct layout (`num_qubits`, `state_dim`, `amplitudes` pointer at byte
offset 8) matches upstream `src/quantum/state.h` at the pinned commit. It initializes and
normalizes the $n = 2$ WH-MUB fiducial $(1,1,1,i)$, the $n = 3$ Hoggar SIC state
$|\Psi_3(3\pi/4)\rangle$, the $n = 4$ cubic optimum $|\Psi_4(\theta^*)\rangle$, and the
$n = 5$ Gaussian-integer rupture witness $v_5$, cross-checking their Pauli 4th moments
$\Phi_4$ against the exact Lean/Python/Rust/C11 values.
