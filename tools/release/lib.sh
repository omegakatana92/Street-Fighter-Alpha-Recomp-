#!/bin/sh
# SPDX-License-Identifier: GPL-3.0-only
#
# Shared by the Linux release script (sourced, not run). It builds SDL 3 as a static library from a
# checksum-checked source, then the game and the launcher against it, so the programs need only the
# system's usual X11/Wayland, sound and zlib libraries.
#
# The game's translated code is the one in work/<game>/gen, made by `make` (and `make explore`) from
# the builder's own ROM set. A release therefore holds the game's translated program, and has to be
# built on a machine that has a ROM set: CI, which has none, never builds a release.
#
# Build it on an OLD base: the programs take glibc from the machine that runs them, so the older the
# glibc this is built against, the more machines can run the result.
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
GAME="${GAME:-sfa}"
VERSION="${VERSION:-$(cat "$ROOT/VERSION" 2>/dev/null || echo 0.1.0)}"
OUT="$ROOT/build/release"
DEPS="$ROOT/build/deps"
SDL_VERSION=3.4.16
SDL_SHA256=7322236cd12090c3eb40b9728be4d49c76f66ad17d04369584d4ecad5cf77c68
mkdir -p "$OUT" "$DEPS"

cfg() { (cd "$ROOT" && python3 cps2recomp/tools/gamecfg.py "$1" "$GAME"); }

# SDL 3's source, checked against its published checksum: $DEPS/SDL3-$SDL_VERSION
sdl_source() {
    if [ ! -d "$DEPS/SDL3-$SDL_VERSION/src" ]; then
        curl -fsSL -o "$DEPS/SDL3-$SDL_VERSION.tar.gz" \
            "https://github.com/libsdl-org/SDL/releases/download/release-$SDL_VERSION/SDL3-$SDL_VERSION.tar.gz"
        echo "$SDL_SHA256  $DEPS/SDL3-$SDL_VERSION.tar.gz" | sha256sum -c - >/dev/null
        tar -xzf "$DEPS/SDL3-$SDL_VERSION.tar.gz" -C "$DEPS"
    fi
}

# SDL 3 as a static library in $DEPS/sdl-linux
sdl_static() {
    if [ ! -f "$DEPS/sdl-linux/lib/cmake/SDL3/SDL3Config.cmake" ]; then
        sdl_source
        cmake -S "$DEPS/SDL3-$SDL_VERSION" -B "$DEPS/sdl-linux-build" -G Ninja -DCMAKE_BUILD_TYPE=Release \
            -DSDL_SHARED=OFF -DSDL_STATIC=ON -DSDL_TEST_LIBRARY=OFF \
            -DCMAKE_INSTALL_PREFIX="$DEPS/sdl-linux" >/dev/null
        cmake --build "$DEPS/sdl-linux-build" --target install >/dev/null
    fi
}

# The game and the launcher, in $1 (the same CMake settings the Makefile uses)
build_programs() {
    build="$1"
    generated="$ROOT/work/$GAME"
    if ! ls "$generated"/gen/native_*.cpp >/dev/null 2>&1; then
        echo "error: no translated code in $generated/gen: run 'make' and 'make explore' with your ROM set first" >&2
        exit 1
    fi
    sdl_static
    cmake -S "$ROOT/cps2recomp" -B "$build/game" -G Ninja -DCMAKE_BUILD_TYPE=Release -DGAME="$GAME" \
        -DGAME_DIR="$ROOT/games/$GAME" -DWORK_DIR="$generated" \
        -DCMAKE_PREFIX_PATH="$DEPS/sdl-linux" -DCMAKE_EXE_LINKER_FLAGS="-static-libstdc++ -static-libgcc" >/dev/null
    cmake --build "$build/game" --target "$GAME"
    cmake -S "$ROOT/cps2recomp/launcher" -B "$build/launcher" -G Ninja -DCMAKE_BUILD_TYPE=Release \
        -DGAME_NAME="$(cfg name)" -DGAME_EXE="$GAME" -DAPP_ID="$(cfg app_id)" \
        -DHOME_ENV="$(echo "$GAME" | tr a-z A-Z)_HOME" -DDISCLAIMER="$(cfg disclaimer)" \
        -DROM_SET="$(cfg rom_set)" -DROM_PARENT="$(cfg rom_parent)" -DROM_NAME="$(cfg rom_name)" \
        -DROM_PROGRAM="$(cfg program)" -DROM_GRAPHICS="$(cfg graphics)" -DROM_SOUND_PROGRAM="$(cfg sound_program)" \
        -DROM_SAMPLES="$(cfg samples)" -DROM_KEY="$(cfg key)" -DDISPLAY_SWITCHES="$(cfg display)" \
        -DCMAKE_PREFIX_PATH="$DEPS/sdl-linux" -DCMAKE_EXE_LINKER_FLAGS="-static-libstdc++ -static-libgcc" >/dev/null
    cmake --build "$build/launcher"
}
