# Amiga Guru

A skill for Amiga software development in the [ChatGPT desktop app](https://learn.chatgpt.com/docs/build-skills), Codex and [Claude](https://claude.com). It gives your assistant a precise library of references and build guidance for AmigaOS 3 (m68k), AmigaOS 4 (PPC), MorphOS (PPC) and other Amiga-like systems.

## What it does

- **Up-to-date API reference**: keeps a local sparse clone of [sacredbanana/AmigaSDK-gcc](https://github.com/sacredbanana/AmigaSDK-gcc) (autodocs and SDK/NDK headers for OS3, OS4 and MorphOS, no binaries) and searches it directly for function signatures, structs, constants and examples. GitHub links accompany every file it cites.
- **Classic books**: recommends the best manual from the [retro-commodore.eu](https://www.retro-commodore.eu/amiga-development/) catalog (ROM Kernel Reference Manuals, Hardware Reference Manual, Intuition Reference Manual, Abacus titles, ARexx...) with direct download links.
- **Real-time 3D graphics**: points to Andrew Tyler's [Amiga Real-Time 3D Graphics](https://amigasourcecodepreservation.gitlab.io/amiga-real-time-3d-graphics) (full book and 68000 sources, CC BY-SA 4.0), Michael Watson's [Frontier: Elite II renderer write-up](http://watsonmw.com/fintro/) and its C source [fe2-intro](https://github.com/watsonmw/fe2-intro) for 3D engines, fixed-point maths, depth sorting and palette tricks.
- **Building and cross-compiling**: verified toolchain settings, Docker images (`sacredbanana/amiga-compiler:m68k-amigaos`, `ppc-amigaos`, `ppc-morphos`), Makefile patterns, native Bebbo GCC setup, and known gotchas such as `-fbaserel` with MUI/BOOPSI and the libnix `errno` link error.

Once installed and enabled, the assistant can select the skill automatically for Amiga library/API questions, requests for book recommendations or download links, and questions about compiling, Makefiles or linker errors for Amiga targets.

## Installation

### ChatGPT desktop app and Codex

Clone into the shared user skills directory for local use:

```bash
mkdir -p ~/.agents/skills
git clone https://github.com/sacredbanana/amiga-guru.git ~/.agents/skills/amiga-guru
```

For a single Codex project, clone into `.agents/skills/amiga-guru` inside that project instead.

In the ChatGPT desktop app, open **Skills** in the sidebar and look for **Amiga Guru**. Select it with `@` in a prompt, for example: “Use Amiga Guru to explain AllocMem on AmigaOS 3.” In Codex, use `$amiga-guru`. If it does not appear after installation, restart the app.

These are local skill installation instructions; they do not install the skill into ChatGPT on the web or mobile. See OpenAI's [skill guide](https://learn.chatgpt.com/docs/build-skills) for supported locations and [plugin distribution](https://developers.openai.com/plugins/build/plugins).

Already using it in Claude Code? The ChatGPT desktop app can also import skills through **Settings → Import** (or **General → Import other agent setup**). See the [official import guide](https://learn.chatgpt.com/docs/import). Choose one installation method to avoid duplicate entries.

### Claude Code

Clone the repository into your skills directory:

```bash
# For all your projects
git clone https://github.com/sacredbanana/amiga-guru.git ~/.claude/skills/amiga-guru

# Or for a single project
git clone https://github.com/sacredbanana/amiga-guru.git .claude/skills/amiga-guru
```

### Claude.ai

Create a ZIP containing only the committed skill files, then upload it under **Settings → Capabilities → Skills**:

```bash
git archive --format=zip --prefix=amiga-guru/ --output=amiga-guru.zip master
```

Run this from a checkout of this repository. Do not zip a working folder containing `.git/` or the downloaded SDK cache.

## Requirements

- Shell access, `git`, `bash` and a writable skill directory for the SDK cache (without them the skill uses the host's web tools to browse GitHub file by file)
- Network access to GitHub, GitLab, retro-commodore.eu and watsonmw.com
- Docker, optionally, for building Amiga projects with the toolchain images

The skill uses whichever shell, file-reading and web tools its host provides. A chat with web access alone can provide reference guidance; building requires a local execution environment with the relevant toolchain. It does not assume access to your other chats or project files.

## Repository layout

| Path | Purpose |
|------|---------|
| `SKILL.md` | The skill itself: instructions, build reference and source-matching rules |
| `agents/openai.yaml` | ChatGPT/Codex display metadata; Claude uses the same `SKILL.md` |
| `scripts/sync-cache.sh` | Creates or updates the AmigaSDK-gcc sparse clone in `cache/amigasdk-gcc` and prints its path |
| `cache/` | Created on first use; git-ignored, never commit it |

To refresh the SDK cache by hand:

```bash
./scripts/sync-cache.sh
```

## License

[MIT](LICENSE) © 2026 Cameron Armstrong (Nightfox)
