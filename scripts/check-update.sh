#!/usr/bin/env bash
# Shared best-effort update check for every iContext skill. Prints ONE line per skill; never fails or blocks.
#
# Usage:
#   scripts/check-update.sh [skill [local-version]] ...   # no args = check every icontext-* folder next to this script
#
# Each skill folder's check-update.sh is a thin stub that execs THIS file, passing the skill name
# and the stub's OWN VERSION (so the answer is right no matter which install root the shared script
# lives in). The logic lives here only — never edit per-skill copies.
set -uo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"   # works from the repo root and from the ~/.icontext cache
HAD_ARGS="$#"

check_one() {
  local skill="$1" local_ver="${2:-}" remote newest
  if [ -z "$local_ver" ]; then
    local_ver="$(cat "$ROOT/$skill/VERSION" 2>/dev/null | tr -d '[:space:]')"
  fi
  local_ver="${local_ver:-0.0.0}"
  remote="$(curl -fsSL --max-time 4 "https://raw.githubusercontent.com/jeurboy/iContext/main/$skill/VERSION" 2>/dev/null | tr -d '[:space:]' || true)"
  if [ -z "$remote" ]; then
    echo "iContext: ${skill} update check skipped (offline or not yet published) — local ${local_ver}"
  elif [ "$remote" = "$local_ver" ]; then
    echo "iContext: ${skill} up to date (${local_ver})"
  else
    newest="$(printf '%s\n%s\n' "$local_ver" "$remote" | sort -V | tail -1)"
    if [ "$newest" = "$remote" ]; then
      echo "iContext: update available for ${skill} (${local_ver} -> ${remote}). Update: run /icontext-self-update (or cd <iContext> && git pull && ./install.sh)"
    else
      echo "iContext: ${skill} is ahead of upstream (${local_ver} > ${remote})"
    fi
  fi
}

while [ "$#" -gt 0 ]; do
  check_one "$1" "${2:-}"
  if [ "$#" -ge 2 ]; then shift 2; else shift; fi
done
if [ "$HAD_ARGS" -eq 0 ]; then
  for d in "$ROOT"/icontext-*; do [ -d "$d" ] && check_one "$(basename "$d")" ""; done
fi
exit 0
