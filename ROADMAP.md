# Street Fighter Alpha — features and roadmap

Where this port stands against a finished one, and what each missing piece needs. The reference is the
toolkit's own complete example, [vampire-savior-recomp](https://github.com/tmcleroy/vampire-savior-recomp)
(`games/vampire_savior/src/`), and the toolkit's documents `docs/FEATURES.md` and `docs/FIGHT.md`.

Everything below is an **optional feature**: with every feature off, the port must run exactly as the
board does. Nothing from the game (no ROM, no RAM dump, no ripped art/text) may ever be committed — each
thing found is recorded in `PROGRESS.md` as *how* it was found (a RAM diff, a write watch, a trace),
never as the data itself.

## What works today

From the toolkit, with no game work:

- The **launcher**: chooses the ROM set, checks every file by CRC-32, sets the controls, Play.
- The **in-game menu** (Esc, `F1`, a stick's click, or Start+Select): save states (9 slots), Reset,
  Insert coin, Player 2 joins, Quit game.
- **Stop, step, slow** (P, O, `-`/`=`).
- **Run-ahead** and the **Display** options (scaling, picture shape, window size, full screen).
- Every key and button **remappable**, for each player.

Built on the game's own memory (`games/sfa/src/`):

- `free_play` (Enhanced) — holds two credits, so Start works with no coin.
- `no_damage`, `no_damage_2` — a player's health is put back to the round's full value every frame.
- `infinite_time` — the round's clock (both of the game's copies) stands still.
- `one_hit` — the opponent is left a single point of health.
- `input_display` (Training) — what each player holds, and for how long, at their side of the picture.

`--list-features` shows these with the toolkit's.

## What a finished port adds (this is the work)

### 0. Foundation — know the game's memory

Partly done: the credits, the round's clock and the two players' records (health, and a frame counter)
are found and named in `games/sfa/src/sfa.h`. What is still wanted is the rest of the player record —
positions, facing, and the state that says a move is out — which is what the training aids are built
from. The record from `+0x000` to `+0x3FF` is busy with values that move every frame; picking them out
is the next job.

How the toolkit finds these (all documented in `docs/FEATURES.md`):

- `--dump-ram F:FILE` + `tools/ramfind.py DUMP=VALUE ...` — addresses that held a known value across
  several dumps (this is how the credits were found).
- `--trace LOW-HIGH:FILE` with a run that does known things at known frames (this is how the clock, the
  health and the frame counter were found).
- `--watch LOW[-HIGH]` — every write to an address and the instruction that made it, read against
  `work/sfa/program.lst`.
- `--poke ADDR=BYTE,...` to try a guess; `--menu FRAME:KEYS` to press the menu's own rows (this is how
  a coin goes in with no hand); `--shot-every N:PFX` to see a run.

### 1. The Features page (the game's own switches)

Mostly done; the quick wins below are the ones left.

| Feature | Kind | Needs |
| --- | --- | --- |
| `full_gauge` (the POWER bars) | on/off | the value behind each player's bar at the bottom of the picture |
| `infinite_time` as a choice of minutes | choice | the round's clock word (found) and the round state |
| Board/operator settings (difficulty, round time, free play) | choices | reading the EEPROM's operator settings |
| "The game's own test menu" | command | a routine address to jump to |

### 2. Training mode (the headline feature)

| Piece | What it adds | Needs |
| --- | --- | --- |
| Input display (done) | what the stick holds, and for how long | the player's facing, so the notation can be turned to the player's side |
| Frame data | startup, active, recovery, and the advantage after a hit | the state that says a move is out, per player |
| Combo readout | hits, damage, and what of it comes back | the damage rule (a rewrite) |
| The dummy (player 2) | stand, crouch, jump, guard, record and replay | the game's idea of a round and of guarding |
| Hit boxes | the players' and projectiles' boxes, drawn on the picture | the box tables and the camera's place |

The toolkit's `fight/` parts (`fight/fight.h`) give all of these once the game's own state is known; the
input display is the first one and needs nothing new.

### 3. Alternative modes

Each is a command with a page of its own:

| Mode | What it adds | Needs |
| --- | --- | --- |
| Attract watcher | the game's own show on a loop, no coin | the credit word (found) held at zero |
| Endless | a game that never ends | the round/match state |
| Two-machine link | not possible (the board's link hardware is a separate build) | — |

### 4. Widescreen

A switch on the launcher's first page, off in every preset (it can change how the game plays). The field
is shown in 16:9, 512 columns where the board's 384, at the same height and scale — a third more of the
field (nothing is stretched). Needs rewrites of the camera and the background scrollers, and the objects
that must be kept while they are in the wide picture. The toolkit's `widescreen.cpp` in Vampire Savior is
the example.

### 5. Readable rewrites (correctness, and what the above builds on)

Rewrite the game's key routines by hand as named C++ (`docs/READABLE.md`): the players' movement and
collision, damage, throws, and the round's advance. Vampire Savior has 123 routines rewritten; each is
checked call by call with `make check-rewrites`. This is what makes a clean `one_hit`, the training mode
and the widescreen possible, and it is the part most worth doing carefully.

## Recommended order

1. **The rest of the player record** — positions, facing, the move state; everything else builds on it.
2. **`full_gauge` and the operator settings** — small, fills out the Features page.
3. **Training mode** — the frame data, the combo readout, the dummy and the hit boxes, on the toolkit's
   `fight/` parts.
4. **Readable rewrites** — needed by 3 and 5, and correctness.
5. **Widescreen.**
6. **Alternative modes.**

**Done so far:** free play, the cheats and the input display (`games/sfa/src/`); the credits, the clock
and the players' health named in `sfa.h` and recorded in `PROGRESS.md`.

## Before uploading: a checklist

- [x] `README.md` states the exact ROM set (`sfa`, Europe 950727) and that **only that revision** works,
      with the Capcom disclaimer.
- [x] `rom/`, `build/`, `work/` are ignored and **absent** from the repository; no game data, keys or dumps
      anywhere (`.github/workflows/check.yml` fails a push that tracks one); no screenshots.
- [x] `PROGRESS.md` records how each finding was made (a RAM diff, a watch, a trace), not the data.
- [x] `make check`, `make check-toolkit`, `make check-common` all pass (the CI runs the last two).
- [x] `LICENSE` (GPL-3.0-only) and `THIRD_PARTY_NOTICES.md` (the cipher is MAME's, BSD-3-Clause); the
      release archives carry them and the licences of what they ship.
- [x] Repo description set (see README's title line / the About field).
- [x] First commit made; the repository builds from a fresh clone with the player's own ROM set
      (`make`, `make explore`, `make launcher`). The first release, `v0.1.0-beta.1`, is up.
