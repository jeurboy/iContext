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

for skill in icontext-init icontext-update icontext-audit icontext-visualize icontext-feature; do
  require_file "$skill/SKILL.md"
  require_file "$skill/PROCEDURE.md"
  require_file "$skill/VERSION"
  require_executable "$skill/check-update.sh"
  require_file "$skill/adapters/claude.md"
  require_file "$skill/adapters/codex.md"
  require_file "$skill/adapters/cursor.md"
  require_file "$skill/adapters/gemini.md"
done

require_executable "icontext-visualize/scripts/export-context-graph.js"
require_executable "icontext-init/templates/.icontext/hooks/guard-command.sh"
require_file "icontext-init/templates/.icontext/hooks/POLICY.md"

for file in \
  icontext-init/templates/CLAUDE.md \
  icontext-init/templates/AGENTS.md \
  icontext-init/templates/AGENT.md \
  icontext-init/templates/GEMINI.md \
  icontext-init/templates/CONTEXT.md \
  icontext-init/templates/DEV.md \
  icontext-init/templates/PRODUCT.md \
  icontext-init/templates/QA.md \
  icontext-init/templates/SECURITY.md \
  icontext-init/templates/DESIGN.md \
  icontext-init/templates/SKILLS.md \
  icontext-init/templates/ROLE.md \
  icontext-init/templates/PLAN.md \
  icontext-init/templates/docker-compose.yml \
  icontext-init/templates/docs/openapi.yaml \
  icontext-init/templates/.vscode/launch.json \
  icontext-init/templates/styles/css/tokens.css \
  icontext-init/templates/styles/components/button.html; do
  require_file "$file"
done

rg -q "^### 10\." icontext-init/templates/SKILLS.md ||
  fail "SKILLS.md must own section 10"
rg -q "/investigate" icontext-init/templates/SKILLS.md ||
  fail "SKILLS.md must route system bugs through gstack /investigate"
rg -q "https://github\.com/garrytan/gstack\.git" icontext-init/templates/SKILLS.md ||
  fail "SKILLS.md must include the upstream gstack Git URL"
rg -q "Moved to \[SKILLS\.md\].*§10" icontext-init/templates/CONTEXT.md ||
  fail "CONTEXT.md must point section 10 to SKILLS.md"
rg -q "^#### 11\.7 Agent mutation safety" icontext-init/templates/CONTEXT.md ||
  fail "CONTEXT.md must define the agent mutation safety gate"

for file in CLAUDE.md AGENTS.md AGENT.md GEMINI.md; do
  rg -q "SKILLS\.md" "icontext-init/templates/$file" ||
    fail "$file must point agents to SKILLS.md"
done

for file in \
  icontext-init/templates/plans/_TEMPLATE/README.md \
  icontext-feature/templates/plan-template/README.md; do
  rg -q "SKILLS\.md" "$file" || fail "$file must link to SKILLS.md"
done

rg -q "(§10.*SKILLS\.md|SKILLS\.md.*§10)" icontext-update/PROCEDURE.md ||
  fail "icontext-update must migrate legacy section 10 into SKILLS.md"
rg -q "/investigate" icontext-update/PROCEDURE.md ||
  fail "icontext-update must backfill the gstack /investigate bug route"
rg -q "name: 'SKILLS\.md'" icontext-visualize/scripts/export-context-graph.js ||
  fail "context graph exporter must include SKILLS.md"

for file in CLAUDE.md AGENTS.md AGENT.md GEMINI.md; do
  rg -q "\.icontext/hooks/" "icontext-init/templates/$file" ||
    fail "$file must include project safety-hook guidance"
  rg -q "database|DB" "icontext-init/templates/$file" ||
    fail "$file must require DB confirmation"
done

for procedure in icontext-init/PROCEDURE.md icontext-update/PROCEDURE.md icontext-audit/PROCEDURE.md; do
  rg -q "\.icontext/hooks/" "$procedure" || fail "$procedure must cover the project safety hook"
  rg -q "per-invocation|exact command" "$procedure" ||
    fail "$procedure must enforce per-invocation confirmation"
done

guard="icontext-init/templates/.icontext/hooks/guard-command.sh"
test_guard_allows() {
  local command_text="$1"
  local output
  output="$("$guard" "$command_text")"
  test "$output" = "{}" || fail "safety guard should allow: $command_text (got: $output)"
}

test_guard_asks() {
  local command_text="$1"
  local output
  output="$("$guard" "$command_text")"
  printf '%s' "$output" | rg -q '"permissionDecision":"ask"' ||
    fail "safety guard should ask: $command_text (got: $output)"
}

test_guard_allows "git status --short"
test_guard_allows "rg -n seed src"
test_guard_allows "rg -n DB_SEED_ON_START docs"
test_guard_asks "git commit -m test"
test_guard_asks "git push origin main"
test_guard_asks "psql -c 'SELECT 1'"
test_guard_asks "pnpm run db:seed"
test_guard_asks "npx prisma migrate deploy"
test_guard_asks "DB_SEED_ON_START=true npm start"

json_output="$(printf '%s' '{"tool_input":{"command":"git push origin main"}}' | "$guard")"
printf '%s' "$json_output" | rg -q '"permissionDecision":"ask"' ||
  fail "safety guard must parse restricted commands from hook JSON"

for file in \
  icontext-init/templates/plans/_TEMPLATE/ops.md \
  icontext-feature/templates/plan-template/ops.md; do
  rg -q "Agent execution safety gate" "$file" ||
    fail "$file must include per-invocation mutation approval guidance"
done

for file in README.md bu.md po.md dev.md qa.md ops.md stk.md; do
  require_file "icontext-init/templates/plans/_TEMPLATE/$file"
  require_file "icontext-feature/templates/plan-template/$file"
done

for section in 3 4 5 6 7; do
  rg -q "^### $section\\." icontext-init/templates/DEV.md ||
    fail "DEV.md must own section $section"
  rg -q "Moved to \\[DEV\\.md\\].*§$section" icontext-init/templates/CONTEXT.md ||
    fail "CONTEXT.md must point section $section to DEV.md"
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

if rg -n "^version:" icontext-init/SKILL.md icontext-update/SKILL.md icontext-audit/SKILL.md icontext-visualize/SKILL.md icontext-feature/SKILL.md >/dev/null; then
  fail "SKILL.md frontmatter must not contain version; use VERSION files"
fi

validator="$HOME/.codex/skills/.system/skill-creator/scripts/quick_validate.py"
if command -v python3 >/dev/null && test -f "$validator"; then
  for skill in icontext-init icontext-update icontext-audit icontext-visualize icontext-feature; do
    python3 "$validator" "$skill"
  done
else
  echo "WARN: skipped Codex quick_validate.py (python3 or validator not found)"
fi

if command -v node >/dev/null; then
  node --check icontext-visualize/scripts/export-context-graph.js
else
  echo "WARN: skipped exporter syntax check (node not found)"
fi

echo "OK: iContext validation passed"
