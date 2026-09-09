# CR-1 — <Change title> (YYYY-MM-DD)

> **Status: `plan`** <!-- to do → plan → ready to implement → implement → ready to test → done -->
> **แผนเดิม:** [NNN-<slug>](./README.md) สถานะ `<plan status>` — CR นี้เป็นการขยาย/แก้ของเดิม
> **ไม่ใช่แผนใหม่** (สร้างจาก `/icontext-feature` Step 2 — CR mode)
> **ref:** [CONTEXT.md](../../CONTEXT.md) <!-- + L2 concern files ที่แตะ: context/DEV.md · PRODUCT.md · QA.md · SECURITY.md · DESIGN.md -->

> ⚠️ เลข CR/decision เป็นตัวอย่างสำหรับ CR แรกของ folder — ตอนสร้างใช้เลขลำดับถัดไปจริง
> (CR-2, D-CR2-n, …) และอย่าแตะไฟล์แผนเดิมนอกจาก README (ตาราง CR) + ไฟล์ CR นี้

## Context

- โจทย์จากเจ้าของงาน: <!-- อะไรที่ขอเพิ่ม/เปลี่ยน อ้างอิงรูป/ฟอร์มถ้ามี -->
- ของเดิมที่ต่อยอด: <!-- แผน/ระบบเดิมที่เกี่ยวข้อง + กติกาที่ยังใช้เดิมทั้งหมด — ไม่สร้าง engine ใหม่ -->
- Use case จริง: <!-- ทำให้เห็นว่าทำไมต้องทำตอนนี้ -->

## Requirement discovery (`/grill-with-docs` | `/wayfinder` — YYYY-MM-DD)

<!-- ผู้ใช้ยืนยันเอง N ข้อ (เลือกจาก options) · ที่เหลือเป็น default ตามโจทย์ + ที่พับเพิ่มหลัง persona panel -->

| # | การตัดสินใจ | ที่มา |
|---|------------|-------|
| D-CR1-1 | <!-- ข้อตัดสินใจ → ผลที่จับต้องได้ --> | ผู้ใช้เลือก YYYY-MM-DD |
| D-CR1-2 | <!-- ... --> | ตามโจทย์ / พับจาก persona / จากสถาปัตยกรรมเดิม |

## Persona panel (N คน — AI-emulated | subagents YYYY-MM-DD, ตาม context/ROLE.md)

| Persona | Works | Concern → Decision |
|---------|-------|--------------------|
| <!-- 🛠️ ชื่อ (role) --> | <!-- ของเดิมที่ใช้ต่อได้ --> | <!-- ความกังวล → ข้อตัดสินใจ/อ้าง D-CR1-n --> |

## การออกแบบ (design)

<!-- เฉพาะ delta จากแผนเดิม — จับเป็นชั้น ๆ:
### 1) DB — migration `NNNNNN` (up/down) ...
### 2) API — entity / usecase / handler binding ...
### 3) openapi (docs/openapi.yaml) ...
### 4) Web ...
### 5) Style guide — ทำก่อนแก้ component (ถ้าแตะ UI) ... -->

## Acceptance criteria

- **AC-1:** <!-- เฉพาะสโคป CR -->
- **AC-2:** <!-- แผนเดิมต้องไม่เสียหาย (backward compatible) -->

## Out of scope

- <!-- สิ่งที่ชัดเจนว่าไม่ทำ + เหตุผล/อ้างอิง decision -->

## Tasks

- [ ] T-1 <!-- style guide ก่อน (ถ้าแตะ component) -->
- [ ] T-2 <!-- ... -->

## Implementation + verification

<!-- เติมตอน implement/ใช้จริง: สิ่งที่ทำจริงต่างจาก design · ผล Loop Engineering (build/lint/test) ·
บั๊กจากการใช้จริง + บทเรียน · งานที่ค้าง (เช่น e2e ที่ยังรันไม่ได้) -->
