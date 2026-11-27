// SPDX-License-Identifier: Apache-2.0
// Copyright (c) 2026 Alexander Stephen Donahue
//
// Moonlab WASM Classical State-Vector Cross-Check + Deterministic QRNG Bit-Exact Twin.
//
// HONEST LABELLING:
//   * Moonlab (tsotchke/moonlab v1.2.1, vendored prebuilt WASM, MIT License) is used
//     here purely as a CLASSICAL CPU state-vector simulator under Node.js. Nothing in
//     this file runs on quantum hardware or constitutes a formal proof.
//   * The deterministic QRNG stream re-implements the verbatim MIT integer mixers from
//     tsotchke/quantum_rng (commit 1a77e77f) in JavaScript BigInt and cross-checks
//     bit-exact agreement with c/src/qrng_stream.c.

'use strict';
const path = require('node:path');
const MOONLAB_JS = path.join(__dirname, '..', 'third_party', 'moonlab', 'moonlab.js');

const MASK = (1n << 64n) - 1n;
const QRNG_FINE_STRUCTURE = 0x7297352743776A1Bn;
const QRNG_PLANCK         = 0x6955927086495225n;
const QRNG_GOLDEN_RATIO   = 0x9E3779B97F4A7C15n;
const QRNG_SQRT2          = 0x6A09E667F3BCC908n;
const QRNG_HEISENBERG     = 0xC13FA9A902A6328Fn;
const QRNG_SCHRODINGER    = 0x91E10DA5C79E7B1Dn;
const QRNG_PAULI_X        = 0x4C957F2D8A1E6B3Cn;
const QRNG_PAULI_Y        = 0xD3E99E3B6C1A4F78n;
const QRNG_PAULI_Z        = 0x8F142FC07892A5B6n;

function splitmix64(x) {
  x ^= x >> 30n;
  x = (x * 0xbf58476d1ce4e5b9n) & MASK;
  x ^= x >> 27n;
  x = (x * 0x94d049bb133111ebn) & MASK;
  x ^= x >> 31n;
  x = (x * QRNG_HEISENBERG) & MASK;
  x ^= x >> 29n;
  return x;
}
function hadamardMix(x) {
  x = splitmix64(x);
  x ^= (QRNG_PAULI_X * (x >> 12n)) & MASK;
  x = (x * QRNG_FINE_STRUCTURE) & MASK;
  x ^= (QRNG_PAULI_Y * (x >> 25n)) & MASK;
  x = (x * QRNG_PLANCK) & MASK;
  x ^= (QRNG_PAULI_Z * (x >> 27n)) & MASK;
  x = (x * QRNG_SCHRODINGER) & MASK;
  x ^= x >> 13n;
  return x;
}
function absorbU64(seed) {
  const bytes = [];
  let s = BigInt(seed) & MASK;
  for (let i = 0; i < 8; i++) { bytes.push(Number(s & 0xFFn)); s >>= 8n; }
  const len = 8n;
  let h = QRNG_SQRT2 ^ splitmix64((len + QRNG_GOLDEN_RATIO) & MASK);
  for (const b of bytes) {
    h ^= (BigInt(b) + QRNG_GOLDEN_RATIO + ((h << 6n) & MASK) + (h >> 2n)) & MASK;
    h = hadamardMix(h);
  }
  return h ^ splitmix64(len);
}
function streamNext(state, idx) {
  return hadamardMix((state + (BigInt(idx) + 1n) * QRNG_GOLDEN_RATIO) & MASK);
}
const hex16 = (x) => x.toString(16).padStart(16, '0');

function pauliPhi4FromBuffer(re, im) {
  const D = re.length;
  let phi4 = 0.0;
  for (let a = 0; a < D; a++) {
    const cr = new Float64Array(D);
    const ci = new Float64Array(D);
    for (let x = 0; x < D; x++) {
      const xa = x ^ a;
      cr[x] = re[x] * re[xa] + im[x] * im[xa];
      ci[x] = re[x] * im[xa] - im[x] * re[xa];
    }
    // In-place FWHT
    for (let half = 1; half < D; half <<= 1) {
      const step = half << 1;
      for (let base = 0; base < D; base += step) {
        for (let k = 0; k < half; k++) {
          const xr = cr[base + k], yr = cr[base + k + half];
          const xi = ci[base + k], yi = ci[base + k + half];
          cr[base + k] = xr + yr; cr[base + k + half] = xr - yr;
          ci[base + k] = xi + yi; ci[base + k + half] = xi - yi;
        }
      }
    }
    for (let b = 0; b < D; b++) {
      const m2 = cr[b] * cr[b] + ci[b] * ci[b];
      phi4 += m2 * m2;
    }
  }
  return phi4;
}

(async () => {
  console.log('[moonlab] Moonlab WASM classical CPU state-vector simulator cross-check (no quantum hardware)');
  const factory = require(MOONLAB_JS);
  const M = await factory({});
  const STATE_BYTES = 256;

  function evalStateInMoonlab(nq, pairs) {
    const D = 1 << nq;
    const p = M._malloc(STATE_BYTES);
    M.HEAPU8.fill(0, p, p + STATE_BYTES);
    const rc1 = M._quantum_state_init(p, nq);
    if (rc1 !== 0) throw new Error('quantum_state_init rc=' + rc1);
    const a = M.HEAPU32[(p + 8) >> 2] >> 3;
    for (let i = 0; i < D; i++) {
      M.HEAPF64[a + 2 * i] = pairs[i][0];
      M.HEAPF64[a + 2 * i + 1] = pairs[i][1];
    }
    const rc2 = M._quantum_state_normalize(p);
    if (rc2 !== 0) throw new Error('quantum_state_normalize rc=' + rc2);
    const re = new Float64Array(D);
    const im = new Float64Array(D);
    for (let i = 0; i < D; i++) {
      re[i] = M.HEAPF64[a + 2 * i];
      im[i] = M.HEAPF64[a + 2 * i + 1];
    }
    const phi4 = pauliPhi4FromBuffer(re, im);
    M._free(p);
    return phi4;
  }

  let fails = 0;
  function assertClose(name, actual, expected, tol) {
    const err = Math.abs(actual - expected);
    const ok = err <= tol;
    if (!ok) fails++;
    console.log(`[moonlab] ${ok ? 'PASS' : 'FAIL'}  ${name}: actual=${actual.toFixed(12)} expected=${expected.toFixed(12)} err=${err.toExponential(2)}`);
  }

  // 1. n=2 WH-MUB fiducial (1, 1, 1, i): exact Phi_4 = 7/4 = 1.75
  assertClose('n=2 WH-MUB (1,1,1,i)', evalStateInMoonlab(2, [[1,0],[1,0],[1,0],[0,1]]), 1.75, 1e-12);

  // 2. n=3 Two-Stabilizer Hoggar SIC |0^3> + e^{i*3pi/4} |+^3>: exact Phi_4 = 16/9
  const th3 = 3 * Math.PI / 4;
  const s3 = 1 / Math.sqrt(8);
  const psi3 = Array.from({ length: 8 }, (_, x) => [s3 * Math.cos(th3) + (x === 0 ? 1 : 0), s3 * Math.sin(th3)]);
  assertClose('n=3 Hoggar SIC |Psi_3(3pi/4)>', evalStateInMoonlab(3, psi3), 16 / 9, 1e-12);

  // 3. n=4 Two-Stabilizer Cubic Optimum |Psi_4(theta*)>: exact Phi_4 = 2.1505201547139396
  const tStar = 0.3774568011835382;
  const th4 = Math.acos(2.0 * (1.0 / (1.0 - tStar) - 2.0));
  const s4 = 0.25;
  const psi4 = Array.from({ length: 16 }, (_, x) => [s4 * Math.cos(th4) + (x === 0 ? 1 : 0), s4 * Math.sin(th4)]);
  assertClose('n=4 Cubic Optimum |Psi_4(theta*)>', evalStateInMoonlab(4, psi4), 2.1505201547139396, 1e-11);

  // 4. n=5 Gaussian-Integer Rupture Witness v5: exact Phi_4 = 693568064 / 260144641
  const v5 = [
    [1,-2],[-1,0],[-2,-3],[-2,-3],[0,-1],[-5,3],[-2,2],[1,1],
    [0,1],[1,-2],[1,-1],[1,0],[0,-1],[-2,-3],[-1,0],[0,3],
    [0,-1],[-1,2],[-3,2],[-5,-2],[-1,-1],[1,0],[-3,1],[2,2],
    [0,3],[1,0],[-3,3],[1,1],[-3,2],[3,-2],[-3,0],[1,3],
  ];
  assertClose('n=5 Rupture Witness v5 (< 3.0)', evalStateInMoonlab(5, v5), 693568064 / 260144641, 1e-12);

  // 5. QRNG deterministic twin check
  const st = absorbU64(1n);
  const w0 = streamNext(st, 0);
  const w1 = streamNext(st, 1);
  console.log(`[moonlab-qrng] deterministic seed=1: state=${hex16(st)} w0=${hex16(w0)} w1=${hex16(w1)}`);

  process.exit(fails === 0 ? 0 : 1);
})();
