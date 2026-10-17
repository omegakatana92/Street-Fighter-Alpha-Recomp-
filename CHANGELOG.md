# Street Fighter Alpha Recomp — changelog

## 0.1.0-beta.2

- `full_gauge` (Cheats): both players' LEVEL (POWER) bars are held full, so a super is always ready.
- `input_display` (Training) now turns its notation to the player's own side, using the game's facing byte.
- The rest of the player record is named: positions (`+0x10` across, `+0x14` up), facing (`+0x0A`), the
  state word (`+0x06`) and the LEVEL bar's value (`+0xBE`). See `games/sfa/PROGRESS.md`.

## 0.1.0-beta.1

First build. The 68000 and Z80 programs of *Street Fighter Alpha: Warriors' Dreams* (Europe 950727)
are translated to C++ ahead of time and run on cps2recomp's own machine. The launcher, the in-game
menu, save states, run-ahead, the display options and every control are remappable. The game's own
features (free play, cheats, the training mode) are being added; see `games/sfa/PROGRESS.md` and
[ROADMAP.md](ROADMAP.md).
