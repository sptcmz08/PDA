# 07 Project Rules

## 1. Development Rules

ต้องทำตาม Requirement ใน docs เท่านั้น

ห้ามเพิ่มฟีเจอร์เองโดยไม่ได้รับคำสั่ง

## 2. Forbidden Features

ห้ามทำสิ่งเหล่านี้

- Server
- API
- Login
- User Management
- Multi PDA
- Sync
- Web Admin
- Dashboard
- Graph
- Google Sheet
- Cloud Backup
- Payment
- Notification
- Permission System
- Camera Scanner

เหตุผล: โปรเจกต์นี้ต้องการ Offline App สำหรับ PDA เครื่องเดียวเท่านั้น

## 3. Code Quality

ต้องเขียนโค้ดแบบอ่านง่าย แยกไฟล์ชัดเจน

หลักการ

- Clean Architecture เท่าที่เหมาะกับโปรเจกต์เล็ก
- Repository Pattern
- Service Layer
- ไม่ยัดทุกอย่างในหน้า UI
- Function ชื่อชัดเจน
- Comment เฉพาะจุดสำคัญ
- Error Handling ครบ

## 4. UI Rule

- เปิดแอปแล้วพร้อมสแกนทันที
- ปุ่มต้องใหญ่
- ข้อความต้องสั้น
- สถานะต้องชัด สี + ข้อความ
- Scanner Input ต้อง Focus ตลอด
- ห้ามให้ผู้ใช้กด Save หลังสแกน

## 5. Database Rule

- `tracking_number` ต้อง UNIQUE
- ห้าม Insert ข้อมูลไม่ผ่าน Validation
- ห้ามบันทึกเลขซ้ำ
- ห้าม Clear Data โดยไม่ Confirm

## 6. Validation Rule

Tracking ถูกต้องต้องเป็นตัวเลข 12 หลักเท่านั้น

Regex

```regex
^\d{12}$
```

## 7. Export Rule

CSV ต้องมี

```text
No,Tracking Number,Date,Time
```

ต้องเปิดผ่าน Excel ได้

หลัง Export ต้องมีปุ่ม Share File

## 8. Error Message Rule

ทุก Error ที่แสดงให้ผู้ใช้ต้องเป็นภาษาไทยเข้าใจง่าย

ตัวอย่าง

```text
ไม่สามารถบันทึกข้อมูลได้ กรุณาลองใหม่
ไม่สามารถ Export CSV ได้
ไม่พบข้อมูล
รูปแบบ Tracking ไม่ถูกต้อง
```

## 9. AI Development Rule

ถ้า AI ไม่มั่นใจ Requirement ห้ามเดา ให้ถามก่อน

ถ้าเจอ Requirement ขัดแย้ง ให้หยุดและถาม

ถ้าทำ Phase เสร็จ ต้องสรุปไฟล์ที่แก้ไขและวิธีทดสอบ

## 10. Testing Rule

ก่อนบอกว่างานเสร็จ ต้องผ่าน Acceptance Test ในไฟล์ `09_Acceptance_Test.md`

## 11. Build Rule

ห้ามส่งงานถ้า Build ไม่ผ่าน

ต้องรัน

```bash
flutter clean
flutter pub get
flutter analyze
flutter build apk --release
```

ถ้า `flutter analyze` มี Warning ที่ไม่กระทบ อธิบายให้ชัดเจน
