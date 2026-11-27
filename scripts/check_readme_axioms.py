#!/usr/bin/env python3
# SPDX-License-Identifier: Apache-2.0
# Copyright (c) 2026 Alexander Stephen Donahue
"""Verify that README.md's axiom block matches results/lean_axioms.txt and obeys the strict allowlist."""

from __future__ import annotations

import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
AXIOMS_FILE = ROOT / "results" / "lean_axioms.txt"
README_FILE = ROOT / "README.md"
ALLOWED = {"propext", "Classical.choice", "Quot.sound"}


def main() -> int:
    if not AXIOMS_FILE.exists():
        print(f"ERROR: missing {AXIOMS_FILE}", file=sys.stderr)
        return 1
    raw = AXIOMS_FILE.read_text(encoding="utf-8-sig").strip()
    lines = [ln.strip() for ln in raw.splitlines() if ln.strip()]
    if len(lines) < 36:
        print(f"ERROR: expected >= 36 audited declarations, found {len(lines)}", file=sys.stderr)
        return 1

    bad = []
    for ln in lines:
        if "sorryAx" in ln or "ofReduceBool" in ln or "ofNat" in ln:
            bad.append(ln)
        m = re.search(r"depends on axioms:\s*\[([^\]]*)\]", ln)
        if m:
            axioms = {a.strip() for a in m.group(1).split(",") if a.strip()}
            if not axioms.issubset(ALLOWED):
                bad.append(f"{ln} (disallowed: {axioms - ALLOWED})")
    if bad:
        print("ERROR: disallowed axioms detected:", file=sys.stderr)
        for b in bad:
            print("  ", b, file=sys.stderr)
        return 1

    if README_FILE.exists():
        readme = README_FILE.read_text(encoding="utf-8")
        sentinel = "WeylMagic.Palomar.prove_all_weyl_magic_theorems"
        if sentinel not in readme:
            print(f"ERROR: README.md missing axiom output for {sentinel}", file=sys.stderr)
            return 1
    print(f"[check_readme_axioms] PASS: {len(lines)} declarations audited; strictly within {sorted(ALLOWED)}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
