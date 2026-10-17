---
name: "amiga-guru"
description: Amiga Guru skill — Use when answering Amiga dev questions that need classic books from the retro-commodore.eu catalog or latest OS3/OS4/MorphOS autodocs and libraries from the sacredbanana/AmigaSDK-gcc GitHub repo, AND when setting up, writing a Makefile for, cross-compiling or building any Amiga or Amiga-like project (AmigaOS 3 m68k, AmigaOS 4 PPC, MorphOS PPC, AROS x86/ARM/etc.) with the Docker toolchain images or a native Bebbo GCC install. Triggers on library APIs, book recommendations, needing download links, code examples, compiler/toolchain setup, linker errors, or "how do I build this for Amiga".
---

# Amiga Guru

Act as a precise librarian for Amiga development sources. Match the query to the best public resource and provide actionable links plus targeted guidance.

## GitHub Repo Cache (AmigaSDK-gcc)

Before browsing individual files from the GitHub repo, **always attempt to clone the repo into a local cache first**. This is faster and more reliable than file-by-file GitHub access.

### Cache Setup

**The skill's own cache is the only cache.** It lives at `cache/amigasdk-gcc` inside this skill's directory (the folder containing this `SKILL.md`; use the path shown for the skill in `<available_skills>`). Never clone, download or read the SDK repo from anywhere else: not `/tmp`, not a project's `.agents/skills/amiga-sdk-docs/cache/`, not the user's working directory, and not a different skill's cache. If another clone happens to exist elsewhere, ignore it.

Run the bundled script at the start of any session where you'll need the GitHub docs or headers. It works out the skill directory from its own location, creates or updates the sparse clone (docs + headers only, no SDK binaries) and prints the cache path as its last line:

```bash
CACHE=$(<skill-dir>/scripts/sync-cache.sh | tail -n 1)
```

Replace `<skill-dir>` with this skill's directory. Wait for the script to finish before reading from the cache. Never commit the cache; `cache/.gitignore` keeps its contents out of git and out of packaged `.skill` files.

**If the script succeeds**, read files directly from `$CACHE` instead of fetching from GitHub one by one. The cache contains:

| Path | Contents | Size |
|------|----------|------|
| `amigaos3/docs/` | OS3 autodocs, examples, guides | ~14 MB |
| `amigaos3/sdk/m68k-amigaos/include/` | OS3 SDK headers (exec, intuition, libraries, proto, inline4, third-party) | ~14 MB |
| `amigaos3/sdk/m68k-amigaos/ndk-include/` | OS3 NDK headers + `.i` assembler includes | ~6 MB |
| `amigaos4/docs/` | OS4 autodocs, examples, MUI docs | ~33 MB |
| `amigaos4/sdk/ppc-amigaos/SDK/include/` | OS4 SDK headers | ~14 MB |
| `amigaos4/sdk/ppc-amigaos/SDK/local/common/include/` | OS4 local/third-party headers | ~1 MB |
| `morphos/docs/` | MorphOS autodocs | ~5 MB |
| `morphos/sdk/include/` | MorphOS SDK headers | ~6 MB |
| `morphos/sdk/os-include/` | MorphOS OS includes | ~8 MB |
| `morphos/sdk/ppc-morphos/include/` | MorphOS PPC-specific headers | ~0.4 MB |

**If the script fails** (network error, git unavailable, disk full, skill directory not writable, etc.), do not fall back to a cache anywhere else. Fall through to the standard GitHub browsing approach described in the **Fallback: Direct GitHub Browsing** section below, and always tell the user which mode you're using.

**Other downloads:** if you need to download any other reference file (e.g. the Aminet RKRM DOS PDF), save it under this skill's `cache/downloads/` directory, never to `/tmp` or the project directory.

### Using the Cache

Once the cache is ready (`$CACHE` is the path printed by `sync-cache.sh`), navigate it like a local filesystem:

```bash
# Find a specific header
find $CACHE -name "exec.h" 
find $CACHE -name "intuition.h"

# Search for a struct, function or constant across all headers
grep -r "struct Node" $CACHE/amigaos3/sdk/m68k-amigaos/include/
grep -r "AllocMem" $CACHE/amigaos4/sdk/ppc-amigaos/SDK/include/

# Find all autodoc files matching a topic
find $CACHE -name "*.doc" | grep -i exec

# Search for a function across all autodocs
grep -r "AllocMem" $CACHE/amigaos3/docs/Autodocs/ | head -20

# List proto headers (function prototypes)
ls $CACHE/amigaos3/sdk/m68k-amigaos/include/proto/

# Read a specific header
cat $CACHE/amigaos3/sdk/m68k-amigaos/include/exec/memory.h

# Cross-OS comparison
grep -r "IExec" $CACHE/amigaos4/sdk/ppc-amigaos/SDK/include/ | head -10
```

When providing file references to the user, also give the equivalent GitHub URL:
`https://github.com/sacredbanana/AmigaSDK-gcc/blob/master/<relative-path>`

---

## Fallback: Direct GitHub Browsing

Use this only when the skill's own cache cannot be created or updated. Browse and read files one at a time via the GitHub web interface:

- Primary repo: https://github.com/sacredbanana/AmigaSDK-gcc
- Start by browsing the main page and README for overview and installation notes (Bebbo GCC, Docker images).
- Explore the three main directories: amigaos3/, amigaos4/, and morphos/.
- For a specific library or function (e.g. exec.library, intuition.library, roadshow, amissl, guigfx, codesets) locate the relevant include files or subfolders inside the matching OS directory.
- Look for autodoc-style comments in source, function prototypes, constants, and any example code or combine-docs.sh output.
- When the query involves modern development, third-party libraries, or up-to-date function signatures for OS3.2 / OS4 / MorphOS, prioritize this repo over older printed books.
- Provide direct GitHub links to folders or specific files (blob or raw) so the user can view the exact source.
- If example code exists for the topic, highlight the path and summarize the relevant usage pattern.

---

## Building Amiga Projects (any Amiga-like OS / architecture)

Everything below the "Verified" headings was taken from the AmigaGPT repo (Makefile, Makefile.OS4, Makefile.MorphOS, build_*.sh) and the AmigaSDK-gcc Dockerfiles. Anything under "Other Amiga-likes" is general knowledge, **not verified here**: say so to the user and check upstream docs.

### Rule of thumb: never invent a toolchain

1. **If the project ships build scripts (`build_os3.sh`, `build_os4.sh`, `build_morphos.sh`, `package.sh`), run those and nothing else.** No direct `make`, no ad-hoc Docker invocations; they will not work reliably. Pass `CLEAN=1` for a clean build and `DEBUG=1` for `-DDEBUG -g -Og` instead of `-Ofast`. Surface script output on failure and troubleshoot inside those constraints.
2. **If the project has no scripts**, use the Docker images below (or a native install) and mirror the verified patterns.
3. The project's own `AGENTS.md`/`CLAUDE.md` wins over this section when they disagree (e.g. AmigaGPT forbids touching `make` directly).

### Verified: targets, compilers and images

| Target | Arch | Compiler | Docker image (`sacredbanana/amiga-compiler:<tag>`) | Base image | Platform macros |
|---|---|---|---|---|---|
| AmigaOS 3.x (NDK 3.2) | m68k | `m68k-amigaos-gcc` (Bebbo GCC) + `vasmm68k_mot` | `m68k-amigaos` | `amigadev/crosstools:m68k-amigaos` | `-D__AMIGAOS3__` |
| AmigaOS 4.1 (SDK 54.16) | PPC | `ppc-amigaos-gcc` | `ppc-amigaos` | `amigadev/crosstools:ppc-amigaos` | `-D__AMIGAOS4__ -D__amigaos4__ -D__USE_INLINE__` |
| MorphOS 3.x (SDK 3.20) | PPC | `ppc-morphos-gcc` (GCC 15.2.0 in the image) | `ppc-morphos` | `amigadev/crosstools:ppc-morphos` | `-D__MORPHOS__` |

Images exist for linux/amd64 and linux/arm64 (Apple Silicon works). Pull with `docker pull sacredbanana/amiga-compiler:m68k-amigaos` (likewise `ppc-amigaos`, `ppc-morphos`). To rebuild them from source: clone AmigaSDK-gcc and run `./build.sh` (`NAME=...` to rename, `PUSH=1` to multi-arch push).

Inside each image the SDK is copied to `/tools/` and symlinked as `/opt/amiga`; the working dir is `/work`; `FLEXCAT_SDDIR=/opt/amiga/lib/flexcat`. The OS3 image also deletes the stock NDK `translator.h` and `translator_protos.h` in favour of translator.library v42.4's.

### Verified: the Docker invocation pattern

Run from the project root so it is mounted at `/work`:

```bash
docker run --rm \
  -v ${PWD}:/work \
  -e USER=$(id -u) -e GROUP=$(id -g) -e DEBUG=${DEBUG} \
  sacredbanana/amiga-compiler:m68k-amigaos sh -c "make && make daemon"
```

- OS4: image tag `ppc-amigaos`, `make -f Makefile.OS4`; MorphOS: tag `ppc-morphos`, `make -f Makefile.MorphOS`.
- Clean: same `docker run` with `make clean` (plus the `-f` for OS4/MorphOS).
- `USER`/`GROUP` are passed so output files are not owned by root on the host.
- The build tree is `build/<os3|os4|morphos>/obj`; binaries land in `out/` as `<Name>_OS3`, etc. (AmigaGPT: `AmigaGPT_OS3`, `AmigaGPTD_OS3`...).

### Verified: native install (no Docker)

1. Install Bebbo's amiga-gcc devkit: https://github.com/bebbo/amiga-gcc
2. Copy the contents of the AmigaSDK-gcc `<os>/sdk/` directory over the toolkit (e.g. `amigaos3/sdk/*` into `/opt/amiga`), replacing existing files.
3. Set `FLEXCAT_SDDIR=/opt/amiga/lib/flexcat` if you use FlexCat catalogs.

### Verified: per-target Makefile settings

| | AmigaOS 3 (`Makefile`) | AmigaOS 4 (`Makefile.OS4`) | MorphOS (`Makefile.MorphOS`) |
|---|---|---|---|
| `CC` | `m68k-amigaos-gcc` | `ppc-amigaos-gcc` | `ppc-morphos-gcc` |
| Key CFLAGS | `-m68020 -noixemul` (libnix) | `-fno-exceptions -fno-tree-loop-distribution -fomit-frame-pointer` | `-noixemul -fno-exceptions -fno-tree-loop-distribution -fomit-frame-pointer` |
| Release / debug | `-Ofast -fomit-frame-pointer` / `-DDEBUG -g -Og` | `-Ofast` / `-DDEBUG -g -Og` | same as OS4 |
| Libs | `-lamiga -lm -lamisslstubs -ljson-c -lmagic -lmui` | `-lm -lamisslstubs -ljson-c -lmagic -lauto` | `-lm -ljson-c -lmagic -lssl -lcrypto -lpthread -latomic` |
| SDK paths | defaults in the image | `LIBDIR=/opt/amiga/ppc-amigaos/lib`, `SDKLIBDIR=.../ppc-amigaos/SDK/lib`, `SDKDIR=.../SDK/include/include_h`, `NETINCDIR=.../SDK/include/netinclude`, `INCDIR=.../ppc-amigaos/include` | `LIBDIR=/opt/amiga/lib`, `SDKLIBDIR=/opt/amiga/ppc-morphos/lib`, `SDKDIR=/opt/amiga/os-include`, `NETINCDIR=/opt/amiga/includestd`, `INCDIR=/opt/amiga/ppc-morphos/include`, `GCCLIBDIR=/opt/ppc-morphos/lib/gcc-lib/ppc-morphos/15.2.0/` (for `-latomic`) |
| Assembler | `vasmm68k_mot -m68020 -Fhunk -opt-fconst -nowarn=62 -dwarf=3 -quiet -x -I. -D__AMIGAOS3__`; `.s` via gcc with `-Wa,-g,--register-prefix-optional,-D` | same flags with `-I$(NETINCDIR) -I$(SDKDIR) -I$(INCDIR)` | same pattern |
| TLS | AmiSSL (`-lamisslstubs`) | AmiSSL (`-lamisslstubs`) | OpenSSL (`-lssl -lcrypto`) |

Makefile skeleton used by all three: `-MP -MMD` dependency files, `VPATH` over `src/*/`, separate `BUILD_DIR` per OS, `-DGIT_BRANCH/-DGIT_COMMIT/-DGIT_TIMESTAMP/-DBUILD_DATE` stamped in, a daemon variant built from the same objects with `-DDAEMON`, `SED = sed -i ""` on Darwin vs `sed -i` elsewhere, and `$(CC) $(CCFLAGS) $(LDFLAGS) objects -o out/...` (LDFLAGS is deliberately given before and after the objects so static libs resolve).

### Verified: third-party libraries bundled in the SDK images

- **AmigaOS 3**: Roadshow 1.5, AmiSSL 5.27, translator.library 42.4, textfield.gadget 3.1, json-c 0.19, Codesets 6.22, guigfx.library 20.1, FlexCat source descriptions, RxMUI 42.7, libmagic 5.48, MCC_ActionTextEditor, MCC_AudioPlayer.
- **AmigaOS 4**: AmiSSL 5.27, Cairo, Flex, Expat, Execsg, MiniGL, Pthreads, Python, SDI 1.7, Flite device, json-c, Codesets, guigfx, FlexCat SDs, libmagic, MCC_ActionTextEditor, MCC_AudioPlayer.
- **MorphOS**: json-c, Codesets, guigfx, FlexCat SDs, libmagic, MCC_ActionTextEditor, MCC_AudioPlayer (OpenSSL/pthread come from the MorphOS SDK).
- Other C runtimes shipped for OS3 under `amigaos3/sdk/m68k-amigaos/`: `libnix` (default with `-noixemul`), `ixemul`, `clib2`, plus `vbcc` support files and NDK 1.3 includes (`ndk13-include`). Multilibs: `lib`, `libb` (baserel), `libm020`, `libm060`, `libb32`.

### Verified: gotchas that have bitten real builds

- **Do not use `-fbaserel` on m68k** for MUI/BOOPSI programs. Base-relative addressing keeps the data base in `a4`; every callback the OS invokes (BOOPSI dispatchers, SDI hooks) must re-establish it with `__saveds`, and the m68k SDI macros do not. Result: libnix `malloc/free` read heap state through a foreign `a4` and crash intermittently on exit.
- **libnix errno change** (new Bebbo libnix): `errno` became `(*__errno)`, so any pre-built `libnix` static library that touches errno (e.g. `libjson-c.a`) fails to link with `undefined reference to 'errno'` until rebuilt against the new headers. `libamisslstubs.a` is clean; `libamisslauto.a` references errno (rebuild from the AmiSSL SDK's `autoinit_amissl_main.c` if you need it). `Dockerfile.libnix` + `update-libnix.sh` regenerate libnix into the SDK repo.
- **Catalog/localization builds**: `.catalog` files come from `.pot`/`.po` via `xgettext`, `msgmerge -U` and `flexcat`; changing a `STRING_*` without regenerating `*_cat.c/.h` fails at link time.
- **Build-number sed**: the Makefiles rewrite `version.h` on every compile; do not hand-edit it.
- **Host line endings/encoding**: Amiga source and docs are often ISO 8859-1; check the project's rules before editing with tools that assume UTF-8.
- **Per-target `#ifdef`s**: guard OS-specific code with `__AMIGAOS3__`, `__AMIGAOS4__`, `__MORPHOS__` (and project macros such as `DAEMON`) and keep all targets compiling.
- Packaging: `package.sh` in AmigaGPT does a clean build for all three platforms, copies executables and catalogs into a bundle directory and creates an `.lha`.
- Autodocs/NDK reading goes through the cache described above; headers live under `amigaos3/sdk/m68k-amigaos/{include,ndk-include}`, `amigaos4/sdk/ppc-amigaos/SDK/include`, `morphos/sdk/{include,os-include}`.

### Other Amiga-likes and architectures (NOT verified in this repo)

State clearly that this is from general knowledge and point to upstream docs before relying on it.

| OS | Arch | How it is typically built |
|---|---|---|
| AROS (x86, x86_64, ARM, PPC, m68k) | various | Cross toolchain is built from the AROS source tree (https://github.com/aros-development-team/AROS); compilers are named like `i386-aros-gcc`, `x86_64-aros-gcc`, `arm-aros-gcc`; use AROS's `mmake`/`make` metabuild, or the project's own Makefile against the AROS SDK. Source is largely OS3-API compatible; 64-bit builds need care with `IPTR`/`APTR` size assumptions. |
| AmigaOS 3 alternative toolchains | m68k | VBCC + vasm + vlink with the NDK, SAS/C or StormC on real hardware/emulators; the SDK repo ships `vbcc` support files and `clib2`. |
| WarpOS / PowerUP | PPC (on 68k Amigas) | Legacy; use the vendor SDKs or `vbcc` PPC targets. |
| Natively on the Amiga | m68k/PPC | Run the compiler under AmigaOS itself (GCC 2.95 / Bebbo ports, SAS/C). |

When asked for a target not covered here: (1) identify the CPU architecture and OS API level, (2) check whether a Docker image or cross toolchain already exists, (3) map the equivalent of `CC`, platform macros, include/lib paths, link libs and C runtime using the verified table as the template, and (4) tell the user which pieces you could not verify.

### Build workflow checklist

1. Read the project's build docs (`AGENTS.md`, `README`, `Makefile*`, `build_*.sh`).
2. Pick the target OS/arch, then run the project script (or the Docker pattern above).
3. On failure: show the real output; classify as missing include (check SDK paths and the cache), undefined reference (missing `-l`, wrong multilib, libnix errno), or a platform `#ifdef` problem.
4. Verify the produced binary exists in `out/` (or equivalent) and, if an emulator is available (AmiKit/Amiberry/WinUAE/QEMU for OS4/MorphOS), smoke-test it.

---

## Classic Books and Older Reference Manuals (retro-commodore.eu)

- The full catalog is at https://www.retro-commodore.eu/amiga-development/
- Page 1 contains the majority of the ROM Kernel Manuals, Hardware Reference Manuals, Intuition Reference Manual, Abacus books, etc.
- For additional pages use ?rceu_page=2, ?rceu_page=3 etc.
- Always extract the exact title, file size, and direct download link (/download.php?file=...).
- General rule: When multiple editions exist in the catalog, **prefer the 3rd edition** of official Commodore reference manuals unless the query specifically needs older information (e.g. very early OS versions).
- Strong matching rules (use the most relevant):
  - ARexx or Rexx scripting → ARexx User's Reference Manual (William Hawes) on page 2
  - 68k Assembly or Machine Language → Amiga Machine Language (Abacus)
  - Hardware, custom chips, Agnus, Denise, Paula → Hardware Reference Manual 3rd edition (or latest available)
  - exec.library, signals, memory, tasks → ROM Kernel Reference Manual Exec
  - Libraries, devices, dos.library, AmigaDOS, file handling, processes → ROM Kernel Reference Manual Libraries and Devices 3rd edition + the preserved RKRM DOS volume at https://aminet.net/docs/misc/rkrm-dos.pdf (download this one into the skill's `cache/downloads/` directory and add it to the Project)
  - Includes, autodocs, function prototypes → ROM Kernel Reference Manual Includes and Autodocs 3rd edition (or 2nd if 3rd not suitable)
  - Intuition, gadgets, windows, screens → Amiga Intuition Reference Manual (main reference)
  - User interface, style, gadgets → Amiga User Interface Style Guide
  - General system programming or C on Amiga → Advanced System Programmers Guide for the Amiga or Amiga System Programmers Guide (Abacus)
  - Developer conferences / advanced topics → Commodore Amiga Developers Conference documents
- For almost every technical question, recommend the single best book from the catalog (with direct download link) and any relevant high-quality external preserved docs (e.g. the Aminet RKRM volumes).
- Strongly advise the user to download the recommended PDFs and upload them to their Amiga Guru Project so they become persistently available.
- Never output large verbatim excerpts from the scanned books.

---

## General Rules

- Always consider whether the user already has relevant material in their personal Amiga Guru Project — suggest checking there first or in parallel.
- Be extremely precise with function names, structures, return codes, and gotchas pulled from the sources.
- Give short targeted excerpts or summaries only when they directly answer the question; point back to the source for full context.
- If the best answer requires a specific book or file the user doesn't have, give the direct link and a one-sentence reason why it's the right one.
- Combine sources when helpful: classic book for concepts + GitHub repo for latest signatures and examples.
- Trigger automatically on any deep Amiga dev technical question involving libraries, APIs, or needing reference material.
