# 10 AI Implementation Prompt

ใช้ Prompt นี้กับ AI Code เช่น Cursor, Cline, Claude Code, Gemini CLI, Codex หรือ VS Code AI

---

## Main Prompt

คุณคือ Senior Flutter Developer

ให้พัฒนาแอป Android สำหรับเครื่อง PDA รุ่น iT88 ระบบ Android 14 ใช้สำหรับสแกนเลข Tracking จากใบปะหน้าขนส่ง เพื่อป้องกันการสแกนเลขซ้ำ โดยเน้นใช้งานง่ายที่สุด ทำงานแบบ Offline 100% และไม่ต้องมี Server

ก่อนเริ่มเขียนโค้ด ให้อ่านเอกสารทั้งหมดในโฟลเดอร์ `docs/`

ห้ามเขียนโค้ดจนกว่าจะอ่าน Requirement ครบ

หลังอ่านครบแล้ว ให้สรุปความเข้าใจทั้งหมดก่อน จากนั้นพัฒนาแบบทีละ Phase ตาม `08_Development_Plan.md`

ห้ามเพิ่มฟีเจอร์นอกเหนือจาก Requirement

หาก Requirement ขัดแย้ง ให้ถามก่อน ห้ามเดา

## Project Requirements Summary

- Flutter Latest Stable
- Android APK
- SQLite Local Database
- Offline 100%
- Keyboard Wedge Scanner Input
- Auto Focus Scanner Input
- Validate Tracking เป็นตัวเลข 12 หลัก
- Duplicate Check
- Success / Duplicate / Error Sound
- Counter
- Search
- History
- Export CSV
- Share File via Android Share Sheet
- Start New Round
- No Server
- No Login
- No Sync
- No Web Admin

## Device

- PDA รุ่น iT88
- Android 14
- Scanner ทำงานแบบ Keyboard Input / Keyboard Wedge
- ยิงแล้วเลขเข้า Text Field อัตโนมัติ

## Tracking Format

Valid Tracking ต้องเป็นตัวเลข 12 หลัก

ตัวอย่าง

```text
829362431516
829360206500
829353044505
829357386314
829352691775
829361951095
```

## Development Instruction

ให้พัฒนาเป็น Phase เท่านั้น

### Phase 1

สร้าง Flutter Project และ Folder Structure

### Phase 2

ทำ SQLite Database, Model, Repository

### Phase 3

ทำ Scanner Screen + Auto Focus

### Phase 4

ทำ Validation + Duplicate Check

### Phase 5

ทำ Alert Sound + UI State + Counter

### Phase 6

ทำ Search + History

### Phase 7

ทำ Export CSV + Share File

### Phase 8

ทำ Start New Round

### Phase 9

ทำ Error Handling + Polish

### Phase 10

Build APK

หลังทำแต่ละ Phase เสร็จ ให้สรุป

- ไฟล์ที่สร้าง/แก้ไข
- วิธีทดสอบ
- สิ่งที่เสร็จแล้ว
- สิ่งที่จะทำ Phase ถัดไป

## Strict Rules

ห้ามเพิ่ม

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
- Notification
- Camera Scanner

ทำเฉพาะแอป Offline สำหรับ PDA เครื่องเดียวเท่านั้น

## Completion Criteria

งานจะถือว่าเสร็จเมื่อผ่าน Acceptance Test ทั้งหมดในไฟล์ `09_Acceptance_Test.md`

ต้อง Build APK ได้ด้วยคำสั่ง

```bash
flutter clean
flutter pub get
flutter analyze
flutter build apk --release
```
