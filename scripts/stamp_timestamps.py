#!/usr/bin/env python3
# SPDX-License-Identifier: Apache-2.0
# Copyright (c) 2026 Alexander Stephen Donahue
"""Obtain RFC 3161 DigiCert TSA (.tsr) and OpenTimestamps (.ots) cryptographic timestamps for MANIFEST.sha256."""

from __future__ import annotations

import hashlib
import subprocess
import sys
import urllib.request
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
MANIFEST = ROOT / "MANIFEST.sha256"
TSR_OUT = ROOT / "MANIFEST.sha256.tsr"
OTS_OUT = ROOT / "MANIFEST.sha256.ots"


def stamp_rfc3161_digicert() -> bool:
    """Create RFC 3161 TimeStampReq via openssl (or minimal ASN.1 DER) and POST to DigiCert TSA."""
    digest = hashlib.sha256(MANIFEST.read_bytes()).digest()
    # Minimal RFC 3161 TimeStampReq (SHA-256 OID 2.16.840.1.101.3.4.2.1, certReq=TRUE)
    # SEQUENCE { INTEGER 1, SEQUENCE { SEQUENCE { OID sha256, NULL }, OCTET STRING digest }, BOOLEAN TRUE }
    sha256_alg = bytes.fromhex("300d06096086480165030402010500")
    msg_imprint = b"\x30" + bytes([len(sha256_alg) + 2 + len(digest)]) + sha256_alg + b"\x04\x20" + digest
    body = b"\x02\x01\x01" + msg_imprint + b"\x01\x01\xff"
    tsq = b"\x30" + bytes([len(body)]) + body

    req = urllib.request.Request(
        "http://timestamp.digicert.com",
        data=tsq,
        headers={"Content-Type": "application/timestamp-query"},
        method="POST",
    )
    try:
        with urllib.request.urlopen(req, timeout=20) as resp:
            tsr = resp.read()
        if len(tsr) < 100 or tsr[0] != 0x30:
            print(f"[timestamp] Unexpected DigiCert TSA response ({len(tsr)} bytes)", file=sys.stderr)
            return False
        TSR_OUT.write_bytes(tsr)
        print(f"[timestamp] Wrote RFC 3161 DigiCert token -> {TSR_OUT.name} ({len(tsr)} bytes)")
        return True
    except Exception as exc:  # noqa: BLE001
        print(f"[timestamp] DigiCert TSA request failed: {exc}", file=sys.stderr)
        return False


def stamp_opentimestamps() -> bool:
    """Submit SHA-256 digest to OpenTimestamps calendar (alice.btc.calendar.opentimestamps.org)."""
    # Try `ots stamp` CLI first if installed; otherwise submit directly to public OTS calendar
    try:
        res = subprocess.run(
            ["ots", "stamp", str(MANIFEST)],
            cwd=str(ROOT),
            capture_output=True,
            text=True,
            timeout=30,
            check=False,
        )
        if res.returncode == 0 and OTS_OUT.exists():
            print(f"[timestamp] Created OpenTimestamps proof via ots CLI -> {OTS_OUT.name}")
            return True
    except FileNotFoundError:
        pass

    digest = hashlib.sha256(MANIFEST.read_bytes()).digest()
    url = "https://a.pool.opentimestamps.org/digest"
    req = urllib.request.Request(
        url,
        data=digest,
        headers={"Content-Type": "application/x-www-form-urlencoded", "Accept": "application/vnd.opentimestamps.v1"},
        method="POST",
    )
    try:
        with urllib.request.urlopen(req, timeout=20) as resp:
            cal_resp = resp.read()
        # Standard OTS v1 header: magic (31 bytes) + version(0x01) + sha256_op(0x08) + digest(32) + cal_resp
        magic = bytes.fromhex("004f70656e54696d657374616d7073000050726f6f6600bf89e2e884e892940108")
        OTS_OUT.write_bytes(magic + digest + cal_resp)
        print(f"[timestamp] Wrote OpenTimestamps proof -> {OTS_OUT.name} ({OTS_OUT.stat().st_size} bytes)")
        return True
    except Exception as exc:  # noqa: BLE001
        print(f"[timestamp] OpenTimestamps calendar submission failed: {exc}", file=sys.stderr)
        return False


def main() -> int:
    if not MANIFEST.exists():
        print("ERROR: MANIFEST.sha256 does not exist yet", file=sys.stderr)
        return 1
    ok_tsr = stamp_rfc3161_digicert()
    ok_ots = stamp_opentimestamps()
    return 0 if (ok_tsr and ok_ots) else 1


if __name__ == "__main__":
    raise SystemExit(main())
