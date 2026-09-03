function endpoint(method, route, buildPath = () => route) {
  const label = `${method} ${route}`;
  const metricKey = label
    .toLowerCase()
    .replace(/[^a-z0-9]+/g, "_")
    .replace(/^_|_$/g, "");
  return Object.freeze({ method, route, label, metricKey, buildPath });
}

// Mock registry: replace these entries with routes traced from the selected page.
export const API_ENDPOINTS = Object.freeze({
  currentUser: endpoint("GET", "/api/v1/me"),
  pageSummary: endpoint("GET", "/api/v1/page/summary"),
  recentRecords: endpoint("GET", "/api/v1/records", () => "/api/v1/records?limit=20"),
  unreadAlerts: endpoint("GET", "/api/v1/alerts/unread-count"),
});

function scenario(name, auth, requests) {
  return Object.freeze({ name, auth, requests: Object.freeze(requests) });
}

// GET-only by default. Add non-GET auth/actions only after fresh owner approval.
export const ENDPOINT_SCENARIOS = Object.freeze({
  page_example: scenario("page_example", null, [
    API_ENDPOINTS.currentUser,
    API_ENDPOINTS.pageSummary,
    API_ENDPOINTS.recentRecords,
  ]),
  focus_refresh_example: scenario("focus_refresh_example", null, [
    API_ENDPOINTS.unreadAlerts,
  ]),
});

export function getEndpointScenario(name) {
  const selected = ENDPOINT_SCENARIOS[name];
  if (!selected) throw new Error(`unknown endpoint scenario: ${name}`);
  return selected;
}
