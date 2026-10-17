#!/usr/bin/env bash
# Sync the AmigaSDK-gcc sparse clone into THIS skill's own cache directory.
# The cache lives at <skill-dir>/cache/amigasdk-gcc and nowhere else.
# Prints the cache path on the last line of stdout when it succeeds.
set -euo pipefail

SKILL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CACHE="$SKILL_DIR/cache/amigasdk-gcc"
REPO="https://github.com/sacredbanana/AmigaSDK-gcc"

mkdir -p "$SKILL_DIR/cache"
# Keep cache contents out of version control and out of packaged .skill files.
[ -f "$SKILL_DIR/cache/.gitignore" ] || printf '*\n!.gitignore\n' > "$SKILL_DIR/cache/.gitignore"

if [ -d "$CACHE/.git" ]; then
  echo "Updating existing cache..." >&2
  git -C "$CACHE" pull --depth=1 origin master >&2
else
  echo "Creating cache (sparse clone)..." >&2
  mkdir -p "$CACHE"
  git -C "$CACHE" init -q
  git -C "$CACHE" remote add origin "$REPO"
  git -C "$CACHE" config core.sparseCheckout true
  cat > "$CACHE/.git/info/sparse-checkout" << 'SPARSE'
amigaos3/docs/
amigaos3/sdk/m68k-amigaos/include/
amigaos3/sdk/m68k-amigaos/ndk-include/
amigaos4/docs/
amigaos4/sdk/ppc-amigaos/SDK/include/
amigaos4/sdk/ppc-amigaos/SDK/local/common/include/
morphos/docs/
morphos/sdk/include/
morphos/sdk/os-include/
morphos/sdk/ppc-morphos/include/
README.md
combine-docs.sh
build.sh
update-libnix.sh
Dockerfile.*
SPARSE
  git -C "$CACHE" pull --depth=1 origin master >&2
fi

echo "$CACHE"
