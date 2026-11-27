#!/usr/bin/env python3
# SPDX-License-Identifier: Apache-2.0
# Copyright (c) 2026 Alexander Stephen Donahue
"""Strict live citation, metadata-fidelity, and retraction auditor for paper/references.bib.

Parses every BibTeX entry and verifies live against Crossref (for DOIs) and the
arXiv Atom API (for eprints):
  1. HTTP 200 and valid structured JSON / XML response (no silent error swallowing).
  2. Title word-overlap >= 55% against live upstream metadata (catches hallucinated or
     wrong-paper DOIs/arXiv IDs).
  3. First-author surname match against live upstream authors.
  4. Crossref retraction/withdrawal screening across BOTH `updated-by` and `update-to`.
  5. arXiv Atom `<entry>` presence check (rejects HTTP 200 empty-feed nonexistent IDs).
"""

from __future__ import annotations

import json
import re
import sys
import unicodedata
import urllib.error
import urllib.request
import xml.etree.ElementTree as ET
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
BIB_FILE = ROOT / "paper" / "references.bib"
UA = "weyl-magic-citation-checker/1.1 (mailto:0_0@0thernes.art)"
STOPWORDS = {"a", "an", "and", "by", "for", "from", "in", "of", "on", "the", "to", "with"}


def norm_tokens(text: str) -> set[str]:
    clean = re.sub(r"\\[a-zA-Z'\"`^~.=]+\{([^}]*)\}", r"\1", text)
    clean = re.sub(r"[{}\\]", "", clean)
    clean = unicodedata.normalize("NFKD", clean).encode("ascii", "ignore").decode("ascii").lower()
    words = re.findall(r"[a-z0-9]+", clean)
    return {w for w in words if len(w) >= 2 and w not in STOPWORDS}


def first_surname(author_field: str) -> str:
    first = author_field.split(" and ")[0].strip()
    if "," in first:
        raw = first.split(",", 1)[0].strip()
    else:
        raw = first.split()[-1].strip()
    toks = norm_tokens(raw)
    if toks:
        return sorted(toks, key=len)[-1]
    return re.sub(r"[^a-z]", "", raw.lower())


def parse_bib(text: str) -> list[dict[str, str]]:
    entries: list[dict[str, str]] = []
    chunks = re.split(r"\n(?=@\w+\{)", text.strip())
    for chunk in chunks:
        m_head = re.match(r"@(\w+)\{([^,]+),", chunk.strip())
        if not m_head:
            continue
        rec: dict[str, str] = {"type": m_head.group(1), "key": m_head.group(2).strip()}
        for m in re.finditer(r"(\w+)\s*=\s*\{((?:[^{}]|\{[^{}]*\})*)\}", chunk):
            rec[m.group(1).lower()] = " ".join(m.group(2).split())
        entries.append(rec)
    return entries


def fetch(url: str) -> bytes:
    req = urllib.request.Request(url, headers={"User-Agent": UA})
    with urllib.request.urlopen(req, timeout=20) as resp:
        if not (200 <= resp.status < 300):
            raise RuntimeError(f"HTTP {resp.status}")
        return resp.read()


def check_doi(entry: dict[str, str]) -> list[str]:
    errs: list[str] = []
    doi = entry["doi"]
    try:
        payload = json.loads(fetch(f"https://api.crossref.org/works/{doi}").decode("utf-8"))
    except (urllib.error.HTTPError, urllib.error.URLError, json.JSONDecodeError, RuntimeError) as exc:
        return [f"DOI {doi} fetch/parse failed: {exc}"]
    msg = payload.get("message", {})
    titles = msg.get("title") or []
    live_title = " ".join(titles)
    bib_toks = norm_tokens(entry.get("title", ""))
    live_toks = norm_tokens(live_title)
    overlap = len(bib_toks & live_toks) / max(1, len(bib_toks))
    if overlap < 0.55:
        errs.append(f"DOI {doi} title mismatch ({overlap:.0%}): bib={entry.get('title')!r} vs live={live_title!r}")

    # Author surname check (allow Springer-style "Not Available" placeholder ONLY when arXiv eprint is also present)
    expected_sur = first_surname(entry.get("author", ""))
    live_authors = " ".join(
        f"{a.get('family', '')} {a.get('given', '')} {a.get('name', '')}" for a in msg.get("author", [])
    )
    placeholder_only = bool(live_authors.strip()) and set(norm_tokens(live_authors)).issubset({"not", "available"})
    if expected_sur and not (placeholder_only and "eprint" in entry):
        if expected_sur not in norm_tokens(live_authors) and expected_sur not in live_authors.lower():
            errs.append(f"DOI {doi} author surname {expected_sur!r} not found in live authors {live_authors!r}")

    # Retraction / concern screening across BOTH updated-by and update-to
    for field in ("updated-by", "update-to"):
        for upd in msg.get(field, []) or []:
            utype = str(upd.get("type", "")).lower()
            ulabel = str(upd.get("label", "")).lower()
            if any(k in utype or k in ulabel for k in ("retract", "withdraw", "concern")):
                errs.append(f"DOI {doi} RETRACTION/CONCERN flag in {field}: {upd}")
    return errs


def check_arxiv(entry: dict[str, str]) -> list[str]:
    errs: list[str] = []
    aid = entry["eprint"]
    try:
        raw = fetch(f"https://export.arxiv.org/api/query?id_list={aid}")
        root = ET.fromstring(raw)
    except (urllib.error.HTTPError, urllib.error.URLError, ET.ParseError, RuntimeError) as exc:
        return [f"arXiv {aid} fetch/parse failed: {exc}"]
    ns = {"a": "http://www.w3.org/2005/Atom"}
    entries = root.findall("a:entry", ns)
    if not entries:
        return [f"arXiv {aid} returned empty Atom feed (non-existent ID)"]
    node = entries[0]
    live_id = (node.findtext("a:id", default="", namespaces=ns) or "").strip()
    live_title = " ".join((node.findtext("a:title", default="", namespaces=ns) or "").split())
    if aid not in live_id or not live_title or live_title.lower() == "error":
        return [f"arXiv {aid} missing valid entry (id={live_id!r}, title={live_title!r})"]

    bib_toks = norm_tokens(entry.get("title", ""))
    live_toks = norm_tokens(live_title)
    overlap = len(bib_toks & live_toks) / max(1, len(bib_toks))
    if overlap < 0.55:
        errs.append(f"arXiv {aid} title mismatch ({overlap:.0%}): bib={entry.get('title')!r} vs live={live_title!r}")

    expected_sur = first_surname(entry.get("author", ""))
    live_authors = " ".join(
        (n.text or "") for n in node.findall("a:author/a:name", ns)
    )
    if expected_sur and expected_sur not in norm_tokens(live_authors) and expected_sur not in live_authors.lower():
        errs.append(f"arXiv {aid} author surname {expected_sur!r} not found in live authors {live_authors!r}")
    return errs


def main() -> int:
    if not BIB_FILE.exists():
        print(f"ERROR: {BIB_FILE} not found", file=sys.stderr)
        return 1
    entries = parse_bib(BIB_FILE.read_text(encoding="utf-8"))
    if not entries:
        print("ERROR: no BibTeX entries parsed", file=sys.stderr)
        return 1

    fails = 0
    doi_count = 0
    arxiv_count = 0
    for entry in entries:
        key = entry["key"]
        errs: list[str] = []
        if "doi" in entry:
            doi_count += 1
            errs.extend(check_doi(entry))
        if "eprint" in entry:
            arxiv_count += 1
            errs.extend(check_arxiv(entry))
        if "doi" not in entry and "eprint" not in entry:
            errs.append("entry has neither DOI nor arXiv eprint identifier")
        if errs:
            fails += len(errs)
            for e in errs:
                print(f"[citation] FAIL {key}: {e}", file=sys.stderr)
        else:
            ids = ", ".join(p for p in (entry.get("doi"), entry.get("eprint")) if p)
            print(f"[citation] PASS {key} ({ids}): title, author, and retraction screen OK")

    print(
        f"[citation] Audited {len(entries)} entries ({doi_count} DOIs + {arxiv_count} arXiv IDs); failures={fails}"
    )
    return 0 if fails == 0 else 1


if __name__ == "__main__":
    raise SystemExit(main())
