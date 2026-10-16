# Street Fighter Alpha: progress

What is known of *Street Fighter Alpha: Warriors' Dreams* (Europe 950727)'s memory, and what has been built
on it. Every address here was found by experiment on the running board with the toolkit's own tools
(`docs/FEATURES.md`); nothing is a dump of the game's data, and no game data is written down.

## How each was found

The tools used, in the order they were reached for:

- `--menu FRAME:KEYS` drives the in-game menu with no window: at `FRAME` it opens the menu and presses the
  keys' buttons (`d` down, `a` confirm), and can write the menu as a picture (`FRAME:KEYS:shot.png`). The
  menu's rows this port has are Save state, Load state, Slot, *Game*, *Display*, Speed, Sound, **Insert
  coin**, *Player 2 joins*, Test menu, Reset, Quit game, Resume — "Insert coin" is the eighth row, seven
  `d`s and an `a`, which is how a coin goes in without a hand.
- `--dump-ram FRAME:FILE` writes the 64 KiB of work RAM after a frame; `--poke ADDR=BYTE` writes a byte
  every frame (a guess, to be checked); `--trace LOW-HIGH:FILE` appends a stretch of work RAM after every
  frame; `--shot-every N:PFX` writes pictures of the board.
- `cps2recomp/tools/ramfind.py` lists the addresses that held a known value in each of several dumps;
  `cps2recomp/tools/tracechanges.py` prints a trace where it changes.
- The round's two digits are small in a screenshot and the health bars sit over them, so the pictures were
  cropped and enlarged (a few lines of Python over the port's own PNG writer) rather than read from the
  whole frame.

**Credits.** Work RAM was dumped in the attract show and again after one coin (put in through the menu),
then `ramfind.py` was asked for a byte that was 0 in the control and 1 after the coin: twenty addresses
answered. A `--trace` of the whole of work RAM across the coin frame left five that moved, and a `--poke`
of those five to different values showed `FF81C3` as the one the title reads (`CREDITS : 9`), which fixed
it.

**The clock.** A real match was needed: the attract show's demo fights show a clock but do not run it (two
frames ten apart in a demo both read the same). With free play standing in for the coin, `--auto` starts a
match of its own, and the clock runs there. `--trace` of the whole of work RAM during such a match, then
looking for a byte counting down a step at a time, gave `FF365D` (a BCD byte: `0x99` is "99"), ticking
down about every 52 frames. Holding it with `--poke` did **not** stop the picture, which is what showed
the two digits are drawn from a second byte the game keeps beside it: `FFAE09`, the same count in decimal.
Holding both stopped the clock, which fixed the pair.

**Health.** The same match's trace was searched for a word that steps down when hits land and stays down.
`FF8440` (player 1) and `FF8840` (player 2) answered, 0x400 apart, each beside a second word (`+0x42`) that
drains down a step at a time: the two are the health and what the bars are drawn from. A `--poke` of
player 1's pair to a small value emptied player 1's bar and left player 2's alone, and the other way round,
which fixed which is which and which bar each one is.

## The memory so far

| Address | Size | What | How it was found |
| --- | --- | --- | --- |
| `FF81C3` | byte | **Credits**: the value the title shows as `CREDITS : n`; 0 in the attract show | Dumped work RAM with and without one coin (inserted through the menu), then `ramfind.py`; a `--poke` of 9 made the title read `CREDITS : 9`. This game's coinage is one coin, one credit. |
| `FF365D` | byte (BCD) | **The round's clock**: the board's two digits in BCD (`0x99` is "99"); it steps down about every 52 frames while a round is fought, and is 0 outside one | Drove a real match (free play + `--auto`), then `--trace`d work RAM and looked for a byte that counted down. |
| `FFAE09` | byte | The same clock in decimal: **what the two digits are drawn from** (the picture over 0x2A recovered, say) | Holding `FF365D` alone with `--poke` did not stop the picture; the trace's change frames matched `FFAE09`, and holding both stopped it. `FFAE09` = the decimal of `FF365D`'s BCD. |
| `FF8400` (+`FF8800`) | record | **Player 1 (player 2)'s record**, the two 0x400 apart; each record's word at `+0x2A` points at the other, which is what fixed the pair | Found with the health words below. |
| `FF8440` (+`FF8840`) | word | **Player 1 (player 2) health**: 0x90 at a round's start, steps down as hits land, 0 outside a round | Traced a real match for a word that stepped down on hits; a `--poke` emptied that player's bar and not the other's. |
| `FF8442` (+`FF8842`) | word | The same health again: **what the bars are drawn from**, draining a step at a time | Moves with the health word; poking both to a small value is what showed the bar follows the second one too. |

The health words are 0 outside a round (and in the attract show), which is what the cheats use to tell a
round from everything else.

## Features built on it (`src/`)

| Feature | Category | What it does |
| --- | --- | --- |
| `free_play` | Game (Enhanced) | Holds two credits, so Start works without a coin. It is what the title waits for, so the attract show gives way to it. |
| `no_damage` | Cheats | Puts player 1's health back to the round's full value every frame. |
| `no_damage_2` | Cheats | The same for player 2 (the opponent's, in a one-player game). |
| `infinite_time` | Cheats | Holds the round's clock (both copies) where it stood when the round began, so it never runs out. |
| `one_hit` | Cheats | Leaves the opponent (player 2) a single point of health, so any hit ends the round. |
| `input_display` | Training | What each player holds, and for how long, at their side of the picture. The first training aid: it is the toolkit's `fight::InputHistory` (the notation, the hold counts) fed from the port's own panel bits, so it needed no new address. The game's facing byte is still unknown, so the notation is not yet turned to the player's side. |

Each was checked with no window: `free_play` against the title (a match starts with no coin), `no_damage`
against a running match (the bar stays full and the health word stays at the round's value), `infinite_time`
against the two digits (they stand still), and `one_hit` against the opponent's bar (it opens empty).

## Next

- The **rest of the player record**: positions, facing, and the state that says a move is out are not yet
  picked out of the values that move every frame (the record from `+0x000` to `+0x3FF` is busy with
  animation, positions and the like; `+0xD6` counts up a step a frame, which is a frame counter of the
  record). They are what the training aids (a hit box, the frame data, the dummy's own guarding) are built
  from.
- The **LEVEL / POWER bars** for a `full_gauge` cheat: the value behind each player's bar at the bottom of
  the picture was not among the values that grow over an idle round, so it still wants finding. The word at
  `+0x14` fills and empties while a round is fought and is a candidate.
- A **rewrite of the damage rule** (`docs/READABLE.md`) for a cleaner `one_hit` than holding the health at
  one point — the same next step the other ports have.
