# {{PROJECT_NAME}} — DEV.md (Layer 2 · development & architecture)

> **Owners:** `DEV OPS` · Sections: §3–7
> Read [CONTEXT.md](../CONTEXT.md) first for the full context map and workflow.
> Siblings: [PRODUCT.md](./PRODUCT.md) · [QA.md](./QA.md) ·
> [SECURITY.md](./SECURITY.md) · [DESIGN.md](./DESIGN.md) · [SKILLS.md](./SKILLS.md)

## สถาปัตยกรรม · Architecture

### 3. สถาปัตยกรรมระบบ · System Architecture
<!-- TODO: diagram / data flow -->
- `web/` ({{WEB_STACK}}) → `api/` ({{API_STACK}}) → `db` ({{DB_STACK}})
- `app/` ({{MOBILE_STACK}}) → `api/`

### 4. Tech Stack
| Layer | Choice | Notes |
|-------|--------|-------|
| Web | {{WEB_STACK}} | React Query · Tailwind · Playwright |
| Mobile | {{MOBILE_STACK}} | state + Dio + feature-first (app/STRUCTURE.md) |
| API | {{API_STACK}} | Clean Architecture · ORM-first, minimal raw SQL |
| DB | {{DB_STACK}} | docker-compose · migrations |

### 4.1 เครื่องมือ Load Test · Load-test tooling
| Tool | Location | Purpose |
|------|----------|---------|
| Grafana k6 | `load-tests/` | วัด page journey, API throughput/RPS, concurrency, ramp, stress และ soak พร้อมรายงานแยก route |

- ใช้ `/icontext-loadtest` เพื่อสร้างหรือปรับชุดทดสอบ โดย skill ต้องถามหน้า/screen/route ที่ต้องการ
  ทดสอบใหม่ทุกครั้ง แล้ว trace API fan-out และ hidden writes จากโค้ดจริง
- ค่าเริ่มต้นคือสร้าง script และตรวจ syntax แบบ offline เท่านั้น ห้ามรัน k6, start/restart service,
  migrate, seed หรือแตะ DB โดยไม่มีการอนุมัติใหม่ที่ระบุ environment และคำสั่งชัดเจน
- staging ที่ใช้ production DB/service ร่วมกันไม่ใช่ target ที่ปลอดภัย แม้ workload จะมีเฉพาะ GET
- บันทึก build revision, infrastructure profile, journeys/time unit, RPS, VUs, in-flight requests,
  dropped iterations, error rate และ p50/p95/p99 ทุกครั้งที่มีการรันโดยผู้ได้รับอนุญาต
- เมื่อต้องการแปลผล ให้ส่ง path ของ summary JSON, HTML หรือ result directory ให้
  `/icontext-loadtest`; skill ต้องอ่าน artifact แบบ read-only และสรุปค่าที่ตั้งใจยิงเทียบกับค่าจริง
- Workload ใช้ GET เป็นค่าเริ่มต้น หากต้องมี POST/PUT/PATCH/DELETE รวมถึง Login ต้องถาม owner ใหม่
  ทุก invocation พร้อมแจ้ง side effect และห้ามถือ approval ครั้งก่อนเป็นสิทธิ์ถาวร

### 5. โครงสร้าง Repo · Repo Structure
- Mono-root with each service as its **own git repo wired as a submodule**: `api/`, `web/`, `app/`.
- Context backbone lives at the root:
  - **L1 agent files** — `CLAUDE.md` / one of `AGENTS.md` or `agents.md` / one of `AGENT.md` or
    `agent.md` / `GEMINI.md` (preserve the casing selected for the project's agent tooling)
  - **L2 context (context map at the root + concern files in `context/`)** — `CONTEXT.md` at the
    repo root (context map + workflow) · `context/DEV.md` (this file: development + architecture) ·
    `context/PRODUCT.md` · `context/QA.md` · `context/SECURITY.md` · `context/DESIGN.md` ·
    `context/SKILLS.md` (skill dependencies + routing) — see the context map in `CONTEXT.md`
  - **L3 + shared** — `context/ROLE.md`, `PLAN.md`, `plans/`, `styles/`, `docs/`, `.icontext/hooks/`

### 5.1 การแก้ Merge Conflict · Merge-conflict resolution
- เมื่อ git merge หรือ rebase ค้างอยู่ที่ conflict ให้เรียก skill `resolving-merge-conflicts`
  (เงื่อนไขเรียกใช้อยู่ใน [SKILLS.md](./SKILLS.md) §10) โดยเริ่มจากอ่านสถานะ merge/rebase ปัจจุบัน
  และไฟล์ที่ conflict เสมอ อย่าเดาจาก marker อย่างเดียว
- ก่อนแก้แต่ละ hunk ให้หาต้นทางและเจตนาเดิมของทั้งสองฝั่งจาก commit message, PR หรือ issue/ticket
  ที่เกี่ยวข้อง แล้วแก้โดยรักษาเจตนาของทั้งสองฝั่งไว้ถ้าทำได้ ถ้าเข้ากันไม่ได้ให้เลือกฝั่งที่ตรงกับ
  เป้าหมายที่แถลงไว้ของการ merge พร้อมจด trade-off — ห้ามประดิษฐ์พฤติกรรมใหม่ และห้าม
  `--abort` โดยไม่ถาม owner ก่อน
- conflict ใน generated artifacts (เช่น lockfile, generated code) อย่าเก็บแก้ทีละบรรทัด ให้ถาม owner
  ว่าจะ regenerate ใหม่ดีกว่าหรือไม่
- หลังแก้ครบทุก hunk ให้รัน automated checks ของโปรเจกต์ตามลำดับ typecheck → tests → format
  แล้วแก้ทุกอย่างที่ merge ทำให้พังก่อนจบงาน
- การจบ merge/rebase (stage + commit หรือ `rebase --continue` จนครบทุก commit) ยังอยู่ภายใต้เกต
  [CONTEXT.md](../CONTEXT.md) §11.7 เสมอ — ต้องได้ per-invocation confirmation ก่อนทุกครั้ง แม้ upstream
  skill จะระบุให้ commit อัตโนมัติ เพราะกฎของโปรเจกต์มีลำดับเหนือกว่า default ของ skill ภายนอก
  (SKILLS.md §10.5)
- ถ้า skill ไม่พร้อมใช้ ให้แก้ด้วยมือตามลำดับขั้นเดียวกันนี้ และบันทึกลง plan ที่เกี่ยวข้องว่าใช้ manual fallback

### 5.2 การ Implement · Implementation execution flow
> Canonical flow คือ loop ใน [CONTEXT.md](../CONTEXT.md) §11.5 — section นี้ถอดเป็นขั้นปฏิบัติสำหรับการ
> execute จริงเท่านั้น ไม่ใช่ flow ชุดใหม่ หากสองที่ขัดกัน ให้ยึด §11.5 เสมอ

- ก่อนเริ่ม: plan ต้องอยู่ที่ status `ready to implement` (review chain §11.4 ผ่านแล้ว) และมี spec/plan/
  ticket source ชัดเจน
- ตัวขับเคลื่อนหลัก: `/icontext-implement` — เริ่มด้วยสรุป plan ผ่าน `icontext-feature-review`
  สร้าง slice list จาก §10 (+CR ที่ค้าง) แล้ววน loop ด้านล่างโดยแต่ละ slice ให้ **implementer
  sub-agent บนโมเดลราคาถูก/effort ต่ำ** เป็นคนเขียนโค้ด — owner ต้อง **confirm ทุกครั้งก่อน spawn**
  (จำนวน agent · scope ของแต่ละตัว · โมเดล/effort) เป็นข้อบังคับ รวมถึงรอบแก้และรอบ retry; ตัว
  orchestrator เก็บการตัดสินใจ (slice · review · ผล test · security · การเปลี่ยน status) ไว้เอง
- ลำดับต่อหนึ่ง slice (วนซ้ำจนครบทุก User Story):
  1. **Slice** — หยิบงานที่เล็กที่สุดที่ขยับ User Story หนึ่งอัน (po.md §3) ไปข้างหน้า
  2. **Implement** — implementer sub-agent ที่ owner ยืนยันแล้วเขียนโค้ดตาม slice brief; ถ้า owner
     เรียก skill `implement` (mattpocock) ให้ใช้มันเป็นเพียงตัว execute ขั้นนี้แทน sub-agent ก็ได้
     (TDD ตาม seams ที่ตกลงไว้, รัน typecheck และ test file เดี่ยวระหว่างทางได้)
     แต่ลำดับขั้นที่เหลือของ loop ห้ามข้ามหรือเรียงใหม่ตาม flow ภายในของ skill เช่นห้ามเก็บ full
     suite ไว้รอท้ายสุดแทนการ retest หลังทุกการแก้
  3. **Test แบบจริง** — unit test สำหรับ API, Playwright สำหรับ UI ตาม `qa.md` §9 ของ plan พร้อมระบุ
     คำสั่งที่รันจริง ผลที่คาดหวัง และวิธีวัด coverage (> 80%)
  4. **Retest/Regression** — หลัง**ทุก**การแก้ ให้รัน suite ที่เกี่ยวข้องทั้งหมดใหม่ ไม่ใช่เฉพาะ test ใหม่
     แก้จนเขียวแล้ว mark test case ที่ผ่านใน `qa.md`
  5. **Review กับ owner** — แสดงสิ่งที่สร้าง (diff · screenshot · app ที่รันได้) อธิบายวิธีที่ test แล้วถาม
     feedback อย่างชัดเจน; จะรัน `code-review` (mattpocock) เป็น optional pass ก่อนขั้นนี้ได้
     (standards/spec — ไม่แทน §11.6)
  6. **Security review** — รัน `security-review` detectors ตาม §11.6 เฉพาะไฟล์ที่ slice แตะ ก่อนออกจาก loop
  7. **Fold feedback** — นำ feedback กลับเข้า slice ถัดไป
- การ commit เข้า current branch (ท้าย slice หรือตามที่ upstream skill สั่ง) ต้องผ่าน per-invocation
  confirmation ตาม [CONTEXT.md](../CONTEXT.md) §11.7 เสมอ — กฎโปรเจกต์เหนือกว่า default ของ skill ภายนอก
  (SKILLS.md §10.5) และ hook `.icontext/hooks/guard-command.sh` จะ intercept ให้ถามอยู่ดี
- ก่อน commit ครั้งแรกของ plan: `/unslop` งานเขียน (plan/docs) เมื่อโค้ดจบ → sync `docs/openapi.yaml` +
  `styles/` + [DEV.md](./DEV.md) §7 → แล้ว quality chain: `/impeccable` ซ้ำเมื่อมีงาน design, `/deslop`
  บน branch diff, ถาม owner ทุกครั้งเรื่อง `/thermo-nuclear-code-quality-review` (optional) — ก่อนขอ §11.7
- ถ้าไม่ใช้ skill ให้ implement ด้วยมือตามลำดับขั้นใน section นี้ได้ทั้งหมด (manual fallback ตาม §10)

### 6. รายการ Service · Services
| Service | Stack | Port | STRUCTURE |
|---------|-------|------|-----------|
| api | {{API_STACK}} | {{API_PORT}} | api/STRUCTURE.md |
| web | {{WEB_STACK}} | {{WEB_PORT}} | web/STRUCTURE.md |
| app | {{MOBILE_STACK}} | — | app/STRUCTURE.md |
| db | {{DB_STACK}} | {{DB_PORT}} | docker-compose.yml |

### 7. Data Model
> Single source of truth for entities. Keep in sync with the plan's schema section + DB migrations
> (CONTEXT.md §11.3). Update this whenever the data model changes.

**Entities**
| Entity | Key fields | Description |
|--------|-----------|-------------|
| <!-- e.g. User --> | id, ... | <!-- TODO --> |

**Relationships**
<!-- TODO: e.g. User 1—N Order; Order N—N Product (via OrderItem). One model can have many physical units. -->

**ERD / notes**
<!-- TODO: link or embed a diagram; note enums, indexes, soft-delete, audit fields -->

---
## Keeping this in sync
- Architecture, stack, repo, service, or data-model changes belong here; keep the affected plan,
  `docs/openapi.yaml`, service `STRUCTURE.md`, and DB migrations aligned in the same change
  ([CONTEXT.md](../CONTEXT.md) §11.3).
- If a technical decision changes product scope, security, testing, or design, update the matching
  L2 sibling in the same change. Link across files; never duplicate a section.
