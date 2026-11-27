#!/usr/bin/env python3
# SPDX-License-Identifier: Apache-2.0
# Copyright (c) 2026 Alexander Stephen Donahue
"""Freeze PDF and create + clean-room-verify dist/arxiv_submission.tar.gz."""

from __future__ import annotations

import shutil
import subprocess
import sys
import tarfile
import tempfile
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
PAPER = ROOT / "paper"
BUILD = PAPER / "build"
DIST = ROOT / "dist"


def find_tectonic() -> str:
    found = shutil.which("tectonic")
    if found:
        return found
    local = Path.home() / ".local" / "bin" / "tectonic.exe"
    if local.exists():
        return str(local)
    raise FileNotFoundError("tectonic binary not found")


def main() -> int:
    tectonic = find_tectonic()
    BUILD.mkdir(parents=True, exist_ok=True)
    DIST.mkdir(parents=True, exist_ok=True)

    # 1. Compile main.tex
    subprocess.run(
        [
            tectonic,
            "-X",
            "compile",
            str(PAPER / "main.tex"),
            "--outdir",
            str(BUILD),
            "--keep-intermediates",
            "--keep-logs",
        ],
        check=True,
    )
    pdf_src = BUILD / "main.pdf"
    pdf_dst = DIST / "Donahue_2026_weyl_magic_obstruction_frontier.pdf"
    shutil.copy2(pdf_src, pdf_dst)

    # 2. Build clean-room arXiv tarball (main.tex, references.bib, main.bbl, figures/*.pdf)
    tar_path = DIST / "arxiv_submission.tar.gz"
    with tarfile.open(tar_path, "w:gz") as tf:
        tf.add(PAPER / "main.tex", arcname="main.tex")
        tf.add(PAPER / "references.bib", arcname="references.bib")
        if (BUILD / "main.bbl").exists():
            tf.add(BUILD / "main.bbl", arcname="main.bbl")
        for fig in sorted((PAPER / "figures").glob("*.pdf")):
            tf.add(fig, arcname=f"figures/{fig.name}")

    # 3. Clean-room verification: extract into empty temp dir and compile from scratch
    with tempfile.TemporaryDirectory() as td:
        td_path = Path(td)
        out_dir = td_path / "out"
        out_dir.mkdir(parents=True, exist_ok=True)
        with tarfile.open(tar_path, "r:gz") as tf:
            tf.extractall(td_path)
        subprocess.run(
            [tectonic, "-X", "compile", str(td_path / "main.tex"), "--outdir", str(out_dir)],
            check=True,
        )
        out_pdf = out_dir / "main.pdf"
        if not out_pdf.exists() or out_pdf.stat().st_size < 50000:
            print("ERROR: clean-room PDF build failed", file=sys.stderr)
            return 1
        print(
            f"[package_arxiv] PASS: frozen PDF ({pdf_dst.stat().st_size} B) "
            f"& clean-room tarball ({tar_path.stat().st_size} B)"
        )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
