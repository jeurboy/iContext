#!/usr/bin/env bash
# Validate the iContext skill package before release.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

fail() {
  echo "FAIL: $*" >&2
  exit 1
}

require_file() {
  test -f "$1" || fail "missing file: $1"
}

require_executable() {
  test -x "$1" || fail "not executable: $1"
}

for skill in icontext-init icontext-update icontext-feature; do
  require_file "$skill/SKILL.md"
  require_file "$skill/PROCEDURE.md"
  require_file "$skill/VERSION"
  require_executable "$skill/check-update.sh"
done

for file in \
  icontext-init/templates/CLAUDE.md \
  icontext-init/templates/AGENTS.md \
  icontext-init/templates/AGENT.md \
  icontext-init/templates/GEMINI.md \
  icontext-init/templates/CONTEXT.md \
  icontext-init/templates/ROLE.md \
  icontext-init/templates/PLAN.md \
  icontext-init/templates/docker-compose.yml \
  icontext-init/templates/docs/openapi.yaml \
  icontext-init/templates/.vscode/launch.json \
  icontext-init/templates/styles/css/tokens.css \
  icontext-init/templates/styles/components/button.html; do
  require_file "$file"
done

for file in README.md bu.md po.md dev.md qa.md ops.md stk.md; do
  require_file "icontext-init/templates/plans/_TEMPLATE/$file"
  require_file "icontext-feature/templates/plan-template/$file"
done

for stack in \
  api-go-clean \
  api-nestjs \
  db-postgres \
  mobile-flutter \
  mobile-rn \
  web-nextjs; do
  require_file "icontext-init/templates/stacks/$stack/STRUCTURE.md"
done

if rg -n "ux-ui-pro-max" --glob '!scripts/validate.sh' . >/dev/null; then
  fail "found old companion skill spelling: ux-ui-pro-max"
fi

if rg -n "^version:" icontext-init/SKILL.md icontext-update/SKILL.md icontext-feature/SKILL.md >/dev/null; then
  fail "SKILL.md frontmatter must not contain version; use VERSION files"
fi

validator="$HOME/.codex/skills/.system/skill-creator/scripts/quick_validate.py"
if command -v python3 >/dev/null && test -f "$validator"; then
  python3 "$validator" icontext-init
  python3 "$validator" icontext-update
  python3 "$validator" icontext-feature
else
  echo "WARN: skipped Codex quick_validate.py (python3 or validator not found)"
fi

echo "OK: iContext validation passed"
