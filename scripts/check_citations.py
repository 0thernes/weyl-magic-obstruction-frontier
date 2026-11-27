#!/usr/bin/env python3
# SPDX-License-Identifier: Apache-2.0
# Copyright (c) 2026 Alexander Stephen Donahue
"""Live HTTP citation verification against arXiv and Crossref APIs for paper/references.bib."""

from __future__ import annotations

import json
import re
import sys
import urllib.error
import urllib.request
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
BIB_FILE = ROOT / "paper" / "references.bib"


def check_url(url: str) -> tuple[bool, str]:
    req = urllib.request.Request(url, headers={"User-Agent": "weyl-magic-citation-checker/1.0"})
    try:
        with urllib.request.urlopen(req, timeout=15) as resp:
            return (200 <= resp.status < 400), f"HTTP {resp.status}"
    except urllib.error.HTTPError as exc:
        return False, f"HTTP {exc.code}"
    except Exception as exc:  # noqa: BLE001
        return False, str(exc)


def main() -> int:
    if not BIB_FILE.exists():
        print(f"ERROR: {BIB_FILE} not found", file=sys.stderr)
        return 1
    text = BIB_FILE.read_text(encoding="utf-8")
    dois = sorted(set(re.findall(r"doi\s*=\s*\{([^}]+)\}", text)))
    arxivs = sorted(set(re.findall(r"eprint\s*=\s*\{([^}]+)\}", text)))
    fails = 0

    for doi in dois:
        ok, status = check_url(f"https://api.crossref.org/works/{doi}")
        print(f"[citation] DOI {doi}: {'OK' if ok else 'FAIL'} ({status})")
        if not ok:
            fails += 1
        else:
            # Verify not retracted in Crossref metadata
            try:
                req = urllib.request.Request(
                    f"https://api.crossref.org/works/{doi}",
                    headers={"User-Agent": "weyl-magic-citation-checker/1.0"},
                )
                with urllib.request.urlopen(req, timeout=15) as resp:
                    payload = json.loads(resp.read().decode("utf-8"))
                    msg = payload.get("message", {})
                    updates = msg.get("update-to", [])
                    for upd in updates:
                        if "retract" in str(upd.get("type", "")).lower():
                            print(f"[citation] ALERT RETRACTED DOI: {doi}", file=sys.stderr)
                            fails += 1
            except Exception:  # noqa: BLE001
                pass

    for aid in arxivs:
        ok, status = check_url(f"https://export.arxiv.org/api/query?id_list={aid}")
        print(f"[citation] arXiv {aid}: {'OK' if ok else 'FAIL'} ({status})")
        if not ok:
            fails += 1

    print(f"[citation] Checked {len(dois)} DOIs + {len(arxivs)} arXiv IDs; failures={fails}")
    return 0 if fails == 0 else 1


if __name__ == "__main__":
    raise SystemExit(main())
