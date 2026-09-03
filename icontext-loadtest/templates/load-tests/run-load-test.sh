#!/usr/bin/env bash
# ./run-load-test.sh --env-file ./load-test.env --scenario soft

[ -n "${BASH_VERSION:-}" ] || exec bash "$0" "$@"
set -euo pipefail
shopt -s extglob

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

trim() {
  local value="$1"
  value="${value##+([[:space:]])}"
  value="${value%%+([[:space:]])}"
  printf '%s' "$value"
}

load_env_file() {
  local env_file="$1"
  if [[ ! -r "$env_file" ]]; then
    echo "env file is missing or unreadable: $env_file" >&2
    exit 1
  fi

  local line key value
  while IFS= read -r line || [[ -n "$line" ]]; do
    line="${line%$'\r'}"
    line="$(trim "$line")"
    [[ -z "$line" || "$line" == \#* ]] && continue
    if [[ "$line" != *=* ]]; then
      echo "invalid env line (expected KEY=VALUE): $line" >&2
      exit 1
    fi

    key="$(trim "${line%%=*}")"
    value="$(trim "${line#*=}")"
    if [[ ! "$key" =~ ^[A-Za-z_][A-Za-z0-9_]*$ ]]; then
      echo "invalid env key: $key" >&2
      exit 1
    fi
    if [[ "$value" == \"*\" && "$value" == *\" ]]; then
      value="${value:1:${#value}-2}"
    elif [[ "$value" == \'*\' && "$value" == *\' ]]; then
      value="${value:1:${#value}-2}"
    fi

    # Explicit shell environment wins over the file.
    if [[ -z "${!key+x}" ]]; then
      export "$key=$value"
    fi
  done < "$env_file"
}

env_file="${LOAD_TEST_ENV_FILE:-}"
selected_scenario="${LOAD_TEST_SCENARIO:-}"
selected_flow="${LOAD_TEST_FLOW:-}"
while [[ $# -gt 0 ]]; do
  case "$1" in
    --env-file)
      [[ -n "${2:-}" ]] || { echo "--env-file requires a path" >&2; exit 1; }
      env_file="$2"
      shift 2
      ;;
    --scenario)
      [[ -n "${2:-}" ]] || { echo "--scenario requires a name" >&2; exit 1; }
      selected_scenario="$2"
      shift 2
      ;;
    --flow)
      [[ -n "${2:-}" ]] || { echo "--flow requires a name" >&2; exit 1; }
      selected_flow="$2"
      shift 2
      ;;
    *)
      echo "usage: $0 [--env-file PATH] [--scenario PROFILE] [--flow ENDPOINT_SCENARIO]" >&2
      exit 1
      ;;
  esac
done
if [[ -n "$env_file" ]]; then
  load_env_file "$env_file"
fi

selected_scenario="${selected_scenario:-${LOAD_TEST_SCENARIO:-soft}}"
if [[ ! "$selected_scenario" =~ ^[a-z][a-z0-9_]*$ ]]; then
  echo "invalid scenario name: use lowercase letters, numbers and underscores" >&2
  exit 1
fi
scenario_key="$(printf '%s' "$selected_scenario" | tr '[:lower:]' '[:upper:]')"

scenario_value() {
  local setting="$1"
  local fallback="$2"
  local scenario_setting="SCENARIO_${scenario_key}_${setting}"
  local configured_value

  if configured_value="$(printenv "$setting" 2>/dev/null)"; then
    printf '%s' "$configured_value"
  elif configured_value="$(printenv "$scenario_setting" 2>/dev/null)"; then
    printf '%s' "$configured_value"
  else
    printf '%s' "$fallback"
  fi
}

selected_flow="${selected_flow:-$(scenario_value FLOW page_example)}"
if [[ ! "$selected_flow" =~ ^[a-z][a-z0-9_]*$ ]]; then
  echo "invalid flow name: use lowercase letters, numbers and underscores" >&2
  exit 1
fi

: "${LOAD_TEST_TARGET:?set LOAD_TEST_TARGET=staging}"
: "${LOAD_TEST_READ_ONLY:?set LOAD_TEST_READ_ONLY=true}"
: "${LOAD_TEST_DB_ISOLATED:?set LOAD_TEST_DB_ISOLATED=true only after verifying the target DB is isolated}"
: "${LOAD_TEST_ALLOWED_HOST:?set LOAD_TEST_ALLOWED_HOST to the exact staging host}"
: "${LOAD_TEST_BLOCKED_HOSTS:?set LOAD_TEST_BLOCKED_HOSTS to a comma-separated production host list}"
: "${BASE_URL:?set BASE_URL to the staging API URL}"
: "${LOAD_TEST_ACCOUNTS_FILE:?set LOAD_TEST_ACCOUNTS_FILE to a protected account JSON file}"
: "${SUMMARY_EXPORT:?set SUMMARY_EXPORT to a protected output JSON path}"

JOURNEYS_PER_TIME_UNIT="$(scenario_value JOURNEYS_PER_TIME_UNIT 1)"
JOURNEY_TIME_UNIT="$(scenario_value JOURNEY_TIME_UNIT 1s)"
DURATION="$(scenario_value DURATION 2m)"
PRE_ALLOCATED_VUS="$(scenario_value PRE_ALLOCATED_VUS 20)"
MAX_VUS="$(scenario_value MAX_VUS 100)"
GRACEFUL_STOP="$(scenario_value GRACEFUL_STOP 2s)"
RUN_TIMEOUT_SECONDS="$(scenario_value RUN_TIMEOUT_SECONDS 300)"
EXECUTOR="$(scenario_value EXECUTOR constant-arrival-rate)"
START_RATE="$(scenario_value START_RATE 1)"
RAMP_STAGES="$(scenario_value RAMP_STAGES '[]')"
VUS="$(scenario_value VUS 1)"
ITERATIONS_PER_VU="$(scenario_value ITERATIONS_PER_VU 1)"
MAX_DURATION="$(scenario_value MAX_DURATION 1m)"
THINK_TIME_SECONDS="$(scenario_value THINK_TIME_SECONDS 0)"
BATCH_SIZE="$(scenario_value BATCH_SIZE 12)"
BATCH_PER_HOST="$(scenario_value BATCH_PER_HOST 12)"
MAX_IN_FLIGHT_REQUESTS="$(scenario_value MAX_IN_FLIGHT_REQUESTS 0)"

if [[ ! "$JOURNEYS_PER_TIME_UNIT" =~ ^[1-9][0-9]*$ ]]; then
  echo "JOURNEYS_PER_TIME_UNIT must be a positive integer" >&2
  exit 1
fi
if [[ ! "$JOURNEY_TIME_UNIT" =~ ^[1-9][0-9]*(ms|s|m|h)$ ]]; then
  echo "JOURNEY_TIME_UNIT must look like 500ms, 10s, 1m or 1h" >&2
  exit 1
fi
if [[ ! "$DURATION" =~ ^[1-9][0-9]*(ms|s|m|h)$ ]]; then
  echo "DURATION must look like 20s, 5m or 1h" >&2
  exit 1
fi
if [[ ! "$GRACEFUL_STOP" =~ ^[0-9]+(ms|s|m)$ ]]; then
  echo "GRACEFUL_STOP must look like 0s, 500ms, 2s or 1m" >&2
  exit 1
fi
if [[ ! "$PRE_ALLOCATED_VUS" =~ ^[1-9][0-9]*$ || ! "$MAX_VUS" =~ ^[1-9][0-9]*$ ]]; then
  echo "PRE_ALLOCATED_VUS and MAX_VUS must be positive integers" >&2
  exit 1
fi
if (( PRE_ALLOCATED_VUS > MAX_VUS )); then
  echo "PRE_ALLOCATED_VUS cannot exceed MAX_VUS" >&2
  exit 1
fi
if [[ ! "$RUN_TIMEOUT_SECONDS" =~ ^[1-9][0-9]*$ ]]; then
  echo "RUN_TIMEOUT_SECONDS must be a positive integer" >&2
  exit 1
fi
case "$EXECUTOR" in
  constant-arrival-rate|ramping-arrival-rate|per-vu-iterations|constant-vus) ;;
  *) echo "unsupported EXECUTOR: $EXECUTOR" >&2; exit 1 ;;
esac
for positive_integer in START_RATE VUS ITERATIONS_PER_VU BATCH_SIZE BATCH_PER_HOST; do
  if [[ ! "${!positive_integer}" =~ ^[1-9][0-9]*$ ]]; then
    echo "$positive_integer must be a positive integer" >&2
    exit 1
  fi
done
if (( BATCH_PER_HOST > BATCH_SIZE )); then
  echo "BATCH_PER_HOST cannot exceed BATCH_SIZE" >&2
  exit 1
fi
if [[ ! "$THINK_TIME_SECONDS" =~ ^[0-9]+([.][0-9]+)?$ ]]; then
  echo "THINK_TIME_SECONDS must be zero or a positive number" >&2
  exit 1
fi
if [[ ! "$MAX_IN_FLIGHT_REQUESTS" =~ ^[0-9]+$ ]]; then
  echo "MAX_IN_FLIGHT_REQUESTS must be zero or a positive integer" >&2
  exit 1
fi
if [[ ! "$MAX_DURATION" =~ ^[1-9][0-9]*(ms|s|m|h)$ ]]; then
  echo "MAX_DURATION must look like 30s, 5m or 1h" >&2
  exit 1
fi

if [[ "$LOAD_TEST_TARGET" != "staging" ]]; then
  echo "refusing target: LOAD_TEST_TARGET must be staging" >&2
  exit 1
fi
if [[ "$LOAD_TEST_READ_ONLY" != "true" ]]; then
  echo "refusing target: LOAD_TEST_READ_ONLY must be true" >&2
  exit 1
fi
if [[ "$LOAD_TEST_DB_ISOLATED" != "true" ]]; then
  echo "refusing target: staging must use an isolated database" >&2
  exit 1
fi
if [[ "$BASE_URL" != https://* ]]; then
  echo "refusing target: BASE_URL must use HTTPS" >&2
  exit 1
fi

target_host="${BASE_URL#https://}"
target_host="${target_host%%/*}"
if [[ "$target_host" != "$LOAD_TEST_ALLOWED_HOST" ]]; then
  echo "refusing target: BASE_URL host does not match LOAD_TEST_ALLOWED_HOST" >&2
  exit 1
fi

IFS=',' read -r -a blocked_hosts <<< "$LOAD_TEST_BLOCKED_HOSTS"
for blocked_host in "${blocked_hosts[@]}"; do
  blocked_host="${blocked_host//[[:space:]]/}"
  if [[ -n "$blocked_host" && "$target_host" == "$blocked_host" ]]; then
    echo "refusing blocked host: $target_host" >&2
    exit 1
  fi
done

if ! command -v k6 >/dev/null 2>&1; then
  echo "k6 is not installed or not in PATH" >&2
  exit 1
fi
if [[ ! -r "$LOAD_TEST_ACCOUNTS_FILE" ]]; then
  echo "account file is missing or unreadable" >&2
  exit 1
fi
if [[ ! -d "$(dirname "$SUMMARY_EXPORT")" ]]; then
  echo "summary output directory does not exist" >&2
  exit 1
fi
for output_file in "${COMBINED_REPORT:-}" "${K6_WEB_DASHBOARD_EXPORT:-}"; do
  if [[ -n "$output_file" && ! -d "$(dirname "$output_file")" ]]; then
    echo "report output directory does not exist: $(dirname "$output_file")" >&2
    exit 1
  fi
done

export LOAD_TEST_TARGET LOAD_TEST_READ_ONLY LOAD_TEST_ALLOWED_HOST LOAD_TEST_BLOCKED_HOSTS
export LOAD_TEST_SCENARIO="$selected_scenario"
export LOAD_TEST_FLOW="$selected_flow"
export K6_LINGER=false
export BASE_URL LOAD_TEST_ACCOUNTS_FILE JOURNEYS_PER_TIME_UNIT JOURNEY_TIME_UNIT DURATION PRE_ALLOCATED_VUS MAX_VUS GRACEFUL_STOP
export EXECUTOR START_RATE RAMP_STAGES VUS ITERATIONS_PER_VU MAX_DURATION THINK_TIME_SECONDS BATCH_SIZE BATCH_PER_HOST
export MAX_IN_FLIGHT_REQUESTS

echo "Target: $BASE_URL"
echo "Scenario: $selected_scenario"
echo "Endpoint flow: $selected_flow"
echo "Executor: $EXECUTOR"
case "$EXECUTOR" in
  constant-arrival-rate)
    echo "Rate: $JOURNEYS_PER_TIME_UNIT journey(s) per $JOURNEY_TIME_UNIT for $DURATION"
    ;;
  ramping-arrival-rate)
    echo "Start rate: $START_RATE journey(s) per $JOURNEY_TIME_UNIT"
    echo "Ramp stages: $RAMP_STAGES"
    ;;
  per-vu-iterations)
    echo "Concurrency: $VUS VUs, $ITERATIONS_PER_VU iteration(s) each, max $MAX_DURATION"
    ;;
  constant-vus)
    echo "Concurrency: $VUS VUs for $DURATION, think time ${THINK_TIME_SECONDS}s"
    ;;
esac
echo "Batch concurrency: $BATCH_PER_HOST per host"
if (( MAX_IN_FLIGHT_REQUESTS > 0 )); then
  if [[ "$EXECUTOR" == "constant-vus" || "$EXECUTOR" == "per-vu-iterations" ]]; then
    concurrency_vus="$VUS"
  else
    concurrency_vus="$MAX_VUS"
  fi
  configured_in_flight=$((concurrency_vus * BATCH_PER_HOST))
  if (( configured_in_flight > MAX_IN_FLIGHT_REQUESTS )); then
    echo "refusing config: VU ceiling × BATCH_PER_HOST = $configured_in_flight exceeds MAX_IN_FLIGHT_REQUESTS=$MAX_IN_FLIGHT_REQUESTS" >&2
    exit 1
  fi
  echo "In-flight request cap: $MAX_IN_FLIGHT_REQUESTS (configured ceiling: $configured_in_flight)"
fi
echo "Graceful stop: $GRACEFUL_STOP"
echo "Watchdog: $RUN_TIMEOUT_SECONDS seconds"
echo "Accounts: $LOAD_TEST_ACCOUNTS_FILE"
echo "Summary: $SUMMARY_EXPORT"
if [[ -n "${COMBINED_REPORT:-}" ]]; then
  echo "Combined report: $COMBINED_REPORT"
fi
if [[ -n "$env_file" ]]; then
  echo "Config: $env_file"
fi
echo "Starting requires the operator's explicit approval for this exact environment and stage."

set +e
k6 run \
  --summary-export="$SUMMARY_EXPORT" \
  "$script_dir/load-test.js" &
k6_pid=$!
run_status=0
timed_out=false

forward_stop() {
  kill -INT "$k6_pid" 2>/dev/null || true
}
trap forward_stop INT TERM

deadline=$((SECONDS + RUN_TIMEOUT_SECONDS))
while kill -0 "$k6_pid" 2>/dev/null; do
  if (( SECONDS >= deadline )); then
    echo "k6 exceeded the ${RUN_TIMEOUT_SECONDS}s watchdog; stopping PID $k6_pid" >&2
    kill -INT "$k6_pid" 2>/dev/null || true
    timed_out=true
    break
  fi
  sleep 1
done

if [[ "$timed_out" == "true" ]]; then
  for _ in 1 2 3 4 5; do
    kill -0 "$k6_pid" 2>/dev/null || break
    sleep 1
  done
  if kill -0 "$k6_pid" 2>/dev/null; then
    kill -TERM "$k6_pid" 2>/dev/null || true
    sleep 1
  fi
  if kill -0 "$k6_pid" 2>/dev/null; then
    kill -KILL "$k6_pid" 2>/dev/null || true
  fi
fi

wait "$k6_pid"
run_status=$?
trap - INT TERM
if [[ "$timed_out" == "true" ]]; then
  run_status=124
fi
set -e

if [[ -n "${COMBINED_REPORT:-}" && ! -s "$COMBINED_REPORT" ]]; then
  echo "combined report was not created: $COMBINED_REPORT" >&2
  [[ $run_status -ne 0 ]] && exit "$run_status"
  exit 1
fi

exit "$run_status"
