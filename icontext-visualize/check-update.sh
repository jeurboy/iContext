#!/usr/bin/env bash
# Thin stub — every icontext-* skill shares ONE real script. The logic lives in
# scripts/check-update.sh (at the repo root, or in ${ICONTEXT_HOME:-~/.icontext}/scripts/).
# Never edit per-skill copies; edit the shared script only.
set -uo pipefail
HERE="$(cd "$(dirname "$0")" && pwd)"
SKILL="$(basename "$HERE")"
LOCAL="$(cat "$HERE/VERSION" 2>/dev/null | tr -d '[:space:]')"
for shared in "$HERE/../scripts/check-update.sh" "${ICONTEXT_HOME:-$HOME/.icontext}/scripts/check-update.sh"; do
  if [ -f "$shared" ]; then exec bash "$shared" "$SKILL" "${LOCAL:-0.0.0}"; fi
done
echo "iContext: ${SKILL} update check skipped (shared scripts/check-update.sh not found) — local ${LOCAL:-0.0.0}"
exit 0
