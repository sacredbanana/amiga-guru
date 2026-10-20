# Amiga Guru

A [Claude](https://claude.com) skill for Amiga software development. It turns Claude into a precise librarian and build assistant for AmigaOS 3 (m68k), AmigaOS 4 (PPC), MorphOS (PPC) and other Amiga-like systems.

## What it does

- **Up-to-date API reference**: keeps a local sparse clone of [sacredbanana/AmigaSDK-gcc](https://github.com/sacredbanana/AmigaSDK-gcc) (autodocs and SDK/NDK headers for OS3, OS4 and MorphOS, no binaries) and searches it directly for function signatures, structs, constants and examples. GitHub links accompany every file it cites.
- **Classic books**: recommends the best manual from the [retro-commodore.eu](https://www.retro-commodore.eu/amiga-development/) catalog (ROM Kernel Reference Manuals, Hardware Reference Manual, Intuition Reference Manual, Abacus titles, ARexx...) with direct download links.
- **Real-time 3D graphics**: points to Andrew Tyler's [Amiga Real-Time 3D Graphics](https://amigasourcecodepreservation.gitlab.io/amiga-real-time-3d-graphics) (full book and 68000 sources, CC BY-SA 4.0), Michael Watson's [Frontier: Elite II renderer write-up](http://watsonmw.com/fintro/) and its C source [fe2-intro](https://github.com/watsonmw/fe2-intro) for 3D engines, fixed-point maths, depth sorting and palette tricks.
- **Building and cross-compiling**: verified toolchain settings, Docker images (`sacredbanana/amiga-compiler:m68k-amigaos`, `ppc-amigaos`, `ppc-morphos`), Makefile patterns, native Bebbo GCC setup, and known gotchas such as `-fbaserel` with MUI/BOOPSI and the libnix `errno` link error.

Claude picks the skill up automatically for Amiga library/API questions, requests for book recommendations or download links, and questions about compiling, Makefiles or linker errors for Amiga targets.

## Installation

### Claude Code

Clone the repository into your skills directory:

```bash
# For all your projects
git clone https://github.com/sacredbanana/amiga-guru.git ~/.claude/skills/amiga-guru

# Or for a single project
git clone https://github.com/sacredbanana/amiga-guru.git .claude/skills/amiga-guru
```

### Claude.ai

Zip the repository folder and upload it under **Settings → Capabilities → Skills**.

## Requirements

- `git` and `bash` for the SDK cache (without them the skill falls back to browsing GitHub file by file)
- Network access to GitHub, GitLab, retro-commodore.eu and watsonmw.com
- Docker, optionally, for building Amiga projects with the toolchain images

## Repository layout

| Path | Purpose |
|------|---------|
| `SKILL.md` | The skill itself: instructions, build reference and source-matching rules |
| `scripts/sync-cache.sh` | Creates or updates the AmigaSDK-gcc sparse clone in `cache/amigasdk-gcc` and prints its path |
| `cache/` | Created on first use; git-ignored, never commit it |

To refresh the SDK cache by hand:

```bash
./scripts/sync-cache.sh
```

## License

[MIT](LICENSE) © 2026 Cameron Armstrong (Nightfox)
