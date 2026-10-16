#!/bin/sh
# SPDX-License-Identifier: GPL-3.0-only
#
# The Windows x64 release: build/release/Street-Fighter-Alpha-windows-x64.zip
#
# Run in an MSYS2 MinGW64 shell, after building with your own ROM set. The archive holds the
# game's translated code, which is made from a ROM set, so it is built on a machine that has
# one: CI never builds or holds a release archive.
#
#   make            # translate the game's code (needs rom/)
#   make launcher   # build the launcher
#   tools/release/windows.sh
#
# The zip holds the two programs, the DLLs they need, their licences and a README. It holds no
# ROM set: the player brings their own.
set -eu
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
cd "$ROOT"

GAME=sfa
NAME=Street-Fighter-Alpha
MINGW="${MINGW_PREFIX:-/mingw64}"
B="build/$GAME"
OUT="$ROOT/build/release"
STAGE="$OUT/stage/$NAME"

[ -f "$B/$GAME.exe" ] || { echo "error: $B/$GAME.exe is missing: run 'make' first" >&2; exit 1; }
[ -f "$B/$GAME-launcher.exe" ] || { echo "error: $B/$GAME-launcher.exe is missing: run 'make launcher' first" >&2; exit 1; }

rm -rf "$OUT/stage"
mkdir -p "$STAGE/licenses"
cp "$B/$GAME.exe" "$B/$GAME-launcher.exe" "$STAGE/"
cp "$ROOT/tools/release/README-windows.txt" "$STAGE/README.txt"
for dll in SDL3.dll zlib1.dll libgcc_s_seh-1.dll libstdc++-6.dll libwinpthread-1.dll; do
    cp "$MINGW/bin/$dll" "$STAGE/"
done

cp "$ROOT/LICENSE" "$STAGE/licenses/GPL-3.0.txt"
cp "$ROOT/THIRD_PARTY_NOTICES.md" "$STAGE/licenses/THIRD_PARTY_NOTICES.md"
cp "$ROOT/tools/release/licenses/"*.txt "$STAGE/licenses/"
# The GCC and MinGW-w64 runtimes ship as DLLs; their texts are the ones the packages install.
for pair in "$MINGW/share/licenses/gcc-libs/COPYING.RUNTIME:GCC-runtime.txt" \
            "$MINGW/share/licenses/gcc-libs/COPYING.LIB:GCC-runtime-library.txt" \
            "$MINGW/share/licenses/crt/COPYING.MinGW-w64-runtime.txt:MinGW-w64-runtime.txt" \
            "$MINGW/share/licenses/winpthreads/COPYING:winpthreads.txt"; do
    src="${pair%:*}"; dst="${pair##*:}"
    [ -f "$src" ] && cp "$src" "$STAGE/licenses/$dst"
done

# The programs link against SDL3.dll, zlib1.dll and the MinGW-w64/GCC runtimes (and Windows' own
# libraries); anything else here means the archive is missing a DLL.
if objdump -p "$STAGE"/*.exe | grep -i 'DLL Name' \
   | grep -viE 'SDL3|zlib1|libgcc_s_seh-1|libstdc\+\+-6|libwinpthread-1|KERNEL32|msvcrt|USER32|SHELL32|ADVAPI32|ole32|api-ms-|GDI32|IMM32|WINMM|VERSION|SETUPAPI|OLEAUT32|COMDLG32|WS2_32'; then
    echo "error: a program needs a DLL that is not in the archive" >&2
    exit 1
fi

mkdir -p "$OUT"
rm -f "$OUT/$NAME-windows-x64.zip"
# (the sort and the fixed timestamps keep a rebuild byte-for-byte the same)
python3 - "$STAGE" "$OUT/$NAME-windows-x64.zip" <<'PY'
import os, sys, zipfile
stage, dest = sys.argv[1], sys.argv[2]
root = os.path.dirname(stage)
with zipfile.ZipFile(dest, "w", zipfile.ZIP_DEFLATED) as z:
    for dirpath, dirnames, filenames in os.walk(stage):
        dirnames.sort()
        for name in sorted(filenames):
            full = os.path.join(dirpath, name)
            arc = os.path.relpath(full, root).replace(os.sep, "/")
            info = zipfile.ZipInfo(arc, date_time=(2020, 1, 1, 0, 0, 0))
            info.compress_type = zipfile.ZIP_DEFLATED
            info.external_attr = 0o644 << 16
            with open(full, "rb") as f:
                z.writestr(info, f.read())
PY

"$ROOT/tools/release/sums.sh"

echo "wrote $OUT/$NAME-windows-x64.zip"
