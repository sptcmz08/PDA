# 08 Development Plan

## Overview

ให้พัฒนาแบบทีละ Phase เพื่อลด Bug และตรวจสอบง่าย

ห้ามทำทุกอย่างรวดเดียวจนตรวจยาก

---

# Phase 1: Project Setup

## Goal

สร้าง Flutter Project และโครงสร้างไฟล์

## Tasks

- Create Flutter Project
- Setup pubspec.yaml
- Add dependencies
- Create folder structure
- Add assets/sounds folder
- Setup basic app theme
- Create App entry

## Output

- Project run ได้
- หน้าจอหลัก placeholder แสดงผลได้

## Command

```bash
flutter pub get
flutter run
```

---

# Phase 2: Database Layer

## Goal

ทำ SQLite ให้เสร็จ

## Tasks

- Create sqlite_helper.dart
- Create tracking_logs table
- Add UNIQUE tracking_number
- Create TrackingLog model
- Create TrackingRepository
- Implement insert
- Implement findByTrackingNumber
- Implement getAll
- Implement countAll
- Implement clearAll

## Test

- Insert ได้
- Insert ซ้ำแล้วไม่ทำให้แอป Crash
- Query ได้
- Count ได้
- Clear ได้

---

# Phase 3: Scanner Screen + Auto Focus

## Goal

ทำหน้าหลักสำหรับสแกน

## Tasks

- Create scanner_screen.dart
- Create scanner_input.dart
- Auto Focus TextField
- Clear Input after scan
- Refocus after scan
- Support onSubmitted
- Add debounce fallback
- Add Counter UI
- Add Status Card
- Add Action Buttons

## Test

- เปิดแอปแล้ว Focus ช่องสแกน
- พิมพ์เลขแล้ว Enter ทำงาน
- หลัง Process ช่องว่างและ Focus กลับ

---

# Phase 4: Validation + Duplicate Check

## Goal

ทำ Logic หลักของระบบ

## Tasks

- Create scanner_service.dart
- Create duplicate_service.dart
- Validate numeric 12 digits
- Check duplicate
- Insert new tracking
- Return ScanResult
- Handle duplicate
- Handle invalid

## Test Cases

```text
829362431516 → success
829362431516 อีกครั้ง → duplicate
82936 → invalid
JT123456789TH → invalid
ค่าว่าง → invalid
```

---

# Phase 5: Alert Sound + UI State

## Goal

ทำเสียงและสีสถานะ

## Tasks

- Create alert_service.dart
- Add success sound
- Add duplicate sound
- Add error sound
- Status green/red/orange
- Show previous scanned_at when duplicate
- Counter update only when success

## Test

- เลขใหม่เสียง success
- เลขซ้ำเสียง duplicate
- เลขผิดเสียง error
- สีเปลี่ยนถูกต้อง
- Counter ถูกต้อง

---

# Phase 6: Search + History

## Goal

ค้นหาและดูประวัติได้

## Tasks

- Create search_dialog.dart
- Create history_screen.dart
- Search exact tracking
- Show found / not found
- Show history newest first
- Scroll list

## Test

- ค้นหาเลขที่มี เจอ
- ค้นหาเลขที่ไม่มี ไม่พบ
- History เรียงล่าสุดก่อน

---

# Phase 7: Export CSV + Share

## Goal

Export CSV และแชร์ LINE ได้

## Tasks

- Create export_service.dart
- Create CSV file
- Add UTF-8 BOM
- File name Tracking_YYYY-MM-DD_HH-mm.csv
- Save to app folder or external app directory
- Show success dialog
- Share file via Android Share Sheet

## Test

- Export สำเร็จ
- เปิด CSV ใน Excel ได้
- Share Sheet เปิดได้
- เลือก LINE ได้ถ้าเครื่องติดตั้ง LINE

---

# Phase 8: Start New Round

## Goal

ล้างข้อมูลเพื่อเริ่มรอบใหม่

## Tasks

- Add confirm dialog
- Clear SQLite
- Reset counter
- Clear status
- Focus scanner input

## Test

- กดยกเลิกแล้วข้อมูลอยู่
- กดยืนยันแล้วข้อมูลหาย
- Counter = 0
- พร้อมสแกนต่อ

---

# Phase 9: Error Handling + Polish

## Goal

เก็บงานให้พร้อมใช้งานจริง

## Tasks

- Add try/catch
- Add Thai error messages
- Improve layout for PDA
- Check focus edge cases
- Check fast scan
- Check export empty list
- Prevent double processing same input

## Test

- กดยิงเร็ว ๆ ไม่ Insert ซ้ำผิดพลาด
- Export ตอนยังไม่มีข้อมูล แสดงข้อความเหมาะสม
- ปิดเปิดแอปข้อมูลยังอยู่
- เริ่มรอบใหม่แล้วข้อมูลล้างจริง

---

# Phase 10: Build APK

## Goal

Build APK พร้อมติดตั้ง

## Tasks

- flutter clean
- flutter pub get
- flutter analyze
- flutter build apk --release
- Test install on PDA

## Output

- APK
- Source Code
- คู่มือ Build
- คู่มือใช้งาน
