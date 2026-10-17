// SPDX-License-Identifier: GPL-3.0-only
//
// Street Fighter Alpha: the training aids, put together from the toolkit's fight/ parts (fight/fight.h).
// The input display needs only what the port read off the panel and the game's facing byte, so it is the
// first one; the others (frame data, the combo readout, the dummy, the hit boxes) wait on more of the
// game's own memory being known: the player records are found (sfa.h), with their positions, facing and
// state picked out, but the state's values are not yet all told apart (PROGRESS.md).
#include "sfa.h"

#include "fight.h"
#include "machine.h"
#include "state.h"

namespace cps2recomp {

namespace {
    using namespace sfa;

    fight::InputHistory g_inputs;

    // Which way a player faces: the game's own byte (sfa.h), read as "the opponent is to its right". It is
    // only meaningful while a round is fought (outside one the record holds 0), so a player not in a round
    // is taken to face right and the notation is left as it is.
    bool FacingLeft(int n) {
        if (Ram16(Player(0) + kHealth) == 0 && Ram16(Player(1) + kHealth) == 0) {
            return false;
        }
        return Ram16(Player(n) + kFacing) == 0;
    }

    void ReadInputs(Machine &machine) {
        for (int n = 0; n < 2; n++) {
            g_inputs.Push(n, machine.players[n], FacingLeft(n));
        }
    }
} // namespace

void TrainingBeforeFrame(Machine &machine) {
    ReadInputs(machine);
}

void TrainingFrame(Machine &) {
    std::vector<HudLine> lines;
    if (FeatureOn("input_display")) {
        g_inputs.Hud(0, lines);
        g_inputs.Hud(1, lines);
    }
    SetHud(lines);
}

void TrainingState(Archive &ar) {
    // (fight::InputHistory's own frame counts are not part of the save state: a load starts the display over)
    if (!ar.Saving()) {
        g_inputs.Clear();
    }
}

void RegisterTraining() {
    Game &game = TheGame();
    game.features.push_back({"input_display", "Training", "Input display",
                             "What each player holds, and for how long, at their side of the picture."});
    TrainingAids({"input_display"});
}

} // namespace cps2recomp
