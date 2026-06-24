# 05 Functional Requirements

## FR-001 Scan Barcode / QR Code

ระบบต้องรับค่า Tracking จากหัวสแกน PDA ผ่าน Keyboard Input / Keyboard Wedge

### Criteria

- เมื่อยิง Barcode เลขต้องเข้า Scanner Input
- ระบบต้อง Process อัตโนมัติ
- ไม่ต้องกดปุ่ม Save
- ไม่ต้องกด Enter เอง
- รองรับการสแกนต่อเนื่อง

## FR-002 Auto Focus

Scanner Input ต้อง Focus อัตโนมัติตลอดเวลา

### Criteria

- เปิดแอปแล้ว Focus ทันที
- หลังสแกนแล้ว Clear + Focus กลับ
- ถ้า Focus หลุด ต้อง Focus กลับ
- ถ้าเปิด Dialog แล้วปิด Dialog ต้อง Focus กลับ

## FR-003 Validate Tracking

ระบบต้องตรวจสอบรูปแบบ Tracking ก่อนบันทึก

### Rule

Tracking ถูกต้องต้องเป็น

```text
numeric only
length = 12
```

### Valid Examples

```text
829362431516
829360206500
829353044505
```

### Invalid Examples

```text
82936
JT123456789TH
829362431516999
8293 62431516
ABC
```

### Invalid Behavior

- ไม่บันทึก
- ไม่เพิ่ม Counter
- เล่นเสียง Error
- แสดงสีส้ม
- แสดงข้อความ "รูปแบบ Tracking ไม่ถูกต้อง"

## FR-004 Duplicate Check

ระบบต้องตรวจสอบเลขซ้ำทันที

### Criteria

- ถ้าไม่เคยสแกน → บันทึก
- ถ้าเคยสแกน → Alert
- เลขซ้ำห้าม Insert
- เลขซ้ำห้ามเพิ่ม Counter
- ต้องแสดงเวลาที่เคยสแกน

## FR-005 Save New Tracking

เมื่อ Tracking ถูกต้องและไม่ซ้ำ

ระบบต้อง

- Insert ลง SQLite
- บันทึก scanned_at
- เล่นเสียง Success
- แสดงสีเขียว
- แสดงข้อความ "บันทึกสำเร็จ"
- เพิ่ม Counter

## FR-006 Duplicate Alert

เมื่อ Tracking ซ้ำ

ระบบต้อง

- ไม่ Insert
- เล่นเสียง Duplicate Alert
- แสดงสีแดง
- แสดงข้อความ "เลขนี้ถูกสแกนแล้ว"
- แสดง Tracking
- แสดงวันที่เวลาที่เคยสแกน
- Clear Input
- Focus กลับ

## FR-007 Counter

แสดงจำนวน Tracking ที่บันทึกสำเร็จทั้งหมด

### Rule

- เลขใหม่ +1
- เลขซ้ำ +0
- รูปแบบผิด +0

## FR-008 Search

ระบบต้องค้นหา Tracking ได้

### Input

- Tracking Number

### Result Found

แสดง

- Tracking Number
- Date
- Time

### Result Not Found

แสดง

```text
ไม่พบข้อมูล
```

## FR-009 History

ระบบต้องแสดงประวัติการสแกน

ข้อมูล

- No
- Tracking Number
- Date
- Time

เรียงจากล่าสุดไปเก่าสุด

## FR-010 Export CSV

ระบบต้อง Export CSV ได้

### CSV Columns

```text
No,Tracking Number,Date,Time
```

### File Name

```text
Tracking_YYYY-MM-DD_HH-mm.csv
```

ตัวอย่าง

```text
Tracking_2026-06-18_14-30.csv
```

### Behavior

- กด Export
- สร้างไฟล์
- แสดง Popup Export สำเร็จ
- มีปุ่มแชร์ไฟล์
- กดแชร์ไฟล์แล้วเปิด Android Share Sheet

## FR-011 Share File

หลัง Export ต้องแชร์ไฟล์ผ่าน Android Share Sheet ได้

ตัวเลือกขึ้นอยู่กับเครื่อง เช่น

- LINE
- Gmail
- Google Drive
- Bluetooth

## FR-012 Start New Round

มีปุ่มเริ่มรอบใหม่

เมื่อกดต้อง Confirm ก่อน

หลังยืนยัน

- ล้าง SQLite
- Reset Counter
- สถานะกลับเป็นพร้อมสแกน
- Focus Scanner Input

## FR-013 Offline Mode

ระบบต้องทำงานได้ 100% โดยไม่ใช้อินเทอร์เน็ต

WiFi ใช้เฉพาะตอนผู้ใช้เลือกแชร์ไฟล์ผ่าน LINE หรือแอปอื่น

## FR-014 Data Persistence

ปิดแอปแล้วเปิดใหม่ ข้อมูลต้องยังอยู่

ยกเว้นผู้ใช้กดเริ่มรอบใหม่
