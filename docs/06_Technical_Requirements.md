# 06 Technical Requirements

## 1. Platform

- Android
- Target Device: PDA iT88
- Android Version: 14
- Build Output: APK

## 2. Framework

- Flutter Latest Stable
- Dart Latest Stable compatible with Flutter version

## 3. Required Packages

แนะนำ Package ดังนี้

```yaml
dependencies:
  flutter:
    sdk: flutter

  sqflite: ^2.3.0
  path: ^1.9.0
  path_provider: ^2.1.0
  share_plus: ^10.0.0
  intl: ^0.19.0
  audioplayers: ^6.0.0
```

หมายเหตุ: Version สามารถปรับเป็น Latest Stable ได้ตาม Flutter SDK ที่ใช้งานจริง

## 4. Android 14 File Handling

ให้สร้างไฟล์ CSV ใน App Directory หรือ External App Directory ที่ปลอดภัย

แนะนำใช้

```dart
getApplicationDocumentsDirectory()
```

หรือ

```dart
getExternalStorageDirectory()
```

ถ้าใช้ External Storage ต้องจัดการ Permission ให้เหมาะกับ Android 14

หลักการ

- หลีกเลี่ยง Permission ที่ไม่จำเป็น
- ใช้ Share Sheet เพื่อแชร์ไฟล์ออก
- ถ้าไฟล์อยู่ใน App Directory ต้องใช้ share_plus ที่รองรับ File sharing ผ่าน FileProvider

## 5. Permission

ต้องขอ Permission เท่าที่จำเป็นเท่านั้น

ระบบนี้ปกติไม่ต้องใช้ Camera เพราะรับค่าจากหัวสแกนแบบ Keyboard Input

ไม่ต้องขอ Camera Permission เว้นแต่เพิ่มฟีเจอร์สแกนด้วยกล้อง ซึ่งไม่ได้อยู่ใน Scope

## 6. Scanner Input Handling

หัวสแกนทำงานแบบ Keyboard Wedge

ต้องรองรับ

- Input เข้าช่อง TextField
- อาจมี Enter / Newline ต่อท้าย
- อาจมี Suffix อื่น
- ต้อง Trim และ Clean ก่อน Validate

Pseudo

```dart
final cleaned = rawInput.trim().replaceAll('\n', '').replaceAll('\r', '');
```

## 7. Detect Scan Completed

Primary Approach

- ใช้ `onSubmitted` หาก Scanner ส่ง Enter

Fallback

- ใช้ debounce 200–300 ms หลัง Text Changed เพื่อ Process เมื่อไม่มี Input เพิ่ม

ต้องป้องกันการ Process ซ้ำ

ใช้ flag เช่น

```dart
bool _isProcessing = false;
String _lastProcessed = '';
DateTime? _lastProcessedAt;
```

## 8. Duplicate Safety

ต้องกันซ้ำ 2 ชั้น

1. Application Logic ตรวจ `findByTrackingNumber`
2. Database UNIQUE constraint

ถ้าเกิด Unique Constraint Error ให้ถือว่าเป็น Duplicate ไม่ใช่ Crash

## 9. Performance

ระบบต้องรองรับการสแกนเร็ว

Requirement

- Query ด้วย UNIQUE index
- ห้ามโหลดข้อมูลทั้งหมดทุกครั้งเพื่อตรวจซ้ำ
- ใช้ `SELECT ... WHERE tracking_number = ? LIMIT 1`
- Insert ต้องเร็ว
- Clear Input ทันทีหลัง Process
- UI ไม่ค้าง

## 10. Error Handling

ต้องมี Try/Catch รอบงานสำคัญ

- Database open
- Insert
- Query
- Delete
- Export
- Share
- Audio play

ทุก Error ต้องแสดงข้อความไทยที่เข้าใจง่าย

## 11. Audio

ใช้ assets

```text
assets/sounds/success.mp3
assets/sounds/duplicate.mp3
assets/sounds/error.mp3
```

ถ้าไม่มีไฟล์เสียงจริง ให้สร้าง placeholder หรือใช้ system sound fallback

ต้องประกาศใน pubspec.yaml

```yaml
flutter:
  assets:
    - assets/sounds/success.mp3
    - assets/sounds/duplicate.mp3
    - assets/sounds/error.mp3
```

## 12. Date Time

เก็บเป็น ISO8601

แสดงผลเป็นไทย

```text
dd/MM/yyyy HH:mm:ss
```

CSV แยก Date / Time

```text
Date = dd/MM/yyyy
Time = HH:mm:ss
```

## 13. CSV Encoding

เพื่อให้ Excel เปิดภาษาไทยได้ดี ควรใส่ BOM UTF-8

```text
\uFEFF
```

ก่อนเนื้อหา CSV

แม้ข้อมูลหลักเป็นตัวเลข แต่ Header มีภาษาอังกฤษได้ เพื่อลดปัญหา

Header แนะนำ

```text
No,Tracking Number,Date,Time
```

## 14. Responsive PDA

UI ต้องรองรับหน้าจอ PDA

- หน้าจอเล็ก
- ปุ่มใหญ่
- ไม่ใช้ Layout แน่นเกินไป
- ใช้ ScrollView เมื่อจำเป็น

## 15. Build

ต้อง Build APK ได้

Command

```bash
flutter clean
flutter pub get
flutter build apk --release
```

หากมี signing ภายหลังค่อยเพิ่ม ไม่จำเป็นในเวอร์ชันเริ่มต้น
