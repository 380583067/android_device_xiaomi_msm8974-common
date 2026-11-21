#!/usr/bin/env python3

import hashlib
from pathlib import Path
import sys


ORIGINAL_SHA256 = "1359997e3446c5e29746a4ca351ef93d2bc2adb21312fc6846c498ba24cd5001"
PATCHED_SHA256 = "b462759471ce6f9a8917970d6d091649bb5f7707c5a4c8790edd06fe6930f92c"

# RTM_NEWLINK on Cancro exceeds the legacy 1 KiB receive buffer. Raise both
# the allocation limit and the requested buffer size to 16 KiB.
PATCHES = (
    (0x3738, bytes.fromhex("b6 f5 80 6f"), bytes.fromhex("b6 f5 80 4f")),  # cmp.w r6
    (0x5D0A, bytes.fromhex("4f f4 80 60"), bytes.fromhex("4f f4 80 40")),  # mov.w r0
)


def fixup(path):
    data = bytearray(path.read_bytes())
    digest = hashlib.sha256(data).hexdigest()
    if digest == PATCHED_SHA256:
        return
    if digest != ORIGINAL_SHA256:
        print(f"Skipping libnetmgr fixup for unrecognized SHA-256 {digest}", file=sys.stderr)
        return

    for offset, original, replacement in PATCHES:
        end = offset + len(original)
        if data[offset:end] != original:
            raise SystemExit(f"Unexpected libnetmgr instruction at {offset:#x}")
        data[offset:end] = replacement

    if hashlib.sha256(data).hexdigest() != PATCHED_SHA256:
        raise SystemExit("Unexpected libnetmgr fixup output")
    path.write_bytes(data)


if __name__ == "__main__":
    if len(sys.argv) != 2:
        raise SystemExit(f"Usage: {sys.argv[0]} PATH_TO_LIBNETMGR")
    fixup(Path(sys.argv[1]))
