#!/usr/bin/env bash
# Best-effort update check for an iContext skill. Prints ONE line; never fails or blocks.
# Compares local VERSION against the published VERSION on GitHub for this skill.
set -uo pipefail
HERE="$(cd "$(dirname "$0")" && pwd)"
SKILL="$(basename "$HERE")"
LOCAL="$(tr -d '[:space:]' < "$HERE/VERSION" 2>/dev/null || echo 0.0.0)"
URL="https://raw.githubusercontent.com/jeurboy/iContext/main/${SKILL}/VERSION"

REMOTE="$(curl -fsSL --max-time 4 "$URL" 2>/dev/null | tr -d '[:space:]' || true)"
if [ -z "$REMOTE" ]; then
  echo "iContext: ${SKILL} update check skipped (offline or not yet published) — local ${LOCAL}"
  exit 0
fi
if [ "$REMOTE" = "$LOCAL" ]; then
  echo "iContext: ${SKILL} up to date (${LOCAL})"
else
  newest="$(printf '%s\n%s\n' "$LOCAL" "$REMOTE" | sort -V | tail -1)"
  if [ "$newest" = "$REMOTE" ]; then
    echo "iContext: update available for ${SKILL} (${LOCAL} -> ${REMOTE}). Update: cd <iContext> && git pull && ./install.sh"
  else
    echo "iContext: ${SKILL} is ahead of upstream (${LOCAL} > ${REMOTE})"
  fi
fi
exit 0
