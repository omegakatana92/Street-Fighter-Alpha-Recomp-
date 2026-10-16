# Third-party notices

Street Fighter Alpha Recomp is licensed **GPL-3.0-only** (see [LICENSE](LICENSE)). It is built with,
and ships code from, other projects. This file lists them and their licences. Nothing here is game
data: the port holds no ROM, no key, no BIOS and no artwork.

## cps2recomp

The toolkit that translates the board's 68000 and Z80 programs to C++ and runs them lives in
[`cps2recomp/`](cps2recomp/) (a copy at `v0.3.0`, made by the toolkit's own `tools/sync-toolkit.sh`).

- **cps2recomp** — Copyright (C) tmcleroy and contributors — **GPL-3.0-only**
  ([source](https://github.com/tmcleroy/cps2recomp), its `LICENSE` is at [`cps2recomp/LICENSE`](cps2recomp/LICENSE)).
- **recomp-common** (`cps2recomp/recomp-common/`) — the in-game menu, the settings rules and the
  launcher the toolkit shares with [satrecomp](https://github.com/tmcleroy/satrecomp) — Copyright (C)
  tmcleroy and contributors — **GPL-3.0-or-later**. Its launcher's look, and the files that make it,
  come from [wiiparty-recomp](https://github.com/arelkair/wiiparty-recomp) by arelkair
  (**GPL-3.0-or-later**).

## The board's cipher (BSD-3-Clause)

The CPS-2 decrypts its program as the 68000 fetches it. The cipher in
[`cps2recomp/machine/cps2crypt.cpp`](cps2recomp/machine/cps2crypt.cpp) is **MAME**'s
(`src/mame/capcom/cps2crypt.cpp`), **BSD-3-Clause**; the cipher itself was worked out by Andreas Naive
and Nicola Salmoria. Only the entry point at the end of the file is the toolkit's. The QSound model
(`cps2recomp/sound/`) follows MAME's as well.

```
Copyright (c) 2003-2025, the MAME project contributors
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

1. Redistributions of source code must retain the above copyright notice, this
   list of conditions and the following disclaimer.

2. Redistributions in binary form must reproduce the above copyright notice,
   this list of conditions and the following disclaimer in the documentation
   and/or other materials provided with the distribution.

3. Neither the name of the copyright holder nor the names of its contributors
   may be used to endorse or promote products derived from this software
   without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
```

## What a release archive carries

A release archive holds the two built programs, so it carries these as well:

| Library | Licence | Where |
| --- | --- | --- |
| **SDL 3** | zlib | linked into the Linux programs (static); `SDL3.dll` on Windows |
| **zlib** | zlib | linked in; `zlib1.dll` on Windows |
| **Dear ImGui** | MIT | the launcher (its interface) |
| **Inter** | SIL OFL 1.1 | the launcher (the font, compiled in) |
| **GCC / MinGW-w64 runtime** | GPL-3.0 with the GCC Runtime Library Exception | `libstdc++-6.dll`, `libgcc_s_seh-1.dll`, `libwinpthread-1.dll` on Windows |

The full texts of SDL 3, zlib, Dear ImGui, the Inter font and the MinGW-w64/GCC runtimes sit in the
`licenses/` folder of the Windows archive; the Linux archive carries this file and `LICENSE`.

```
SDL 3 — Copyright (C) 1997-2025 Sam Lantinga <slouken@libsdl.org> — zlib licence
Dear ImGui — Copyright (c) 2014-2025 Omar Cornut — MIT licence
Inter — Copyright (c) 2016 The Inter Project Authors — SIL Open Font License 1.1
```

## The game

*Street Fighter Alpha: Warriors' Dreams* is a trademark of **Capcom Co., Ltd.** This port is not
affiliated with, endorsed by or sponsored by Capcom. It contains no part of the game: the player
brings their own ROM set, which is only read, never changed.
