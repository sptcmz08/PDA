# 03 Database Design

## 1. Database

ใช้ SQLite ภายในเครื่อง PDA

Database Name

```text
pda_tracking_scanner.db
```

## 2. Table: tracking_logs

ใช้เก็บเลข Tracking ที่สแกนสำเร็จเท่านั้น

```sql
CREATE TABLE tracking_logs (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  tracking_number TEXT NOT NULL UNIQUE,
  scanned_at TEXT NOT NULL
);
```

## 3. Field Description

| Field | Type | Required | Description |
|---|---|---:|---|
| id | INTEGER | Yes | Running ID |
| tracking_number | TEXT | Yes | เลข Tracking 12 หลัก |
| scanned_at | TEXT | Yes | วันที่เวลาที่สแกน ISO8601 |

## 4. Constraint

### UNIQUE tracking_number

ต้องมี UNIQUE ที่ `tracking_number`

เหตุผล

- กันเลขซ้ำระดับ Database
- ป้องกันกรณี Logic ฝั่ง App ผิดพลาด
- ป้องกัน Race Condition ระหว่างสแกนเร็ว ๆ

## 5. Index

เนื่องจาก `tracking_number` เป็น UNIQUE อยู่แล้ว SQLite จะสร้าง Index ให้โดยอัตโนมัติ

ห้ามลบ UNIQUE constraint

## 6. Date Format

ให้เก็บ `scanned_at` เป็น ISO8601 เช่น

```text
2026-06-18T14:30:05.000
```

เวลาแสดงผลค่อย Format เป็น

```text
18/06/2026 14:30:05
```

## 7. Model

TrackingLog

```dart
class TrackingLog {
  final int? id;
  final String trackingNumber;
  final DateTime scannedAt;
}
```

## 8. Required Repository Methods

```dart
Future<int> insert(TrackingLog log);

Future<TrackingLog?> findByTrackingNumber(String trackingNumber);

Future<List<TrackingLog>> getAll({bool newestFirst = true});

Future<int> countAll();

Future<void> clearAll();

Future<bool> exists(String trackingNumber);
```

## 9. Insert Logic

ห้าม Insert โดยไม่ Validate

ลำดับที่ถูกต้อง

```text
trim
↓
validate numeric 12 digits
↓
find duplicate
↓
insert
```

และควร Catch Unique Constraint Error อีกชั้น

## 10. Clear Round Logic

ปุ่ม "เริ่มรอบใหม่" ให้ล้างข้อมูลทั้งหมดในตาราง

```sql
DELETE FROM tracking_logs;
```

จากนั้น Reset Auto Increment ถ้าต้องการ

```sql
DELETE FROM sqlite_sequence WHERE name='tracking_logs';
```

หมายเหตุ: Reset Auto Increment ไม่จำเป็นต่อการใช้งาน แต่ช่วยให้ CSV เริ่ม No ใหม่ได้ง่าย

## 11. Export Query

Export CSV ต้องดึงข้อมูลเรียงตามเวลาสแกนจากเก่าไปใหม่ เพื่อให้ลำดับไฟล์ตรงตามการสแกนจริง

```sql
SELECT * FROM tracking_logs ORDER BY scanned_at ASC;
```

## 12. History Query

History บนหน้าจอให้เรียงล่าสุดก่อน

```sql
SELECT * FROM tracking_logs ORDER BY scanned_at DESC;
```

## 13. Search Query

```sql
SELECT * FROM tracking_logs WHERE tracking_number = ? LIMIT 1;
```

## 14. Data Safety

- ห้ามบันทึกเลขซ้ำ
- ห้ามบันทึกค่าว่าง
- ห้ามบันทึกเลขไม่ครบ 12 หลัก
- ห้ามบันทึกตัวอักษร
- ห้ามล้างข้อมูลโดยไม่ Confirm
