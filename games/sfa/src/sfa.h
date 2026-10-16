// SPDX-License-Identifier: GPL-3.0-only
//
// Street Fighter Alpha: Warriors' Dreams (Europe 950727): names for what is known of the game's memory.
// Every address here was found by experiment on the running board with the toolkit's own tools
// (--menu, --dump-ram, --poke, --trace); PROGRESS.md says how each one was found. No game data is written
// down here, only where the game keeps it.
#pragma once

#include "game.h"

#include <cstdint>

namespace sfa {

// The credits the game is holding, a byte: the title shows it as "CREDITS : n", and a coin adds one (this
// game's coinage is one coin, one credit). 0 while the board is in its attract show, and what the title
// waits for before it offers "PRESS 1P OR 2P START".
constexpr uint32_t kCredits = 0xFF81C3;

// A player's record: the two are 0x400 apart, player 1's first (each record's own word at +0x2A points at
// the other one, which is what fixed the pair).
//   +0x40  the health, a word (0x90 at the round's start: what a hit takes bits off)
//   +0x42  the same health again, drawn down a step at a time: what the bars are drawn from
// Both are 0 outside a round, and in the attract show.
constexpr uint32_t kPlayer0 = 0xFF8400, kPlayerStride = 0x400;
constexpr uint32_t kHealth = 0x40, kHealthShown = 0x42;
inline constexpr uint32_t Player(int n) {
    return kPlayer0 + static_cast<uint32_t>(n) * kPlayerStride;
}

// The round's clock. The game counts a BCD byte down (0x99 is "99") and keeps beside it the decimal value
// the two digits are drawn from; holding both is what stops the clock. 0 outside a round.
constexpr uint32_t kClockBcd = 0xFF365D, kClockShown = 0xFFAE09;
constexpr uint8_t kClockFull = 0x99; // (BCD: ninety-nine)

} // namespace sfa
