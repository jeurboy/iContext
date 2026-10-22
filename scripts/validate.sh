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

for skill in icontext-init icontext-update icontext-audit icontext-visualize icontext-feature icontext-feature-review icontext-loadtest icontext-self-update; do
  require_file "$skill/SKILL.md"
  require_file "$skill/PROCEDURE.md"
  require_file "$skill/VERSION"
  require_executable "$skill/check-update.sh"
  require_file "$skill/adapters/claude.md"
  require_file "$skill/adapters/codex.md"
  require_file "$skill/adapters/cursor.md"
  require_file "$skill/adapters/gemini.md"
  # every check-update.sh must be the same thin stub pointing at the ONE shared script
  rg -q "scripts/check-update\.sh" "$skill/check-update.sh" ||
    fail "$skill/check-update.sh must be a stub that execs the shared scripts/check-update.sh"
done

require_executable "scripts/check-update.sh"
stub_count="$(cksum icontext-*/check-update.sh | awk '{print $1}' | sort -u | wc -l | tr -d '[:space:]')"
[ "$stub_count" = "1" ] ||
  fail "all skill check-update.sh stubs must be identical copies"

require_executable "icontext-visualize/scripts/export-context-graph.js"
require_executable "icontext-loadtest/templates/load-tests/run-load-test.sh"
require_executable "icontext-init/templates/.icontext/hooks/guard-command.sh"
require_file "icontext-init/templates/.icontext/hooks/POLICY.md"

for file in \
  icontext-init/templates/CLAUDE.md \
  icontext-init/templates/AGENTS.md \
  icontext-init/templates/AGENT.md \
  icontext-init/templates/GEMINI.md \
  icontext-init/templates/CONTEXT.md \
  icontext-init/templates/context/DEV.md \
  icontext-init/templates/context/PRODUCT.md \
  icontext-init/templates/context/QA.md \
  icontext-init/templates/context/SECURITY.md \
  icontext-init/templates/context/DESIGN.md \
  icontext-init/templates/context/SKILLS.md \
  icontext-init/templates/context/ROLE.md \
  icontext-init/templates/PLAN.md \
  icontext-init/templates/docker-compose.yml \
  icontext-init/templates/docs/openapi.yaml \
  icontext-init/templates/.vscode/launch.json \
  icontext-init/templates/styles/css/tokens.css \
  icontext-init/templates/styles/components/button.html; do
  require_file "$file"
done

rg -q "^### 10\." icontext-init/templates/context/SKILLS.md ||
  fail "SKILLS.md must own section 10"
rg -q "/investigate" icontext-init/templates/context/SKILLS.md ||
  fail "SKILLS.md must route system bugs through gstack /investigate"
rg -q "https://github\.com/garrytan/gstack\.git" icontext-init/templates/context/SKILLS.md ||
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

for file in CLAUDE.md AGENTS.md AGENT.md GEMINI.md; do
  rg -q "context/DEV\.md" "icontext-init/templates/$file" ||
    fail "$file must point agents at the context/ L2 folder"
done

for file in \
  icontext-init/templates/plans/_TEMPLATE/README.md \
  icontext-feature/templates/plan-template/README.md; do
  rg -q "\.\./\.\./context/SKILLS\.md" "$file" ||
    fail "$file must link to context/SKILLS.md"
done

rg -q "\]\(\./context/DEV\.md\)" icontext-init/templates/CONTEXT.md ||
  fail "CONTEXT.md must link the context map into the context/ folder"
rg -q "Step 5\.7" icontext-update/PROCEDURE.md ||
  fail "icontext-update must define Step 5.7 for the legacy context/ relocation"
rg -q "relocate candidate" icontext-audit/PROCEDURE.md ||
  fail "icontext-audit must flag root-level concern files as a relocate candidate"
rg -q "resolveL2" icontext-visualize/scripts/export-context-graph.js ||
  fail "context graph exporter must resolve L2 files in context/ and at the root"

rg -q "(§10.*SKILLS\.md|SKILLS\.md.*§10)" icontext-update/PROCEDURE.md ||
  fail "icontext-update must migrate legacy section 10 into SKILLS.md"
rg -q "/investigate" icontext-update/PROCEDURE.md ||
  fail "icontext-update must backfill the gstack /investigate bug route"
rg -q "name: 'SKILLS\.md'" icontext-visualize/scripts/export-context-graph.js ||
  fail "context graph exporter must include SKILLS.md"
rg -q "which page|page/screen/route" icontext-loadtest/PROCEDURE.md ||
  fail "icontext-loadtest must ask for the target page every invocation"
rg -q "Default to GET-only" icontext-loadtest/PROCEDURE.md ||
  fail "icontext-loadtest must default to GET-only"
rg -q "ALLOW_NON_GET=false" icontext-loadtest/templates/load-tests/load-test.env.example ||
  fail "load-test env template must block non-GET routes by default"
rg -Fq 'page_example: scenario("page_example", null' icontext-loadtest/templates/load-tests/endpoints.js ||
  fail "load-test endpoint template must default its mock page to GET-only auth"
if rg -ni "calcounter|cold[ _-]home|nutrition-goals|refresh_tokens" icontext-loadtest/templates >/dev/null; then
  fail "load-test templates must contain only generic mock data"
fi
rg -q "icontext-loadtest" icontext-init/templates/context/DEV.md ||
  fail "DEV.md must document icontext-loadtest tooling"
rg -q "icontext-loadtest" icontext-init/templates/context/SKILLS.md ||
  fail "SKILLS.md must route load-test work to icontext-loadtest"
rg -q "icontext-feature-review" icontext-init/templates/context/SKILLS.md ||
  fail "SKILLS.md must route plan reviews to icontext-feature-review"
rg -q "icontext-self-update" icontext-init/templates/context/SKILLS.md ||
  fail "SKILLS.md must route skill updates to icontext-self-update"
rg -q "resolving-merge-conflicts" icontext-init/templates/context/DEV.md ||
  fail "DEV.md must document the resolving-merge-conflicts workflow"
rg -q "resolving-merge-conflicts" icontext-init/templates/context/SKILLS.md ||
  fail "SKILLS.md must route merge conflicts to resolving-merge-conflicts"
rg -q "resolving-merge-conflicts" icontext-update/PROCEDURE.md ||
  fail "icontext-update must backfill the resolving-merge-conflicts route"
rg -q "resolving-merge-conflicts" icontext-audit/PROCEDURE.md ||
  fail "icontext-audit must check the resolving-merge-conflicts route"
rg -q "to-spec" icontext-init/templates/context/SKILLS.md ||
  fail "SKILLS.md must route tracker-spec requests to to-spec"
rg -q "to-spec" icontext-update/PROCEDURE.md ||
  fail "icontext-update must backfill the to-spec route"
rg -q "to-spec" icontext-audit/PROCEDURE.md ||
  fail "icontext-audit must check the to-spec route"
rg -q 'code-review` \(mattpocock\)' icontext-init/templates/context/SKILLS.md ||
  fail "SKILLS.md must route standards/spec reviews to the mattpocock code-review skill"
rg -q 'mattpocock `code-review`' icontext-update/PROCEDURE.md ||
  fail "icontext-update must backfill the mattpocock code-review route"
rg -q 'mattpocock `code-review`' icontext-audit/PROCEDURE.md ||
  fail "icontext-audit must check the mattpocock code-review route"
rg -q 'implement` \(mattpocock\)' icontext-init/templates/context/SKILLS.md ||
  fail "SKILLS.md must route user-invoked implementation to the mattpocock implement skill"
rg -q 'implement` \(mattpocock\)' icontext-init/templates/context/DEV.md ||
  fail "DEV.md must document the mattpocock implement execution flow"
rg -q 'mattpocock `implement`' icontext-update/PROCEDURE.md ||
  fail "icontext-update must backfill the mattpocock implement route"
rg -q 'mattpocock `implement`' icontext-audit/PROCEDURE.md ||
  fail "icontext-audit must check the mattpocock implement route"
rg -q "poteto-mode" icontext-init/templates/context/SKILLS.md ||
  fail "SKILLS.md must route user-invoked poteto-style runs to poteto-mode"
rg -q "https://github\.com/michael-denyer/pstack-claude\.git" icontext-init/templates/context/SKILLS.md ||
  fail "SKILLS.md must include the upstream pstack-claude Git URL"
rg -q "poteto-mode" icontext-update/PROCEDURE.md ||
  fail "icontext-update must backfill the poteto-mode route"
rg -q "poteto-mode" icontext-audit/PROCEDURE.md ||
  fail "icontext-audit must check the poteto-mode route"
rg -q "AGENTS.md.*agents.md" icontext-init/PROCEDURE.md ||
  fail "icontext-init must recognize AGENTS.md/agents.md aliases"
rg -q "AGENT.md.*agent.md" icontext-update/PROCEDURE.md ||
  fail "icontext-update must recognize AGENT.md/agent.md aliases"
rg -q "AGENTS.md.*agents.md" icontext-audit/PROCEDURE.md ||
  fail "icontext-audit must recognize AGENTS.md/agents.md aliases"
rg -q "agents.md" icontext-visualize/scripts/export-context-graph.js ||
  fail "context graph exporter must discover lowercase agent aliases"
rg -q "agents_pointer_target" install.sh ||
  fail "installer must preserve an existing lowercase agents.md target"
rg -q "Offer page-specific load-test scaffolding every run" icontext-update/PROCEDURE.md ||
  fail "icontext-update must offer load-test scaffolding every run"
rg -q "Offer page-specific load-test scaffolding every run" icontext-audit/PROCEDURE.md ||
  fail "icontext-audit must offer load-test scaffolding every run"
rg -q "ff-only" icontext-self-update/PROCEDURE.md ||
  fail "icontext-self-update must use ff-only pulls only"
rg -q "skills-lock\.json" icontext-self-update/PROCEDURE.md ||
  fail "icontext-self-update must cover dependency skills via skills-lock.json"
rg -q "npx.*skills@latest update" icontext-self-update/PROCEDURE.md ||
  fail "icontext-self-update must update dependency skills through the Skills CLI"
rg -q "restart" icontext-self-update/PROCEDURE.md ||
  fail "icontext-self-update must remind the user to restart the agent app"

for file in \
  README.md \
  RESULT_TEMPLATE.md \
  accounts.example.json \
  load-test.js \
  db-verification.sql \
  endpoints.js \
  load-test.env.example \
  run-load-test.sh; do
  require_file "icontext-loadtest/templates/load-tests/$file"
done

test ! -e icontext-loadtest/templates/load-tests/load-test.env ||
  fail "load-test template must not include a real load-test.env"
test ! -e icontext-loadtest/templates/load-tests/accounts.json ||
  fail "load-test template must not include real accounts.json"
test ! -d icontext-loadtest/templates/load-tests/result ||
  fail "load-test template must not include result artifacts"

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
  rg -q "^### $section\\." icontext-init/templates/context/DEV.md ||
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

if rg -n "^version:" icontext-init/SKILL.md icontext-update/SKILL.md icontext-audit/SKILL.md icontext-visualize/SKILL.md icontext-feature/SKILL.md icontext-loadtest/SKILL.md icontext-self-update/SKILL.md >/dev/null; then
  fail "SKILL.md frontmatter must not contain version; use VERSION files"
fi

validator="$HOME/.codex/skills/.system/skill-creator/scripts/quick_validate.py"
if command -v python3 >/dev/null && test -f "$validator"; then
  for skill in icontext-init icontext-update icontext-audit icontext-visualize icontext-feature icontext-loadtest icontext-self-update; do
    python3 "$validator" "$skill"
  done
else
  echo "WARN: skipped Codex quick_validate.py (python3 or validator not found)"
fi

if command -v node >/dev/null; then
  node --check icontext-visualize/scripts/export-context-graph.js
  node --input-type=module --check < icontext-loadtest/templates/load-tests/endpoints.js
  node --input-type=module --check < icontext-loadtest/templates/load-tests/load-test.js
else
  echo "WARN: skipped exporter syntax check (node not found)"
fi

echo "OK: iContext validation passed"
