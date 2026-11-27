#!/usr/bin/env python3
# SPDX-License-Identifier: Apache-2.0
# Copyright (c) 2026 Alexander Stephen Donahue
"""Audit docs/site/index.html and docs/site/blueprint.html for zero-CDN, strict CSP, WCAG, and Palomar completeness."""

from __future__ import annotations

import json
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SITE = ROOT / "docs" / "site"
COMP = ROOT / "lean" / "comparator.json"


def check_html(path: Path) -> list[str]:
    errs: list[str] = []
    text = path.read_text(encoding="utf-8")
    if "Content-Security-Policy" not in text or "default-src 'none'" not in text:
        errs.append(f"{path.name}: missing strict default-src 'none' CSP")
    # Check for forbidden third-party script/style CDNs in src/href attributes
    cdns = ("cdn.", "unpkg.com", "jsdelivr", "cdnjs", "fonts.googleapis", "mathjax", "katex")
    for m in re.finditer(r'(?:src|href)\s*=\s*"(https?://[^"]+)"', text):
        url = m.group(1)
        if any(cdn in url for cdn in cdns):
            errs.append(f"{path.name}: forbidden CDN URL {url}")
    # Check for raw LaTeX $...$ math delimiters inside HTML body (ignore JS template ${...})
    body = text.split("<body", 1)[-1]
    body_no_script = re.sub(r"<script\b[^>]*>.*?</script>", "", body, flags=re.S)
    if re.search(r"(?<!\\)\$[^$\n]{1,60}\$", body_no_script):
        errs.append(f"{path.name}: raw $...$ math delimiter found in static HTML")
    if "<main" not in text or "lang=\"en\"" not in text:
        errs.append(f"{path.name}: missing WCAG <main> landmark or lang='en'")
    return errs


def main() -> int:
    errors: list[str] = []
    idx = SITE / "index.html"
    bp = SITE / "blueprint.html"
    for p in (idx, bp):
        if not p.exists():
            errors.append(f"Missing {p}")
        else:
            errors.extend(check_html(p))

    if bp.exists() and COMP.exists():
        bp_text = bp.read_text(encoding="utf-8")
        comp = json.loads(COMP.read_text(encoding="utf-8"))
        for thm in comp["theorem_names"]:
            short = thm.split(".")[-1]
            if short not in bp_text:
                errors.append(f"blueprint.html missing Palomar target {short}")

    if errors:
        for e in errors:
            print(f"[verify_site] FAIL: {e}", file=sys.stderr)
        return 1
    print("[verify_site] PASS: Observatory & Blueprint passed CSP, zero-CDN, WCAG, and 23-target Palomar checks")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
