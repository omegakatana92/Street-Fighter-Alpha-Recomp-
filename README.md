# Street Fighter Alpha: Warriors' Dreams — Recomp

A native PC port of **Street Fighter Alpha: Warriors' Dreams**, the 1995 Capcom arcade
fighting game (the first *Alpha*, on the CP System II board). Its 68000 and Z80 programs are
translated ahead of time into C++ by [cps2recomp](https://github.com/tmcleroy/cps2recomp),
and run on a small machine written for it — no emulator, and no game data in this repository.

This is a work in progress.

The port reads your own **Street Fighter Alpha** ROM set (the MAME set `sfa`, Europe 950727) —
nothing else is needed, and the set's key is used on the fly, as the board does.

Not affiliated with, endorsed by or sponsored by Capcom. Street Fighter Alpha is a trademark of
Capcom Co., Ltd.

## Features

With every feature off the port runs exactly as the board does. From the toolkit (no game-specific
work):

- The **launcher**: choose the ROM set (checked file by file by CRC-32), set the controls, Play.
- The **in-game menu** (Esc or `F1`; a stick's click, or Start+Select): save states (nine slots),
  Reset, Insert coin, Player 2 joins, Quit game.
- **Stop, step, slow** (`P`, `O`, `-`/`=`).
- **Run-ahead** and the **Display** options (scaling, picture shape, window size, full screen).
- Every key and button **remappable**, for each player.

The game's own features (`games/sfa/src/`), from addresses found on the running board and recorded
in [games/sfa/PROGRESS.md](games/sfa/PROGRESS.md):

| Feature | Category | What it does |
| --- | --- | --- |
| Free play | Game | Start works without a coin. |
| No damage | Cheats | Player 1's health does not go down. |
| No damage, player 2 | Cheats | The same for player 2 (the opponent's, in a one-player game). |
| Infinite time | Cheats | The round's clock stands still. |
| One-hit knockouts | Cheats | The opponent goes down with the first hit. |
| Input display | Training | What each player holds, and for how long, at their side of the picture. |

`--list-features` prints the whole list. More is planned; see [ROADMAP.md](ROADMAP.md). Ready-made
builds for Windows, Linux and the Steam Deck go on the [Releases](../../releases) page.

## Layout

| Path | What |
| --- | --- |
| `cps2recomp/` | A copy of the toolkit (`v0.3.0`), made by its `tools/sync-toolkit.sh`. Never change it here. |
| `games/sfa/game.cfg` | The ROM set's files and CRC-32s, the launcher's words, and the game's features. |
| `games/sfa/src/` | The game's own C++: the optional features on top of the board. |
| `games/sfa/PROGRESS.md` | The game's memory as it is found, and how each address was found. |
| `ROADMAP.md` | The features still to build and what each needs. |
| `rom/` | Your ROM set: a folder of its files or the set's zip. Not committed. |
| `build/`, `work/` | Build output and generated code. Not committed. |

## Prerequisites (MSYS2, MinGW64)

Run all commands from an **MSYS2 MinGW64** shell (so `gcc`/`g++`, SDL3 and zlib are found). Install
what is missing once:

```sh
pacman -S --needed base-devel make git diffutils \
  mingw-w64-x86_64-toolchain mingw-w64-x86_64-cmake mingw-w64-x86_64-ninja \
  mingw-w64-x86_64-SDL3 mingw-w64-x86_64-zlib
```

Python 3 comes with MSYS2. CMake must be on `PATH` (`which cmake` must succeed); the MinGW64 package
above puts it in `/mingw64/bin`. `make check` also needs `git` (the repository must be a git working
tree, since `check-common` asks git for the top level) and `diffutils` (for `cmp`).

On Linux (for the AppImage and the Steam Deck build), install a compiler, cmake, ninja, python3 and
SDL 3's build dependencies; `tools/release/linux.sh` lists the packages for Ubuntu.

## The ROM set

`ROM` points at a folder holding the set's files or at the set's zip. The default is `rom`, so put the
set's zip at `rom/sfa.zip` (or the loose files in `rom/`). Files inside a zip are found by CRC-32,
whatever they are named, so they may sit in a subfolder. The set is only read, never changed.

The set this port is made from is MAME's `sfa` (Europe 950727); `games/sfa/game.cfg` lists its files
and checksums, and `games/sfa/PROGRESS.md` says how it was told apart from the other revisions.
**Only this revision is accepted**: the port is translated from its program, and the game's features
use addresses found in it. The clones (`sfau`, `sfar1`, `sfar2`, `sfar3`, `sfaj`) are built from the
same program but are not accepted here.

## Building

```sh
make            # translate the game's code to C++ and link build/sfa/sfa(.exe)
make launcher   # build the launcher: build/sfa/sfa-launcher(.exe)
```

`make` reads the board's program out of the ROM set (above) and translates it, so the set must be in
place first. A fresh tree also needs `make explore` once, because it starts out knowing almost none of
the game's code:

```sh
make explore    # find the game's code by made-up play, in rounds (once, about ten minutes)
make            # translate again, now that the code is known
```

`make explore` plays the game headless with made-up input across several runs, records every place the
code was reached by a computed jump, and translates what it found before the next round. Its progress
is in the final run's log line, `instructions had no translation` — as low as possible is what you
want.

## Running it

The build makes two programs in `build/sfa/`: the game, `sfa.exe`, and the launcher,
`sfa-launcher.exe`. Keep them beside each other.

- **The launcher** is the way in for a player: choose the ROM set (every file checked by CRC-32), set
  the controls, choose features, Play.
- **Double-clicking `sfa.exe`** starts the launcher beside it — straight into the game if a ROM set
  was chosen before, otherwise at the launcher's first page.
- **From a shell:** `make run` runs the port windowed, with `rom/` and the settings file the Makefile
  names; pass options through with `ARGS=`, e.g. `make run ARGS=--fullscreen`. A game is started with a
  coin (Insert coin in the menu) or with Free play.

Feature choices come from `work/sfa/settings.ini`; the eeprom and the save states (`state0.bin` …) sit
beside it. `--help` lists every option (`--headless`, `--frames`, `--movie`, `--poke`, `--trace`,
`--dump-ram`, `--list-features`, `--cpu`, `--sound`, …).

**On Windows the two programs need the MinGW runtime beside them** — `SDL3.dll`, `zlib1.dll`,
`libstdc++-6.dll`, `libgcc_s_seh-1.dll`, `libwinpthread-1.dll`. `make` copies them into `build/sfa/`
(the `deps` target), so the folder can be double-clicked or run from any shell. Starting the programs
from an **MSYS2 MinGW64** shell works as well, because that shell has `/mingw64/bin` on `PATH`.

## Troubleshooting

- **"SDL3.dll was not found"**, or **"The procedure entry point … could not be located in the dynamic
  link library"** — the runtime DLLs are missing from beside the programs, or an older one from another
  toolchain is being picked up. Run `make deps`, which copies the ones this build needs out of
  `/mingw64/bin`; or launch from an MSYS2 MinGW64 shell.
- **`cmake: command not found`** — install `mingw-w64-x86_64-cmake` (Prerequisites); it lands in
  `/mingw64/bin`, which the MinGW64 shell has on `PATH`.
- **The launcher refuses the ROM set** — it checks every file by CRC-32. This port wants MAME's `sfa`
  (Europe 950727); other regions and revisions are refused on purpose.
- **Slow, or the log reports instructions left to the interpreter** — run `make explore` once, then
  `make` again.
- **No sound** — the sound program runs like the rest of the game; check the launcher's Sound row and
  that the set has its `sound_program` files (`sfz.01`, `sfz.02`).

## Checking

```sh
make check          # translated code against the interpreter, by state hash; two runs alike
make check-blocks   # every translated block beside the interpreter (registers, cycles, writes)
make check-toolkit  # cps2recomp/ is what its tools/sync-toolkit.sh recorded
make check-common   # recomp-common/ is what its tools/sync-common.sh recorded
```

See `cps2recomp/build.mk` for the full list of targets.

## Licence

GPL-3.0-only; see [LICENSE](LICENSE) and [THIRD_PARTY_NOTICES.md](THIRD_PARTY_NOTICES.md).
