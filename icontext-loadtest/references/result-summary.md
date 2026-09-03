# แนวทางสรุปผล Load Test เป็นภาษาคน

ใช้โครงนี้เมื่อ user ให้ path ของ k6 result อย่ารัน test ใหม่เพื่อเติมข้อมูลที่ขาด ให้ระบุว่า
ข้อมูลใดไม่มีใน artifact แทน

## 1. บอกก่อนว่าทดสอบอะไร

เขียนหนึ่งย่อหน้าในรูปแบบ:

> Scenario นี้จำลองผู้ใช้เข้ามา `<อัตรา>` ต่อ `<ช่วงเวลา>` เป็นเวลา `<duration>` แต่ละคนทำ
> `<journey>` ซึ่งเรียก API `<จำนวน>` ครั้ง จึงตั้งใจสร้างโหลดประมาณ `<RPS>`

แยก “ค่าที่ตั้งใจยิง” ออกจาก “ค่าที่ระบบทำได้จริง” เสมอ

## 2. สรุปผลผ่าน/ไม่ผ่านทันที

ขึ้นต้นด้วยหนึ่งประโยค:

> ผล: ผ่าน/ไม่ผ่าน — ระบบทำได้ `<completed rate>` เทียบเป้าหมาย `<target rate>` โดยมี
> `<error rate>` errors, `<dropped>` dropped iterations และ p95 `<latency>`

ถ้า environment ใช้ production DB/service ร่วมกัน ให้ระบุว่าผลใช้วิเคราะห์เบื้องต้นได้แต่ไม่ใช่
formal capacity acceptance

## 3. ตาราง Throughput

| รายการ | เป้าหมาย | ทำได้จริง | ผล |
|--------|----------|-------------|----|
| Journeys | | | |
| Journey rate | | | |
| HTTP requests | | | |
| API RPS | | | |
| Successful RPS | | | |
| Dropped/interrupted | 0 | | |

เมื่อหนึ่ง journey มีหลาย requests ให้ตรวจความสัมพันธ์ `journeys × requests per journey` และอธิบาย
ส่วนต่างที่อาจมาจาก redirect, retry, interrupted request หรือ conditional endpoint

## 4. ตาราง Response Time

| รายการ | Avg | p50 | p95 | p99 | Max | SLO |
|--------|-----|-----|-----|-----|-----|-----|
| Login | | | | | | |
| Page journey | | | | | | |
| HTTP รวม | | | | | | |

ตามด้วย route ที่ช้าที่สุด 3–5 เส้น อย่ารายงานเฉพาะ average เพราะ tail latency เป็นตัวบอก queueing
และประสบการณ์ผู้ใช้ที่ช้า

## 5. แปลอาการ

- `waiting` สูง แต่ connecting/TLS ต่ำ → คอขวดน่าจะอยู่หลังรับ request เช่น API, DB, pool หรือ upstream
- VUs ชน `maxVUs` และมี dropped iterations → load generator รักษา arrival rate ไม่ได้ เพราะ journey
  ใช้เวลานาน; การเพิ่ม VUs อาจเพิ่มแรงกด ไม่ใช่การแก้ระบบ
- request count มากกว่า route counters → ตรวจ redirect/retry/HTTP hop
- request count มากกว่า response count → ตรวจ timeout, DNS, TLS, connection reset หรือ interruption
- median ต่ำแต่ p95/p99 สูง → ระบบมี tail latency/queueing แม้ผู้ใช้ส่วนใหญ่ยังเร็ว
- zero errors แต่ dropped สูง → ระบบยังไม่ผ่าน เพราะ traffic ที่ตั้งใจยิงไม่ได้เริ่มครบ

ใช้คำว่า “มีแนวโน้ม” สำหรับ bottleneck ที่ยังไม่มี server/DB metrics และบอกหลักฐานที่ต้องดูต่อ

## 6. Capacity statement

กล่าวว่า “รองรับอย่างน้อย N” ได้เมื่อ stage นั้นผ่าน SLO, ไม่มี dropped iterations, ไม่มี unexpected
writes/restarts/OOM และมี infrastructure profile ครบ อย่าเรียก stage ที่ล้มเหลวว่า capacity

ถ้ายังไม่พบ failure boundary ให้เขียน:

> รอบนี้พิสูจน์ว่ารองรับอย่างน้อย `<N journeys/s>` บน `<infra>` แต่ยังไม่ทราบ maximum capacity

แนะนำ operating capacity ที่มี headroom เฉพาะเมื่อ owner กำหนด policy เช่น 70% ของ highest passing
sustained rate

## 7. ขั้นต่อไปที่ปลอดภัย

สรุป 1–3 ข้อที่สัมพันธ์กับหลักฐาน เช่นตรวจ DB connections/slow queries, CPU throttling, memory/OOM,
route tracing หรือทดสอบ rate ต่ำลง ห้ามแนะนำให้เพิ่ม load บน environment ที่ใช้ production ร่วมกัน

ปิดท้ายด้วย path ที่ใช้วิเคราะห์และรายการข้อมูลที่ไม่มี เช่น container CPU/memory, DB metrics,
deployment revision หรือ account/data distribution
