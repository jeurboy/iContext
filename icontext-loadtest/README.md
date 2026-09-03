# icontext-loadtest

สร้างชุด k6 load test จากหน้า/เส้นทางจริงของโปรเจกต์ iContext โดยถามหน้าที่ต้องการทดสอบทุกครั้ง
จากนั้น trace API fan-out, hidden writes และ dependency จากโค้ดจริงก่อนสร้าง script, profiles,
metrics และ report แบบมี safety guard

ค่าเริ่มต้นคือ GET-only ด้วย prepared access token สร้างและตรวจแบบ offline เท่านั้น ทุก non-GET
ต้องถาม user ใหม่ทุก invocation และไม่รัน k6 หรือแตะ environment/DB โดยอัตโนมัติ

เมื่อ user ส่ง path ของ result JSON/HTML/directory ให้ skill จะอ่านแบบ read-only และสรุปค่าที่ตั้งใจ
ยิงเทียบกับ throughput, latency, errors, dropped iterations และ capacity validity ที่ทำได้จริง

เริ่มใช้งานด้วย `/icontext-loadtest`
