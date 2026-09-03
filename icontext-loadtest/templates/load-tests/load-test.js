import http from "k6/http";
import { check, fail, group, sleep } from "k6";
import exec from "k6/execution";
import { Counter, Trend } from "k6/metrics";

import { getEndpointScenario } from "./endpoints.js";

const baseURL = (__ENV.BASE_URL || "").replace(/\/$/, "");
const accountsPath = __ENV.LOAD_TEST_ACCOUNTS_FILE || "";
const endpointScenario = getEndpointScenario(__ENV.LOAD_TEST_FLOW || "page_example");
const scenarioEndpoints = [endpointScenario.auth, ...endpointScenario.requests].filter(Boolean);
const journeyDuration = new Trend("journey_duration", true);
const logFailedResponses = __ENV.LOG_FAILED_RESPONSES === "true";
const endpointMetrics = {};
for (const endpoint of scenarioEndpoints) {
  endpointMetrics[endpoint.label] = {
    duration: new Trend(`rt_${endpoint.metricKey}`, true),
    requests: new Counter(`req_${endpoint.metricKey}`),
    responses: new Counter(`res_${endpoint.metricKey}`),
  };
}

if (!accountsPath) throw new Error("LOAD_TEST_ACCOUNTS_FILE is required");
const accounts = JSON.parse(open(accountsPath));

function parseRampStages() {
  let stages;
  try {
    stages = JSON.parse(__ENV.RAMP_STAGES || "[]");
  } catch (error) {
    throw new Error(`RAMP_STAGES must be valid JSON: ${error.message}`);
  }
  if (!Array.isArray(stages) || stages.length === 0) {
    throw new Error("RAMP_STAGES must contain at least one stage");
  }
  return stages;
}

function executionScenario() {
  const executor = __ENV.EXECUTOR || "constant-arrival-rate";
  const common = {
    exec: "runScenario",
    gracefulStop: __ENV.GRACEFUL_STOP || "2s",
    tags: {
      workload: endpointScenario.name,
      profile: __ENV.LOAD_TEST_SCENARIO || "custom",
      executor,
    },
  };

  if (executor === "constant-arrival-rate") {
    return {
      ...common,
      executor,
      rate: Number(__ENV.JOURNEYS_PER_TIME_UNIT || 1),
      timeUnit: __ENV.JOURNEY_TIME_UNIT || "1s",
      duration: __ENV.DURATION || "2m",
      preAllocatedVUs: Number(__ENV.PRE_ALLOCATED_VUS || 20),
      maxVUs: Number(__ENV.MAX_VUS || 100),
    };
  }
  if (executor === "ramping-arrival-rate") {
    return {
      ...common,
      executor,
      startRate: Number(__ENV.START_RATE || 1),
      timeUnit: __ENV.JOURNEY_TIME_UNIT || "1s",
      stages: parseRampStages(),
      preAllocatedVUs: Number(__ENV.PRE_ALLOCATED_VUS || 20),
      maxVUs: Number(__ENV.MAX_VUS || 100),
    };
  }
  if (executor === "per-vu-iterations") {
    return {
      ...common,
      executor,
      vus: Number(__ENV.VUS || 1),
      iterations: Number(__ENV.ITERATIONS_PER_VU || 1),
      maxDuration: __ENV.MAX_DURATION || "1m",
    };
  }
  if (executor === "constant-vus") {
    return {
      ...common,
      executor,
      vus: Number(__ENV.VUS || 1),
      duration: __ENV.DURATION || "2m",
    };
  }
  throw new Error(`unsupported EXECUTOR: ${executor}`);
}

const selectedExecution = executionScenario();
const maxInFlightRequests = Number(__ENV.MAX_IN_FLIGHT_REQUESTS || 0);
if (maxInFlightRequests > 0) {
  const vuCeiling = selectedExecution.maxVUs || selectedExecution.vus || 1;
  const batchPerHost = Number(__ENV.BATCH_PER_HOST || 12);
  const configuredCeiling = vuCeiling * batchPerHost;
  if (configuredCeiling > maxInFlightRequests) {
    throw new Error(
      `configured in-flight ceiling ${configuredCeiling} exceeds MAX_IN_FLIGHT_REQUESTS=${maxInFlightRequests}`,
    );
  }
}

export const options = {
  discardResponseBodies: false,
  summaryTrendStats: ["avg", "med", "p(90)", "p(95)", "p(99)", "max"],
  batch: Number(__ENV.BATCH_SIZE || 12),
  batchPerHost: Number(__ENV.BATCH_PER_HOST || 12),
  scenarios: {
    selected_flow: selectedExecution,
  },
  thresholds: {
    http_req_failed: [{ threshold: "rate<0.01", abortOnFail: true, delayAbortEval: "1m" }],
    [`http_req_duration{flow:${endpointScenario.name}}`]: ["p(95)<1000"],
    journey_duration: ["p(95)<2000", "p(99)<3000"],
    dropped_iterations: ["count==0"],
  },
};

function targetHost(url) {
  const match = /^https:\/\/([^/]+)(?:\/|$)/.exec(url);
  return match?.[1] || "";
}

function assertSafeConfig() {
  if (__ENV.LOAD_TEST_TARGET !== "staging") fail("LOAD_TEST_TARGET must be staging");
  if (__ENV.LOAD_TEST_READ_ONLY !== "true") {
    fail("LOAD_TEST_READ_ONLY must be true on the runner and API deployment");
  }
  if (!baseURL.startsWith("https://")) fail("BASE_URL must be an HTTPS staging URL");

  const nonGetEndpoints = scenarioEndpoints.filter((endpoint) => endpoint.method !== "GET");
  if (nonGetEndpoints.length > 0 && __ENV.ALLOW_NON_GET !== "true") {
    fail(`non-GET endpoints require current approval and ALLOW_NON_GET=true: ${nonGetEndpoints.map((endpoint) => endpoint.label).join(", ")}`);
  }

  const host = targetHost(baseURL);
  if (!host || host !== __ENV.LOAD_TEST_ALLOWED_HOST) {
    fail("LOAD_TEST_ALLOWED_HOST must exactly match the BASE_URL host");
  }
  const blockedHosts = (__ENV.LOAD_TEST_BLOCKED_HOSTS || "")
    .split(",")
    .map((value) => value.trim())
    .filter(Boolean);
  if (blockedHosts.includes(host)) fail(`refusing blocked host ${host}`);
  if (!Array.isArray(accounts) || accounts.length < 2) {
    fail("account file must contain at least two dedicated test accounts");
  }
  for (const account of accounts) {
    if (account.test_only !== true) fail("every account needs test_only=true");
    if (!endpointScenario.auth && !account.access_token && !__ENV.LOAD_TEST_ACCESS_TOKEN) {
      fail("GET-only authenticated flow needs a prepared access_token");
    }
  }
}

function scenarioRequest(endpoint, token, context) {
  return [endpoint.method, `${baseURL}${endpoint.buildPath(context)}`, null, {
    headers: { Authorization: `Bearer ${token}` },
    tags: { flow: endpointScenario.name, name: endpoint.label, route: endpoint.label },
  }];
}

function safeResponseBody(response) {
  const body = String(response.body || "").slice(0, 500);
  return body.replace(
    /"(access_token|refresh_token|token|password)"\s*:\s*"[^"]*"/gi,
    '"$1":"[redacted]"',
  );
}

function logFailure(name, response) {
  if (!logFailedResponses || (response.status >= 200 && response.status < 300)) return;

  const requestID = response.headers["X-Request-Id"] || response.headers["X-Request-ID"] || "";
  console.error(JSON.stringify({
    event: "request_failed",
    request: name,
    status: response.status,
    error: response.error || "",
    error_code: response.error_code || 0,
    request_id: requestID,
    body: safeResponseBody(response),
  }));
}

function recordMetrics(endpoint, response) {
  const tags = { route: endpoint.label };
  const metrics = endpointMetrics[endpoint.label];
  metrics.duration.add(response.timings.duration, tags);
  metrics.requests.add(1, tags);
  if (response.status > 0) metrics.responses.add(1, tags);
}

function metricValues(summary, name) {
  return summary.metrics[name]?.values || {};
}

function displayNumber(value, digits = 2) {
  return Number.isFinite(value) ? Number(value).toFixed(digits) : "—";
}

function escapeHTML(value) {
  return String(value)
    .replace(/&/g, "&amp;")
    .replace(/</g, "&lt;")
    .replace(/>/g, "&gt;")
    .replace(/"/g, "&quot;")
    .replace(/'/g, "&#39;");
}

function buildCombinedReport(summary) {
  const rows = scenarioEndpoints.map((endpoint) => {
    const requests = metricValues(summary, `req_${endpoint.metricKey}`);
    const responses = metricValues(summary, `res_${endpoint.metricKey}`);
    const timing = metricValues(summary, `rt_${endpoint.metricKey}`);
    const missingResponses = Math.max((requests.count || 0) - (responses.count || 0), 0);

    return `<tr>
      <td><code>${escapeHTML(endpoint.label)}</code></td>
      <td>${requests.count || 0}</td>
      <td>${displayNumber(requests.rate)}</td>
      <td>${responses.count || 0}</td>
      <td>${displayNumber(responses.rate)}</td>
      <td>${missingResponses}</td>
      <td>${displayNumber(timing.avg)} ms</td>
      <td>${displayNumber(timing.med)} ms</td>
      <td>${displayNumber(timing["p(95)"])} ms</td>
      <td>${displayNumber(timing["p(99)"])} ms</td>
      <td>${displayNumber(timing.max)} ms</td>
    </tr>`;
  }).join("\n");

  const profile = escapeHTML(__ENV.LOAD_TEST_SCENARIO || "custom");
  const flow = escapeHTML(endpointScenario.name);
  const generatedAt = new Date().toISOString();
  return `<!doctype html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>Load test ${flow} — ${profile}</title>
  <style>
    body { color: #1f2937; font: 14px system-ui, sans-serif; margin: 32px; }
    h1 { margin-bottom: 4px; }
    p { color: #6b7280; margin-top: 0; }
    table { border-collapse: collapse; width: 100%; }
    th, td { border-bottom: 1px solid #e5e7eb; padding: 10px; text-align: right; }
    th:first-child, td:first-child { text-align: left; }
    th { background: #f3f4f6; position: sticky; top: 0; }
    code { white-space: nowrap; }
  </style>
</head>
<body>
  <h1>${flow} endpoint summary</h1>
  <p>Profile: ${profile} · Generated: ${generatedAt}</p>
  <table>
    <thead><tr>
      <th>Route</th><th>Requests</th><th>Request RPS</th><th>Responses</th>
      <th>Response RPS</th><th>No response</th><th>Avg</th><th>p50</th>
      <th>p95</th><th>p99</th><th>Max</th>
    </tr></thead>
    <tbody>${rows}</tbody>
  </table>
</body>
</html>`;
}

export function handleSummary(summary) {
  const reportPath = __ENV.COMBINED_REPORT || "load-test-combined.html";
  return {
    [reportPath]: buildCombinedReport(summary),
    stdout: `Combined endpoint report: ${reportPath}\n`,
  };
}

export function setup() {
  assertSafeConfig();
}

export function runScenario() {
  const account = accounts[exec.scenario.iterationInTest % accounts.length];
  if (endpointScenario.auth) {
    fail("replace the mock auth path from the approved target API contract before use");
  }
  const accessToken = account.access_token || __ENV.LOAD_TEST_ACCESS_TOKEN || "";
  if (!accessToken) fail("GET-only authenticated flow requires a prepared access_token");
  const requestContext = { now: new Date() };

  group(endpointScenario.name, () => {
    const started = Date.now();
    const requestEntries = endpointScenario.requests.map((endpoint) => ({
      endpoint,
      request: scenarioRequest(endpoint, accessToken, requestContext),
    }));
    const responses = http.batch(requestEntries.map((entry) => entry.request));
    for (let i = 0; i < responses.length; i += 1) {
      const endpoint = requestEntries[i].endpoint;
      recordMetrics(endpoint, responses[i]);
      logFailure(endpoint.label, responses[i]);
      check(responses[i], {
        [`${endpoint.label} returns 2xx`]: (res) => res.status >= 200 && res.status < 300,
      });
    }
    journeyDuration.add(Date.now() - started);
  });

  const thinkTime = Number(__ENV.THINK_TIME_SECONDS || 0);
  if (thinkTime > 0) sleep(thinkTime);
}
