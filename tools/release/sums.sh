#!/bin/sh
# SPDX-License-Identifier: GPL-3.0-only
#
# Rewrite build/release/SHA256SUMS.txt from the archives beside it (the zip, the tarball, the
# AppImage). Run by tools/release/windows.sh and tools/release/linux.sh after they write one.
set -eu
OUT="$(cd "$(dirname "$0")/../.." && pwd)/build/release"
mkdir -p "$OUT"
cd "$OUT"
python3 - <<'PY'
import hashlib, os
names = sorted(n for n in os.listdir(".") if n.endswith((".zip", ".tar.gz", ".AppImage")))
with open("SHA256SUMS.txt", "w", newline="\n") as f:
    for n in names:
        with open(n, "rb") as g:
            f.write("%s  %s\n" % (hashlib.sha256(g.read()).hexdigest(), n))
PY
cat SHA256SUMS.txt
