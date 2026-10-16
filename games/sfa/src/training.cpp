// SPDX-License-Identifier: GPL-3.0-only
//
// Street Fighter Alpha: the training aids, put together from the toolkit's fight/ parts (fight/fight.h).
// The input display needs only what the port read off the panel, so it is the first one; the others (frame
// data, the combo readout, the dummy, the hit boxes) wait on more of the game's own memory being known: the
// player records are found (sfa.h) but their positions, facing and move state are not yet picked out
// (PROGRESS.md).
#include "sfa.h"

#include "fight.h"
#include "machine.h"
#include "state.h"

namespace cps2recomp {

namespace {
    fight::InputHistory g_inputs;

    void ReadInputs(Machine &machine) {
        for (int n = 0; n < 2; n++) {
            // (the game's own facing byte is not known yet, so the notation is not turned to the player's side)
            g_inputs.Push(n, machine.players[n], false);
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
