#!/usr/bin/env bash
# iContext installer - installs the icontext-* skills into your Claude Code skills dir.
#   ./install.sh          copy skills (default)
#   ./install.sh --link   symlink skills (repo stays the single source of truth)
set -euo pipefail

DEST="${CLAUDE_SKILLS_DIR:-$HOME/.claude/skills}"
SRC="$(cd "$(dirname "$0")" && pwd)"   # skills live at the repo root
MODE="${1:-copy}"

mkdir -p "$DEST"
for s in icontext-init icontext-feature; do
  rm -rf "$DEST/$s"
  if [ "$MODE" = "--link" ]; then
    ln -s "$SRC/$s" "$DEST/$s"; echo "linked  $s -> $SRC/$s"
  else
    cp -R "$SRC/$s" "$DEST/$s"; echo "copied  $s"
  fi
done

echo
echo "Done. Restart Claude Code, then run /icontext-init in a project directory."
