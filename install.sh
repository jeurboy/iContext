#!/usr/bin/env bash
# iContext installer — installs the icontext-* skills for your AI coding tool.
#
#   From a clone:  ./install.sh [tool] [--link]
#   One-liner:     curl -fsSL <raw>/install.sh | bash -s -- [tool]
#
# tool (default: claude):
#   claude          Claude Code   → ~/.claude/skills/                              (global slash-command skills)
#   claude-project  Claude Code   → ./.claude/skills/                              (this project)
#   cursor          Cursor        → ./.cursor/rules/icontext.mdc                   (project rule)
#   copilot         GitHub Copilot→ ./.github/instructions/icontext.instructions.md
#   windsurf        Windsurf      → ./.windsurf/rules/icontext.md
#   cline           Cline         → ./.clinerules/icontext.md
#   gemini          Gemini CLI    → ./.gemini/GEMINI.md
#   codex           OpenAI Codex  → ./AGENTS.md (append)
#   aider           Aider         → ./CONVENTIONS.md (append)
#
# Skill files are cached at ${ICONTEXT_HOME:-~/.icontext}; non-Claude pointers reference them.
set -euo pipefail

REPO_URL="${ICONTEXT_REPO:-https://github.com/jeurboy/iContext.git}"
ICONTEXT_HOME="${ICONTEXT_HOME:-$HOME/.icontext}"
SKILLS=(icontext-init icontext-update icontext-audit icontext-visualize icontext-feature)

TOOL="claude"
MODE="copy"
for a in "$@"; do
  case "$a" in
    --link) MODE="link" ;;
    --*)    ;;                # ignore unknown flags
    *)      TOOL="$a" ;;
  esac
done

case "$TOOL" in
  claude|claude-project|cursor|copilot|windsurf|cline|gemini|codex|aider) ;;
  *) echo "Unknown tool: $TOOL"
     echo "Use one of: claude | claude-project | cursor | copilot | windsurf | cline | gemini | codex | aider"
     exit 1 ;;
esac

# --- locate source: a local clone next to this script, else clone into the cache ---
SELF_DIR=""
if [ -n "${BASH_SOURCE[0]:-}" ] && [ -f "${BASH_SOURCE[0]:-}" ]; then
  SELF_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
fi
if [ -n "$SELF_DIR" ] && [ -d "$SELF_DIR/icontext-init" ]; then
  SRC="$SELF_DIR"
else
  # piped via curl — clone or update the cached repo
  command -v git >/dev/null || { echo "git is required for the one-liner install"; exit 1; }
  SRC="$ICONTEXT_HOME/repo"
  if [ -d "$SRC/.git" ]; then
    git -C "$SRC" pull --ff-only -q || true
  else
    mkdir -p "$ICONTEXT_HOME"
    git clone -q --depth 1 "$REPO_URL" "$SRC"
  fi
fi

# --- sync skills into the stable shared home (so pointers have a fixed path to read) ---
mkdir -p "$ICONTEXT_HOME"
for s in "${SKILLS[@]}"; do
  rm -rf "$ICONTEXT_HOME/$s"
  cp -R "$SRC/$s" "$ICONTEXT_HOME/$s"
done

install_claude() {                      # $1 = destination skills dir
  local dest="$1"; mkdir -p "$dest"
  for s in "${SKILLS[@]}"; do
    rm -rf "$dest/$s"
    if [ "$MODE" = "link" ]; then ln -s "$SRC/$s" "$dest/$s"; else cp -R "$SRC/$s" "$dest/$s"; fi
    echo "  $MODE  $s -> $dest/$s"
  done
}

pointer_body() {                        # $1 = adapter name
  cat <<EOF
iContext gives you five workflows to scaffold, audit, visualize, and maintain this project's layered context.

Skill files (read these to run the workflow):
- \`$ICONTEXT_HOME/icontext-init/PROCEDURE.md\` — scaffold or update/sync the context backbone
  (CONTEXT.md, L1 agent files, plans/, styles/, docs/). Idempotent & non-destructive.
- \`$ICONTEXT_HOME/icontext-update/PROCEDURE.md\` — backfill an existing CONTEXT.md/iContext
  project with missing sections and latest templates. Confirms every change before writing.
- \`$ICONTEXT_HOME/icontext-audit/PROCEDURE.md\` — audit an existing context for latest-template
  gaps, repo/context drift, and unnecessary Markdown cleanup candidates. Asks for every decision.
- \`$ICONTEXT_HOME/icontext-visualize/PROCEDURE.md\` — export a static HTML/JS dependency graph
  from CONTEXT.md, plans, services, docs, styles, and related Markdown files.
- \`$ICONTEXT_HOME/icontext-feature/PROCEDURE.md\` — add one feature plan (role-split folder).

Tool-specific notes (when present):
- \`$ICONTEXT_HOME/icontext-init/adapters/$1.md\`
- \`$ICONTEXT_HOME/icontext-update/adapters/$1.md\`
- \`$ICONTEXT_HOME/icontext-audit/adapters/$1.md\`
- \`$ICONTEXT_HOME/icontext-visualize/adapters/$1.md\`
- \`$ICONTEXT_HOME/icontext-feature/adapters/$1.md\`
To start: follow icontext-init's PROCEDURE.md, use icontext-update for missing template backfills,
use icontext-audit for drift/cleanup checks, icontext-visualize for graph exports, then
icontext-feature for each feature.
EOF
}

write_pointer() {                       # $1 = file, $2 = adapter name
  local file="$1"; mkdir -p "$(dirname "$file")"
  pointer_body "$2" > "$file"
  echo "  wrote pointer -> $file"
}

write_cursor_rule() {                   # Cursor .mdc needs frontmatter
  local file="$PWD/.cursor/rules/icontext.mdc"; mkdir -p "$(dirname "$file")"
  { printf -- '---\ndescription: iContext — scaffold & maintain project context\nalwaysApply: false\n---\n\n'
    pointer_body cursor; } > "$file"
  echo "  wrote rule -> $file"
}

append_pointer() {                      # $1 = file, $2 = adapter name (idempotent)
  local file="$1"; mkdir -p "$(dirname "$file")"
  if [ -f "$file" ] && grep -q "iContext skill pointer" "$file" 2>/dev/null; then
    echo "  already linked in $file"; return
  fi
  { echo; echo "<!-- iContext skill pointer -->"; pointer_body "$2"; } >> "$file"
  echo "  appended pointer -> $file"
}

echo "iContext → $TOOL   (source: $SRC)"
case "$TOOL" in
  claude)         install_claude "$HOME/.claude/skills" ;;
  claude-project) install_claude "$PWD/.claude/skills" ;;
  cursor)         write_cursor_rule ;;
  copilot)        write_pointer  "$PWD/.github/instructions/icontext.instructions.md" copilot ;;
  windsurf)       write_pointer  "$PWD/.windsurf/rules/icontext.md" gemini ;;
  cline)          write_pointer  "$PWD/.clinerules/icontext.md" gemini ;;
  gemini)         write_pointer  "$PWD/.gemini/GEMINI.md" gemini ;;
  codex)          append_pointer "$PWD/AGENTS.md" codex ;;
  aider)          append_pointer "$PWD/CONVENTIONS.md" codex ;;
esac

echo
echo "Done. Skill files cached at $ICONTEXT_HOME."
[ "$TOOL" = "claude" ] && echo "Restart Claude Code, then run /icontext-init in a project directory."
exit 0
