# 02 System Architecture

## 1. Architecture Overview

ระบบเป็น Offline First Android App ทำงานบนเครื่อง PDA เพียงเครื่องเดียว

```text
PDA iT88 Android 14
        │
        ▼
Built-in Scanner
Keyboard Wedge Input
        │
        ▼
Flutter App
        │
        ├── Presentation Layer
        ├── Service Layer
        ├── Repository Layer
        └── Database Layer
        │
        ▼
SQLite Local Database
        │
        ▼
CSV Export + Android Share Sheet
```

## 2. Layer Architecture

### 2.1 Presentation Layer

หน้าที่

- แสดง UI
- รับ Input จาก Scanner Text Field
- แสดงสถานะ สี เสียง และจำนวน
- เปิด Dialog ค้นหา / ประวัติ / Export / เริ่มรอบใหม่

ไฟล์หลัก

```text
lib/screens/scanner_screen.dart
lib/screens/history_screen.dart
lib/widgets/
```

### 2.2 Service Layer

หน้าที่

- จัดการ Business Logic
- Validate Tracking
- ตรวจเลขซ้ำ
- เล่นเสียง Alert
- Export CSV
- Share File

ไฟล์หลัก

```text
lib/services/scanner_service.dart
lib/services/duplicate_service.dart
lib/services/alert_service.dart
lib/services/export_service.dart
```

### 2.3 Repository Layer

หน้าที่

- เป็นตัวกลางระหว่าง Service กับ Database
- Query / Insert / Delete / Search ข้อมูล Tracking
- ป้องกัน UI ไม่ให้เรียก SQLite โดยตรง

ไฟล์หลัก

```text
lib/repositories/tracking_repository.dart
```

### 2.4 Database Layer

หน้าที่

- เปิด SQLite
- สร้าง Table
- Migration
- Execute Query

ไฟล์หลัก

```text
lib/database/sqlite_helper.dart
```

## 3. Module Design

### 3.1 Scanner Module

รับค่าจาก TextField ที่หัวสแกนส่งเข้ามา

Requirement

- รองรับ Keyboard Wedge
- รองรับ Enter / Suffix หลังยิง
- รองรับกรณีไม่มี Enter โดยใช้ debounce สั้น ๆ ถ้าจำเป็น
- Clear TextField หลัง Process
- Auto Focus กลับเสมอ

### 3.2 Duplicate Check Module

หัวใจของระบบ

Logic

```text
receive tracking
↓
trim
↓
validate
↓
find by tracking_number
↓
if not found:
    insert
    success
else:
    duplicate alert
```

### 3.3 Alert Module

แยกเสียงและสถานะออกจาก Business Logic

สถานะ

- Success: สีเขียว + เสียงติ๊ด
- Duplicate: สีแดง + เสียงเตือน
- Invalid: สีส้ม + เสียง Error
- Ready: สีเทา/ขาว

### 3.4 History Module

แสดงรายการที่บันทึกสำเร็จทั้งหมด

เรียงล่าสุดก่อน

### 3.5 Search Module

ค้นหาเลข Tracking

กรณีเจอ

- แสดงเลข
- วันที่
- เวลา

กรณีไม่เจอ

- แสดงข้อความไม่พบข้อมูล

### 3.6 Export Module

Export CSV และเปิด Android Share Sheet

Flow

```text
กด Export CSV
↓
อ่านข้อมูลทั้งหมดจาก SQLite
↓
สร้าง CSV
↓
บันทึกไฟล์
↓
แสดง Popup Export สำเร็จ
↓
กดแชร์ไฟล์
↓
เปิด Android Share Sheet
```

## 4. Data Flow

### 4.1 New Tracking

```text
Scanner Input
→ Scanner Service
→ Duplicate Service
→ Repository.findByTracking()
→ Not Found
→ Repository.insert()
→ AlertService.success()
→ UI Green
→ Counter +1
→ Clear Input
→ Focus Input
```

### 4.2 Duplicate Tracking

```text
Scanner Input
→ Scanner Service
→ Duplicate Service
→ Repository.findByTracking()
→ Found
→ Do Not Insert
→ AlertService.duplicate()
→ UI Red
→ Show Previous scanned_at
→ Counter unchanged
→ Clear Input
→ Focus Input
```

### 4.3 Invalid Tracking

```text
Scanner Input
→ Scanner Service
→ Validate
→ Invalid
→ Do Not Insert
→ AlertService.error()
→ UI Orange
→ Counter unchanged
→ Clear Input
→ Focus Input
```

## 5. Folder Structure

```text
lib/
  main.dart
  app.dart

  core/
    constants.dart
    date_helper.dart
    sound_helper.dart
    file_helper.dart
    app_colors.dart
    app_text_styles.dart

  database/
    sqlite_helper.dart

  models/
    tracking_log.dart
    scan_result.dart

  repositories/
    tracking_repository.dart

  services/
    scanner_service.dart
    duplicate_service.dart
    export_service.dart
    alert_service.dart
    permission_service.dart

  screens/
    scanner_screen.dart
    history_screen.dart

  widgets/
    counter_card.dart
    status_card.dart
    action_button.dart
    scanner_input.dart
    confirm_dialog.dart
    search_dialog.dart

assets/
  sounds/
    success.mp3
    duplicate.mp3
    error.mp3
```

## 6. State Management

เพื่อให้โปรเจกต์เล็กและดูแลง่าย ใช้ `ChangeNotifier` หรือ `ValueNotifier` ได้

ห้าม Over-engineer

ตัวเลือกแนะนำ

- ValueNotifier สำหรับสถานะหน้าสแกน
- StatefulWidget + service/repository injection ก็เพียงพอ
- ถ้าใช้ Provider ได้ แต่ไม่จำเป็นต้องใช้ BLoC

## 7. Future Ready

แม้เวอร์ชันนี้เป็น Offline เครื่องเดียว แต่โครงสร้างต้องแยกชั้นให้ดี เพื่อให้อนาคตเพิ่ม Server ได้โดยไม่รื้อระบบ

ตัวอย่างการต่อยอดอนาคต

```text
Repository
  ├── Local SQLite
  └── Remote API
```

แต่เวอร์ชันปัจจุบันห้ามทำ Remote API
