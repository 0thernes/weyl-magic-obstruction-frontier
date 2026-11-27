<!-- SPDX-License-Identifier: CC-BY-4.0 -->
# Upgrading & Compatibility Policy

`weyl-magic-obstruction-frontier` follows [Semantic Versioning 2.0.0](https://semver.org/) tracked in a single source of truth ([VERSION](VERSION)).

## Stability Guarantees

1. **Palomar Challenge Immutability (`lean/PalomarChallenge.lean` & `lean/comparator.json`):**
   - Existing theorem names (`WeylMagic.Palomar.prove_t1a` through `prove_t5d` and `prove_all_weyl_magic_theorems`) and their formal types will **never** be weakened or silently altered within major version `1.x.y`.
   - New formal theorems in `1.1.x+` (e.g., exact $\alpha=4$ Super-MUB witnesses or `D=81` Lean char-3 certificates) will be added purely additively.
2. **Python Package API (`src/weyl_magic/oracle.py`):**
   - Public functions in `weyl_magic.oracle` maintain backward-compatible return schemas across `1.x.y` releases; schema changes increment `schema_version` inside `data/*.json` and bump the major version if breaking.
3. **Toolchain Upgrades:**
   - Upgrading Lean beyond `v4.35.0` requires re-running `lake build`, `VerifyAxioms.lean`, `lake check --paranoid`, and `lake comparator --config comparator.json --paranoid`, and updating `lean/lean-toolchain` and `results/lean_axioms.txt` atomically.
4. **Deprecation Policy:**
   - Any deprecated CLI flag, Python function, or JSON field is announced in `CHANGELOG.md` at least one minor version prior to removal in a major release.
