# Making a release

The release archives are built **by hand**, on a machine that has the ROM set: they hold the game's
translated code, so CI never builds or holds one. They land in `build/release/` and are uploaded to
the repository's Releases page by hand:

```sh
make                      # translate the game's code (needs rom/)
make explore              # find the game's code by made-up play (once)
make launcher             # the launcher
tools/release/linux.sh    # build/release/Street-Fighter-Alpha-linux-x86_64.tar.gz + .AppImage
tools/release/windows.sh  # build/release/Street-Fighter-Alpha-windows-x64.zip
gh release create vX.Y.Z build/release/*.zip build/release/*.tar.gz build/release/*.AppImage \
    build/release/SHA256SUMS.txt --title ... --notes ...
```

| Script | Builds | What it holds |
| --- | --- | --- |
| `linux.sh` | `Street-Fighter-Alpha-linux-x86_64.tar.gz` and `.AppImage` | the two programs (SDL 3 linked in), a `README.md`, the licence and `licenses/` |
| `windows.sh` | `Street-Fighter-Alpha-windows-x64.zip` | the two programs, the five DLLs they need, a `README.txt` and `licenses/` |
| `sums.sh` | `SHA256SUMS.txt` | hashes every archive in `build/release/` (run by the others) |

The archives hold **no** ROM set, no key, no BIOS and no game artwork: the player brings their own
set. `windows.sh` also checks every DLL the two programs import against a list of the ones the
archive carries, so an archive cannot go out missing one.

`linux.sh` runs on x86_64 Linux (Ubuntu 24.04 or 22.04): it builds SDL 3 as a static library from a
checksum-checked source and then the port against it, so the programs need only the system's usual
sound, X11/Wayland and zlib libraries. `windows.sh` runs in an **MSYS2 MinGW64** shell on Windows.
