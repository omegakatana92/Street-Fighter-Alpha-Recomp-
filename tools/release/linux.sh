#!/bin/sh
# SPDX-License-Identifier: GPL-3.0-only
#
# The Linux x86_64 release (Steam Deck and other x86_64 Linux):
#
#   build/release/Street-Fighter-Alpha-linux-x86_64.tar.gz    the port, self-contained
#   build/release/Street-Fighter-Alpha-linux-x86_64.AppImage  the same port, as an AppImage
#
# RUN THIS ON x86_64 LINUX, WHERE YOUR ROM SET IS: it builds the game's translated code, so releases
# are made by hand and never by CI (see tools/release/README.md). An old base is best: the programs
# take glibc from the machine that runs them, and Ubuntu 22.04 (glibc 2.35) reaches SteamOS 3.5 and
# everything since.
#
#   make && make explore && make launcher    # with rom/ in place
#   tools/release/linux.sh
#
# It needs a compiler, cmake, ninja, make, curl, python3, and the development packages SDL 3 is
# built against (Ubuntu 22.04 and 24.04):
#   sudo apt install build-essential cmake ninja-build python3 curl zlib1g-dev \
#     libx11-dev libxext-dev libxrandr-dev libxcursor-dev libxi-dev libxss-dev libxtst-dev \
#     libxkbcommon-dev libwayland-dev wayland-protocols libdecor-0-dev libegl-dev libgl-dev \
#     libpulse-dev libasound2-dev libudev-dev libdbus-1-dev libpipewire-0.3-dev
set -eu
. "$(dirname "$0")/lib.sh"
cd "$ROOT"
NAME=Street-Fighter-Alpha
BUILD="$ROOT/build/release-linux"
STAGE="$BUILD/stage/$NAME"

build_programs "$BUILD"

# 1. The tarball: the two programs, the README and the licence.
rm -rf "$BUILD/stage"
mkdir -p "$STAGE/licenses"
cp "$BUILD/game/$GAME" "$BUILD/launcher/$GAME-launcher" "$STAGE/"
cp "$ROOT/README.md" "$STAGE/README.md"
cp "$ROOT/LICENSE" "$STAGE/LICENSE"
cp "$ROOT/THIRD_PARTY_NOTICES.md" "$STAGE/THIRD_PARTY_NOTICES.md"
cp "$ROOT/tools/release/licenses/"*.txt "$STAGE/licenses/"
strip "$STAGE/$GAME" "$STAGE/$GAME-launcher" 2>/dev/null || true

rm -f "$OUT/$NAME-linux-x86_64.tar.gz"
tar -czf "$OUT/$NAME-linux-x86_64.tar.gz" -C "$BUILD/stage" "$NAME"
echo "wrote $OUT/$NAME-linux-x86_64.tar.gz"

# 2. The AppImage: an AppDir with the programs, an icon, a desktop entry and an AppRun; the
#    libraries they need gathered by linuxdeploy; the archive packed by its appimage plugin.
APPDIR="$BUILD/$NAME.AppDir"
rm -rf "$APPDIR"
mkdir -p "$APPDIR/usr/bin" \
         "$APPDIR/usr/share/applications" \
         "$APPDIR/usr/share/icons/hicolor/256x256/apps"
cp "$BUILD/game/$GAME" "$BUILD/launcher/$GAME-launcher" "$APPDIR/usr/bin/"
cp "$ROOT/tools/release/$GAME.png" "$APPDIR/$GAME.png"
cp "$ROOT/tools/release/$GAME.png" "$APPDIR/usr/share/icons/hicolor/256x256/apps/$GAME.png"
mkdir -p "$APPDIR/usr/share/licenses/$NAME"
cp "$ROOT/LICENSE" "$ROOT/THIRD_PARTY_NOTICES.md" "$APPDIR/usr/share/licenses/$NAME/"
cp "$ROOT/tools/release/licenses/"*.txt "$APPDIR/usr/share/licenses/$NAME/"

cat > "$APPDIR/AppRun" <<'EOF'
#!/bin/sh
HERE="$(dirname "$(readlink -f "$0")")"
exec "$HERE/usr/bin/sfa-launcher" "$@"
EOF
chmod +x "$APPDIR/AppRun"

cat > "$APPDIR/usr/share/applications/$GAME.desktop" <<EOF
[Desktop Entry]
Type=Application
Name=Street Fighter Alpha: Warriors' Dreams
Comment=Native recomp port (needs your own sfa ROM set)
Exec=$GAME-launcher
Icon=$GAME
Categories=Game;ArcadeGame;
Terminal=false
EOF

TOOLS="$BUILD/tools"
mkdir -p "$TOOLS"
[ -x "$TOOLS/linuxdeploy" ] || curl -fsSL -o "$TOOLS/linuxdeploy" \
    https://github.com/linuxdeploy/linuxdeploy/releases/download/continuous/linuxdeploy-x86_64.AppImage
[ -x "$TOOLS/linuxdeploy-plugin-appimage" ] || curl -fsSL -o "$TOOLS/linuxdeploy-plugin-appimage" \
    https://github.com/linuxdeploy/linuxdeploy-plugin-appimage/releases/download/continuous/linuxdeploy-plugin-appimage-x86_64.AppImage
chmod +x "$TOOLS/linuxdeploy" "$TOOLS/linuxdeploy-plugin-appimage"

# (linuxdeploy and its plugin are themselves AppImages: extract and run, so no FUSE is needed; the
# plugin is found on PATH, so the tools folder goes there)
export APPIMAGE_EXTRACT_AND_RUN=1
export LINUXDEPLOY_OUTPUT_VERSION="$VERSION"
export PATH="$TOOLS:$PATH"
"$TOOLS/linuxdeploy" --appdir "$APPDIR" \
    --executable "$APPDIR/usr/bin/$GAME" \
    --executable "$APPDIR/usr/bin/$GAME-launcher" \
    --desktop-file "$APPDIR/usr/share/applications/$GAME.desktop" \
    --icon-file "$APPDIR/$GAME.png" \
    --output appimage

rm -f "$OUT/$NAME-linux-x86_64.AppImage"
for a in "$ROOT"/*.AppImage; do
    [ -f "$a" ] && mv "$a" "$OUT/$NAME-linux-x86_64.AppImage"
done
[ -f "$OUT/$NAME-linux-x86_64.AppImage" ] || { echo "error: no AppImage was written" >&2; exit 1; }
echo "wrote $OUT/$NAME-linux-x86_64.AppImage"

"$ROOT/tools/release/sums.sh"
