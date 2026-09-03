# ผลการทดสอบ Load Test: {{PAGE_NAME}}

- Endpoint scenario:
- Load profile:
- Environment / target host:
- ช่วงเวลาทดสอบ (timezone):
- App/API revision:
- Script revision:
- Infrastructure profile:
- ผู้ดำเนินการ / หลักฐานอนุมัติ:

## สรุปแบบภาษาคน

> Scenario นี้จำลอง <!-- อัตราผู้ใช้ + journey + จำนวน API calls + duration -->

> ผล: ผ่าน/ไม่ผ่าน เพราะ <!-- achieved rate + p95 + errors + dropped -->

## Throughput

| รายการ | เป้าหมาย | ทำได้จริง | ผล |
|--------|----------|-------------|----|
| Journeys | | | |
| Journey rate | | | |
| HTTP requests / API RPS | | | |
| Successful RPS | | | |
| Dropped / interrupted | 0 | | |

## เวลาตอบสนองแยกตาม Endpoint

| Endpoint | Requests/RPS | Responses/RPS | Avg | p50 | p95 | p99 | Max | Error % |
|----------|--------------|---------------|-----|-----|-----|-----|-----|---------|
| `GET /api/v1/mock-route` | | | | | | | | |

## ทรัพยากรและคอขวด

- API CPU / memory / goroutines / restarts:
- DB CPU / connections / waits / slow queries:
- Load generator CPU / memory / network:
- Waiting เทียบ connecting/TLS:
- Route ที่ช้าที่สุด:
- สมมติฐานคอขวดและหลักฐานที่ยังขาด:

## ความปลอดภัยของข้อมูล

- Before/after evidence:
- ตารางหรือข้อมูลที่เปลี่ยน:
- Non-GET ที่ได้รับอนุมัติ:
- Unexpected writes:

## ข้อสรุป Capacity

- รองรับอย่างน้อย:
- Maximum capacity: ทราบ / ยังไม่ทราบ
- Operating headroom:
- ข้อจำกัดของผลทดสอบ:
- ขั้นต่อไปที่ปลอดภัย:
