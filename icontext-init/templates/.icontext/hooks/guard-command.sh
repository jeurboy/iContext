#!/usr/bin/env bash
# Project safety hook for AI shell/tool commands.
# Input: a plain command argument, a plain command on stdin, or hook JSON containing a command.
# Output: {} to allow, or a permissionDecision=ask response for a restricted action.
set -euo pipefail

input=""
if [ "$#" -gt 0 ]; then
  input="$*"
else
  input="$(command cat)"
fi

extract_command() {
  local raw="$1"

  if command -v python3 >/dev/null 2>&1; then
    local parsed
    parsed="$(printf '%s' "$raw" | python3 -c '
import json
import sys

raw = sys.stdin.read()
try:
    value = json.loads(raw)
except Exception:
    print(raw)
    raise SystemExit

def find_command(node):
    if isinstance(node, dict):
        for key in ("command", "cmd", "script"):
            candidate = node.get(key)
            if isinstance(candidate, str) and candidate.strip():
                return candidate
        for key in ("tool_input", "input", "arguments", "params"):
            candidate = find_command(node.get(key))
            if candidate:
                return candidate
    return ""

print(find_command(value))
' 2>/dev/null || true)"
    if [ -n "$parsed" ]; then
      printf '%s' "$parsed"
      return
    fi
  fi

  # Minimal fallback for common hook JSON. Plain text passes through unchanged.
  local parsed
  parsed="$(printf '%s' "$raw" | sed -n 's/.*"command"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' | head -1)"
  if [ -n "$parsed" ]; then
    printf '%s' "$parsed"
  elif ! printf '%s' "$raw" | grep -q '^[[:space:]]*[{[]'; then
    printf '%s' "$raw"
  fi
}

command_text="$(extract_command "$input")"
command_lower="$(printf '%s' "$command_text" | tr '[:upper:]' '[:lower:]')"

reason=""

# Block every commit and every push, not only force-push. Read-only git commands stay allowed.
git_write_re='(^|[;&|][;&|]?)[[:space:]]*(sudo[[:space:]]+)?(command[[:space:]]+)?git([[:space:]]+(-C|-c|--git-dir|--work-tree)[[:space:]]+[^[:space:];&|]+)*[[:space:]]+(commit|push)([[:space:]]|$)'
if printf '%s' "$command_text" | grep -Eq "$git_write_re" 2>/dev/null; then
  if printf '%s' "$command_text" | grep -Eq '(^|[;&|][;&|]?)[[:space:]]*(sudo[[:space:]]+)?(command[[:space:]]+)?git([^;&|]*)[[:space:]]commit([[:space:]]|$)' 2>/dev/null; then
    reason="git commit"
  else
    reason="git push"
  fi
fi

# Direct database clients require confirmation even for a read-only query: connecting to the
# wrong environment can still expose data or trigger session-side behavior.
db_client_re='(^|[;&|][;&|]?)[[:space:]]*(sudo[[:space:]]+)?(command[[:space:]]+)?(psql|mysql|mysqlsh|sqlite3|mongosh|mongo|redis-cli|clickhouse-client|cqlsh|sqlcmd|pg_restore|pg_dump|mysqldump|mongorestore|mongodump)([[:space:]]|$)'
docker_db_client_re='(^|[;&|][;&|]?)[[:space:]]*(sudo[[:space:]]+)?(docker|podman)[[:space:]]+([^;&|]*[[:space:]])?(psql|mysql|mysqlsh|sqlite3|mongosh|mongo|redis-cli|clickhouse-client|cqlsh|sqlcmd|pg_restore|pg_dump|mysqldump|mongorestore|mongodump)([[:space:]]|$)'
if [ -z "$reason" ] && { printf '%s' "$command_lower" | grep -Eq "$db_client_re" 2>/dev/null || printf '%s' "$command_lower" | grep -Eq "$docker_db_client_re" 2>/dev/null; }; then
  reason="direct database access"
fi

# Common migration, seed, reset, import, restore, and DB-push runners.
package_db_re='(^|[;&|][;&|]?)[[:space:]]*(sudo[[:space:]]+)?(npm|pnpm|yarn|bun)[[:space:]]+(run[[:space:]]+)?[^;&|]*(seed|migrat|db[:_-]?(push|reset|setup|import|restore|load))'
framework_db_re='(^|[;&|][;&|]?)[[:space:]]*(sudo[[:space:]]+)?(npx[[:space:]]+)?(prisma|sequelize|sequelize-cli|knex|typeorm|drizzle-kit|alembic)[[:space:]]+[^;&|]*(seed|migrat|upgrade|downgrade|db[[:space:]]+(push|seed|execute|reset))'
rails_db_re='(^|[;&|][;&|]?)[[:space:]]*(sudo[[:space:]]+)?(bundle[[:space:]]+exec[[:space:]]+)?(rails|rake)[[:space:]]+db:(seed|migrate|rollback|reset|drop|create|setup|prepare|restore)'
django_db_re='(^|[;&|][;&|]?)[[:space:]]*(sudo[[:space:]]+)?(python3?|uv[[:space:]]+run[[:space:]]+python)[[:space:]]+[^;&|]*manage\.py[[:space:]]+(migrate|flush|loaddata)'
script_db_re='(^|[;&|][;&|]?)[[:space:]]*(sudo[[:space:]]+)?(make|task|just|go[[:space:]]+run|python3?|node|bash|sh)[[:space:]]+[^;&|]*(seed|migrat|db[-_:]?(push|reset|setup|import|restore|load))'
if [ -z "$reason" ] && {
  printf '%s' "$command_lower" | grep -Eq "$package_db_re" 2>/dev/null ||
  printf '%s' "$command_lower" | grep -Eq "$framework_db_re" 2>/dev/null ||
  printf '%s' "$command_lower" | grep -Eq "$rails_db_re" 2>/dev/null ||
  printf '%s' "$command_lower" | grep -Eq "$django_db_re" 2>/dev/null ||
  printf '%s' "$command_lower" | grep -Eq "$script_db_re" 2>/dev/null;
}; then
  reason="database migration/seed/import/restore"
fi

# Environment switches often activate startup migrations or seed/import behavior.
db_env_re='(^|[;&|][;&|]?)[[:space:]]*(env[[:space:]]+)?([a-z0-9_]+=[^[:space:];&|]+[[:space:]]+)*[a-z0-9_]*(seed|migrat|snapshot|import|restore|load|db[a-z0-9_]*(push|reset|setup|import|restore|load))[a-z0-9_]*[[:space:]]*='
if [ -z "$reason" ] && printf '%s' "$command_lower" | grep -Eq "$db_env_re" 2>/dev/null; then
  reason="database-changing startup/config flag"
fi

json_escape() {
  printf '%s' "$1" | sed 's/\\/\\\\/g; s/"/\\"/g'
}

if [ -z "$command_text" ]; then
  message="[iContext safety] The hook could not inspect this command. Keep it blocked until the host adapter passes the shell command correctly."
  printf '{"permissionDecision":"ask","message":"%s"}\n' "$(json_escape "$message")"
elif [ -n "$reason" ]; then
  message="[iContext safety] Restricted action: $reason. Ask the user to confirm this exact action, target, and environment before running it. Do not reuse an earlier approval for another invocation."
  printf '{"permissionDecision":"ask","message":"%s"}\n' "$(json_escape "$message")"
else
  printf '{}\n'
fi
