<!-- SPDX-License-Identifier: CC-BY-4.0 -->
# Operations, Provenance, Backups, and Offsite Mirroring

## 1. Release & Deployment Operations

- **GitHub Pages (`docs/site/`):** Deployed automatically from `main` via `.github/workflows/pages.yml` (`actions/deploy-pages@v4`). Zero external runtime dependencies; strict CSP (`default-src 'none'`).
- **One-Command Reproduce & Rollback:**
  - `just reproduce` — executes full clean verification across Lean, Rust, Zig, C11+NASM+QGTL, Moonlab WASM, Python, and clean-room Tectonic PDF compilation.
  - `just rollback <tag>` — cleanly checks out a verified release tag (e.g., `v1.0.0`) and re-verifies `MANIFEST.sha256` digests without rewriting history.

## 2. Cryptographic Integrity & Timestamping

All frozen verification artifacts (Lean sources, `results/lean_axioms.txt`, `data/*.json`, `dist/*.pdf`, `dist/arxiv_submission.tar.gz`) are hashed into `MANIFEST.sha256` and `data/MANIFEST.sha256` by `scripts/generate_manifests.py`:

```bash
python scripts/generate_manifests.py
python scripts/stamp_timestamps.py   # DigiCert RFC 3161 (.tsr) + OpenTimestamps Bitcoin (.ots)
sha256sum -c data/MANIFEST.sha256
sha256sum -c MANIFEST.sha256
```

GitHub Actions CI additionally signs SLSA Build Provenance attestations (`actions/attest-build-provenance@v2`) on every push to `main` and release tag.

## 3. Offsite Mirrors & Archival Backups

To protect against single-host loss or repository mutation, this project maintains **three independent archival mirrors**:

1. **Master Research Archive Submodule:** Pinned at the exact `v1.0.0` commit SHA inside `https://github.com/0thernes/0thernes-research-archive` (`0TH-2026-021`), together with the frozen PDF and verified SHA-256 digest.
2. **Software Heritage (ISO/IEC 18670 SWHID):** Submitted to `archive.softwareheritage.org` via the Save Code Now API upon publication, providing permanent content-addressed archival.
3. **Offline Git Bundle Backup:** Maintainers can create a complete self-contained portable mirror bundle at any release point via:
   ```bash
   git bundle create ../weyl-magic-obstruction-frontier-v1.0.0.bundle --all
   git bundle verify ../weyl-magic-obstruction-frontier-v1.0.0.bundle
   ```
   Store offline bundles alongside `MANIFEST.sha256`, `MANIFEST.sha256.tsr`, and `MANIFEST.sha256.ots`.

## 4. Data Migrations & Schema Versioning

Frozen JSON datasets in `data/` carry an explicit `"schema_version": "1.0"` field. Any backward-incompatible schema update requires incrementing `schema_version`, documenting the migration in `UPGRADING.md`, regenerating `data/MANIFEST.sha256` and `MANIFEST.sha256`, and cutting a new major release tag.
