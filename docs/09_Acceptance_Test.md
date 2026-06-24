# 09 Acceptance Test

เอกสารนี้คือรายการทดสอบก่อนส่งมอบ

งานจะถือว่าเสร็จเมื่อ Test ผ่านทั้งหมด

---

# A. Installation Test

## AT-001 Install APK

- ติดตั้ง APK บน PDA iT88 Android 14 ได้
- เปิดแอปได้
- แอปไม่ Crash

Expected: Pass

---

# B. Scanner Input Test

## AT-002 Auto Focus on Open

เปิดแอปแล้วช่อง Scanner Input ต้องพร้อมรับข้อมูลทันที

Expected: ยิงบาร์โค้ดได้ทันทีโดยไม่ต้องแตะช่อง

## AT-003 Keyboard Wedge Input

ยิง Barcode แล้วเลขเข้าแอป

Expected: เลขถูก Process อัตโนมัติ

## AT-004 Continuous Scan

ยิงต่อเนื่องหลายรายการ

Expected: แอปไม่ค้าง และ Focus กลับทุกครั้ง

---

# C. Validation Test

## AT-005 Valid 12 Digits

Input

```text
829362431516
```

Expected:

- บันทึกสำเร็จ
- สีเขียว
- เสียง Success
- Counter +1

## AT-006 Too Short

Input

```text
82936
```

Expected:

- ไม่บันทึก
- สีส้ม
- เสียง Error
- Counter ไม่เพิ่ม

## AT-007 Contains Letter

Input

```text
JT123456789TH
```

Expected:

- ไม่บันทึก
- สีส้ม
- เสียง Error
- Counter ไม่เพิ่ม

## AT-008 Empty Input

Input ว่าง

Expected:

- ไม่บันทึก
- ไม่ Crash

---

# D. Duplicate Test

## AT-009 First Scan

Input

```text
829360206500
```

Expected:

- บันทึกสำเร็จ
- Counter +1

## AT-010 Duplicate Scan

Input เดิมอีกครั้ง

```text
829360206500
```

Expected:

- ไม่บันทึกซ้ำ
- สีแดง
- เสียง Duplicate
- แสดงข้อความเลขนี้ถูกสแกนแล้ว
- แสดงวันที่เวลาที่เคยสแกน
- Counter ไม่เพิ่ม

## AT-011 Database Unique Safety

พยายาม Insert เลขซ้ำระดับ Repository

Expected:

- ไม่ Crash
- ถือเป็น Duplicate

---

# E. Counter Test

## AT-012 Counter Accuracy

Scan

```text
829362431516
829360206500
829353044505
829353044505
ABC
```

Expected:

- Counter = 3
- เพราะเลขซ้ำและรูปแบบผิดไม่นับ

---

# F. Search Test

## AT-013 Search Found

ค้นหาเลขที่เคยสแกน

Expected:

- แสดง Tracking
- แสดงวันที่
- แสดงเวลา

## AT-014 Search Not Found

ค้นหาเลขที่ไม่เคยสแกน

Expected:

```text
ไม่พบข้อมูล
```

---

# G. History Test

## AT-015 History List

เปิดประวัติ

Expected:

- แสดง Tracking ทั้งหมดที่บันทึกสำเร็จ
- มีวันที่เวลา
- เรียงล่าสุดก่อน

---

# H. Export CSV Test

## AT-016 Export With Data

กด Export CSV หลังมีข้อมูล

Expected:

- สร้างไฟล์ CSV
- ชื่อไฟล์รูปแบบ Tracking_YYYY-MM-DD_HH-mm.csv
- มี Popup Export สำเร็จ

## AT-017 CSV Columns

เปิดไฟล์ CSV

Expected columns

```text
No,Tracking Number,Date,Time
```

## AT-018 CSV Open in Excel

เปิด CSV ใน Excel

Expected:

- อ่านข้อมูลได้
- เลข Tracking ไม่เสียรูปแบบ

## AT-019 Share File

กดแชร์ไฟล์

Expected:

- Android Share Sheet เปิด
- สามารถเลือก LINE ได้ถ้ามี LINE ในเครื่อง

## AT-020 Export Empty

กด Export ตอนยังไม่มีข้อมูล

Expected:

- ไม่ Crash
- แจ้งว่าไม่มีข้อมูลสำหรับ Export หรือ Export เป็นไฟล์ว่างพร้อม Header ตามที่ตกลง

แนะนำ: แจ้งว่าไม่มีข้อมูลสำหรับ Export

---

# I. Start New Round Test

## AT-021 Cancel Clear

กดเริ่มรอบใหม่ แล้วกดยกเลิก

Expected:

- ข้อมูลยังอยู่
- Counter ไม่เปลี่ยน

## AT-022 Confirm Clear

กดเริ่มรอบใหม่ แล้วยืนยัน

Expected:

- ล้างข้อมูลทั้งหมด
- Counter = 0
- History ว่าง
- พร้อมสแกนใหม่

---

# J. Persistence Test

## AT-023 Close and Reopen

สแกนข้อมูลแล้วปิดแอป เปิดใหม่

Expected:

- ข้อมูลยังอยู่
- Counter ถูกต้อง

---

# K. UI/UX Test

## AT-024 Button Size

ปุ่มต้องกดง่ายบน PDA

Expected:

- ไม่เล็กเกินไป
- ไม่กดพลาดง่าย

## AT-025 Status Clarity

สถานะต้องชัดเจน

Expected:

- Success เขียว
- Duplicate แดง
- Invalid ส้ม
- ข้อความอ่านง่าย

---

# L. Build Test

## AT-026 Flutter Analyze

รัน

```bash
flutter analyze
```

Expected:

- ไม่มี Error

## AT-027 Release Build

รัน

```bash
flutter build apk --release
```

Expected:

- Build APK สำเร็จ
