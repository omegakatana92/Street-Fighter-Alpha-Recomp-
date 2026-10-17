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

// A player's place in the stage, a word each. +0x10 is across it (larger is further right) and +0x14 is the
// height above the floor: the floor is about 0x28, a jump lifts it (0x7C at a jump's top) and a crouch
// lowers it a little. Found by writing each word with --poke and watching the character move across and up
// the picture (PROGRESS.md).
constexpr uint32_t kPositionX = 0x10, kPositionY = 0x14;

// Which way a player faces, a word: 1 while the opponent is to its right, 0 while to its left. Found by
// writing player 1's X past player 2 and diffing the record, then checking the flag against both records'
// X over a long match (PROGRESS.md).
constexpr uint32_t kFacing = 0x0A;

// What a player is doing, a word: the game's own state, whose values include 0x0002 standing, 0x0004
// crouching, 0x0400 walking, 0x0602 in the air and 0x0A02 attacking. Found by dumping the record at known
// states (PROGRESS.md).
constexpr uint32_t kState = 0x06;

// The LEVEL (POWER) bar at the bottom of the picture, a word: it fills as the round is fought and reads
// 0x90 when the bar shows MAX. Its copy at +0x148 holds the same value. Found by writing each word of the
// record with --poke until the bar filled (PROGRESS.md).
constexpr uint32_t kGauge = 0xBE, kGaugeCopy = 0x148;
constexpr uint16_t kGaugeFull = 0x90;

// The round's clock. The game counts a BCD byte down (0x99 is "99") and keeps beside it the decimal value
// the two digits are drawn from; holding both is what stops the clock. 0 outside a round.
constexpr uint32_t kClockBcd = 0xFF365D, kClockShown = 0xFFAE09;
constexpr uint8_t kClockFull = 0x99; // (BCD: ninety-nine)

} // namespace sfa
