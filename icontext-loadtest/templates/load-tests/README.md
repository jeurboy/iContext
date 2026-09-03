# {{PAGE_NAME}} Load Test

> Template layout: replace every `{{PLACEHOLDER}}` and mock value from repository evidence. Delete
> sections that do not apply; do not leave example routes or product names in generated output.

## เป้าหมาย

<!-- หน้าที่ทดสอบ, user-visible outcome, capacity question -->

## ขอบเขตและ Safety

- Target page/route: `{{PAGE_ROUTE}}`
- Endpoint scenario: `{{FLOW_NAME}}`
- GET-only by default; list every approved non-GET method/route and side effect.
- Target environment / isolation evidence: <!-- TODO -->
- Explicit execution approval: `not authorised` by default

## Journey และ Endpoint Register

> หนึ่ง journey: <!-- actor → auth/cache state → page → ready condition -->

| Method | Route | Trigger | Parallel/serial | Side effect | Dependency | Included |
|--------|-------|---------|-----------------|-------------|------------|----------|
| GET | `/api/v1/mock-route` | initial mount | parallel | none verified | API/DB | yes |

## โปรไฟล์โหลด

| Profile | ภาษาคน | Executor | Rate/VUs | Duration | In-flight ceiling |
|---------|---------|----------|----------|----------|-------------------|
| `soft` | <!-- TODO --> | `constant-arrival-rate` | <!-- TODO --> | <!-- TODO --> | <!-- TODO --> |
| `baseline` | <!-- TODO --> | `constant-arrival-rate` | <!-- TODO --> | <!-- TODO --> | <!-- TODO --> |
| `ramp` | <!-- TODO --> | `ramping-arrival-rate` | <!-- TODO --> | <!-- TODO --> | <!-- TODO --> |
| `concurrent` | <!-- TODO --> | `per-vu-iterations` | <!-- TODO --> | <!-- TODO --> | <!-- TODO --> |
| `sustained` | <!-- TODO --> | `constant-vus` | <!-- TODO --> | <!-- TODO --> | <!-- TODO --> |

## วิธีตั้งค่า

```sh
cp load-test.env.example /protected/path/{{PAGE_SLUG}}-load-test.env
cp accounts.example.json /protected/path/{{PAGE_SLUG}}-accounts.json
chmod 600 /protected/path/{{PAGE_SLUG}}-load-test.env /protected/path/{{PAGE_SLUG}}-accounts.json
```

## คำสั่งสำหรับ Operator

> Documentation only. Do not execute without the exact environment/profile approval.

```sh
./run-{{PAGE_SLUG}}.sh --env-file /protected/path/{{PAGE_SLUG}}-load-test.env --scenario soft
```

## Metrics และ SLO

- `rt_<method_route>` — avg/p50/p95/p99/max response time
- `req_<method_route>` — request count/RPS
- `res_<method_route>` — received-response count/rate
- `journey_duration`, `http_req_failed`, `dropped_iterations`, `vus`
- SLO: <!-- TODO: page p95/p99, route p95, error/dropped limits -->

## Report

- Dashboard HTML: `{{DASHBOARD_REPORT}}`
- Combined route table: `{{COMBINED_REPORT}}`
- Summary JSON: `{{SUMMARY_JSON}}`
- Result wording/template: `RESULT_TEMPLATE.md`

## การแปลผลจากไฟล์

ส่ง path ของ JSON/HTML/result directory ให้ `/icontext-loadtest` พร้อมระบุหน้าที่ทดสอบ Skill จะ
สรุปค่าที่ตั้งใจยิงเทียบกับ throughput, latency, failures, dropped iterations และ capacity validity
โดยไม่รัน k6 ซ้ำ

## สิ่งที่ยังไม่ยืนยัน

- <!-- connectivity, credentials, runtime response, DB effects, resource metrics, capacity -->
