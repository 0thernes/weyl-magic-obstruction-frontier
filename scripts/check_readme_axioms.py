#!/usr/bin/env python3
# SPDX-License-Identifier: Apache-2.0
# Copyright (c) 2026 Alexander Stephen Donahue
"""Strict verbatim audit of results/lean_axioms.txt, README.md, and docs/site/blueprint.html."""

from __future__ import annotations

import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
AXIOMS_FILE = ROOT / "results" / "lean_axioms.txt"
README_FILE = ROOT / "README.md"
BLUEPRINT_FILE = ROOT / "docs" / "site" / "blueprint.html"
ALLOWED = {"propext", "Classical.choice", "Quot.sound"}
LINE_RE = re.compile(
    r"^'([^']+)'\s+(does not depend on any axioms|depends on axioms:\s*\[([^\]]*)\])$"
)


def main() -> int:
    if not AXIOMS_FILE.exists():
        print(f"ERROR: missing {AXIOMS_FILE}", file=sys.stderr)
        return 1
    raw = AXIOMS_FILE.read_text(encoding="utf-8-sig").replace("\r\n", "\n").strip()
    lines = [ln.strip() for ln in raw.splitlines() if ln.strip()]
    if len(lines) < 38:
        print(f"ERROR: expected >= 38 audited declarations, found {len(lines)}", file=sys.stderr)
        return 1

    bad: list[str] = []
    symbols: list[str] = []
    for ln in lines:
        m = LINE_RE.match(ln)
        if not m:
            bad.append(f"malformed axiom line: {ln}")
            continue
        symbols.append(m.group(1))
        if "sorryAx" in ln or "ofReduceBool" in ln:
            bad.append(ln)
        if m.group(3) is not None:
            axioms = {a.strip() for a in m.group(3).split(",") if a.strip()}
            if not axioms.issubset(ALLOWED):
                bad.append(f"{ln} (disallowed: {sorted(axioms - ALLOWED)})")
    if bad:
        print("ERROR: disallowed or malformed axiom entries:", file=sys.stderr)
        for b in bad:
            print("  ", b, file=sys.stderr)
        return 1

    # Strict verbatim check: EVERY line of results/lean_axioms.txt must appear verbatim in README.md
    if not README_FILE.exists():
        print(f"ERROR: missing {README_FILE}", file=sys.stderr)
        return 1
    readme = README_FILE.read_text(encoding="utf-8").replace("\r\n", "\n")
    missing_readme = [ln for ln in lines if ln not in readme]
    if missing_readme:
        print(f"ERROR: README.md missing {len(missing_readme)} verbatim axiom lines:", file=sys.stderr)
        for ln in missing_readme[:5]:
            print("  ", ln, file=sys.stderr)
        return 1

    # Also verify blueprint.html covers every audited declaration symbol
    if BLUEPRINT_FILE.exists():
        bp = BLUEPRINT_FILE.read_text(encoding="utf-8")
        missing_bp = [sym for sym in symbols if sym not in bp]
        if missing_bp:
            print(f"ERROR: blueprint.html missing {len(missing_bp)} audited symbols:", file=sys.stderr)
            for sym in missing_bp[:5]:
                print("  ", sym, file=sys.stderr)
            return 1

    print(
        f"[check_readme_axioms] PASS: {len(lines)} declarations audited verbatim across "
        f"results/lean_axioms.txt, README.md, and blueprint.html; strictly within {sorted(ALLOWED)}"
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
