Street Fighter Alpha: Warriors' Dreams - recomp port (Windows x64)
================================================================

A native PC port of Street Fighter Alpha: Warriors' Dreams (Capcom, 1995, CPS-2 board), made
with tmcleroy's cps2recomp (https://github.com/tmcleroy/cps2recomp) by static recompilation.
NOT affiliated with, endorsed by or sponsored by Capcom. Street Fighter Alpha is a trademark
of Capcom Co., Ltd.

NO GAME FILES ARE INCLUDED. You need your own copy of the game: the arcade ROM set "sfa"
(Europe, 950727), from a board you own. This archive cannot help you get one. Other regions
and revisions (sfau, sfar1, sfar2, sfar3, sfaj, ...) do not work and are refused on purpose.


How to play
-----------
1. Double-click sfa-launcher.exe.
2. Choose your ROM set: point the launcher at the folder that holds the set's files, or at
   the set's .zip. It checks every file by CRC-32 before it will run.
3. Set the controls and any features you want, then Play.

In game: Esc or F1 opens the menu (save states, Insert coin, Player 2 joins, Reset, Quit).
P, O and -/= stop, step and slow the game. Everything is remappable in the launcher.


What is in here
---------------
sfa.exe                the game
sfa-launcher.exe       the launcher (keep it beside the game)
SDL3.dll               \
zlib1.dll               >  the runtime libraries the two programs need
libgcc_s_seh-1.dll     /   (keep them all in this folder, beside the .exe files)
libstdc++-6.dll       /
libwinpthread-1.dll  /
licenses/              the licences of the port and of everything shipped with it

Keep the .exe and .dll files together in one folder. Save states, settings and the board's
eprom are kept beside them (or wherever you run the game from).

The port is GPL-3.0; its source, and how it was made, are at
https://github.com/omegakatana92/Street-Fighter-Alpha-Recomp-
You can also build it yourself from that source. To play, you still need your own ROM set.
