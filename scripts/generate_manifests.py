#!/usr/bin/env python3
# SPDX-License-Identifier: Apache-2.0
# Copyright (c) 2026 Alexander Stephen Donahue
"""Generate data/MANIFEST.sha256 and root MANIFEST.sha256 for cryptographic provenance."""

from __future__ import annotations

import hashlib
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def sha256_file(path: Path) -> str:
    h = hashlib.sha256()
    with path.open("rb") as f:
        for chunk in iter(lambda: f.read(65536), b""):
            h.update(chunk)
    return h.hexdigest()


def main() -> None:
    data_dir = ROOT / "data"
    data_files = sorted(p for p in data_dir.glob("*") if p.is_file() and p.name != "MANIFEST.sha256")
    data_lines = [f"{sha256_file(p)}  data/{p.name}" for p in data_files]
    with (data_dir / "MANIFEST.sha256").open("w", encoding="utf-8", newline="\n") as f:
        f.write("\n".join(data_lines) + "\n")

    # Root manifest: key verified artifacts (Lean sources, data, results, frozen PDF/tarball if present)
    targets: list[Path] = []
    targets.extend(sorted((ROOT / "lean").rglob("*.lean")))
    targets.extend(
        [
            ROOT / "formalization.yaml",
            ROOT / ".zenodo.json",
            ROOT / "lean" / "lakefile.toml",
            ROOT / "lean" / "comparator.json",
            ROOT / "lean" / "formalization.yaml",
        ]
    )
    targets.extend(data_files)
    if (ROOT / "results" / "lean_axioms.txt").exists():
        targets.append(ROOT / "results" / "lean_axioms.txt")
    for dist_p in sorted((ROOT / "dist").glob("*")) if (ROOT / "dist").exists() else []:
        if dist_p.is_file():
            targets.append(dist_p)

    seen = set()
    root_lines = []
    for p in targets:
        if p.exists() and p not in seen:
            seen.add(p)
            rel = p.relative_to(ROOT).as_posix()
            root_lines.append(f"{sha256_file(p)}  {rel}")
    with (ROOT / "MANIFEST.sha256").open("w", encoding="utf-8", newline="\n") as f:
        f.write("\n".join(root_lines) + "\n")
    print(
        f"[generate_manifests] Wrote data/MANIFEST.sha256 ({len(data_lines)} files) "
        f"and MANIFEST.sha256 ({len(root_lines)} files)"
    )


if __name__ == "__main__":
    main()
