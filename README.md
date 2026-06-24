# PDA Tracking Scanner App

เอกสารชุดนี้ใช้สำหรับสั่งงาน AI Code / โปรแกรมเมอร์ เพื่อพัฒนาแอป Android สำหรับเครื่อง PDA รุ่น iT88 Android 14 ใช้สแกนเลข Tracking จากใบปะหน้าขนส่ง และป้องกันเลขซ้ำแบบ Offline

## เป้าหมายหลัก

แอปต้องใช้งานง่ายมากที่สุดสำหรับพนักงานหน้างาน

Workflow หลัก:

```text
เปิดแอป
↓
พร้อมสแกนทันที
↓
ยิงบาร์โค้ด
↓
เลขใหม่ → บันทึก + เสียงติ๊ด + สีเขียว
เลขซ้ำ → ไม่บันทึก + เสียง Alert + สีแดง
รูปแบบผิด → ไม่บันทึก + เสียง Error + สีส้ม
↓
พร้อมยิงต่อทันที
↓
จบงาน → Export CSV → แชร์ผ่าน LINE
```

## ข้อมูลอุปกรณ์

- PDA รุ่น: iT88
- Android: 14
- การเชื่อมต่อ: WiFi
- หัวสแกน: Barcode / QR ในตัว
- วิธีส่งข้อมูล: Keyboard Wedge / Keyboard Input
- ลักษณะการใช้งาน: กดยิงแล้วเลขเข้า Text Field อัตโนมัติ เหมือน BigSeller
- ไม่ต้องใช้ Server
- ไม่ต้อง Sync หลายเครื่อง
- ไม่ต้อง Login

## ตัวอย่าง Tracking จริง

```text
829362431516
829360206500
829353044505
829357386314
829352691775
829361951095
```

## เอกสารในชุดนี้

```text
docs/
├── 01_Project_Overview.md
├── 02_System_Architecture.md
├── 03_Database_Design.md
├── 04_UI_UX_Design.md
├── 05_Functional_Requirements.md
├── 06_Technical_Requirements.md
├── 07_Project_Rules.md
├── 08_Development_Plan.md
├── 09_Acceptance_Test.md
└── 10_AI_Implementation_Prompt.md
```

## คำสั่งเริ่มต้นสำหรับ AI Code

ให้อ่านไฟล์ทั้งหมดในโฟลเดอร์ `docs/` ก่อนเริ่มเขียนโค้ด

```text
อ่านเอกสารทั้งหมดในโฟลเดอร์ docs ก่อน ห้ามเขียนโค้ดจนกว่าจะอ่าน Requirement ครบ
หลังอ่านครบแล้วให้สรุปความเข้าใจก่อน
จากนั้นให้พัฒนาแบบทีละ Phase ตาม 08_Development_Plan.md
ห้ามเพิ่มฟีเจอร์นอกเหนือจาก Requirement
หาก Requirement ขัดแย้ง ให้ถามก่อน ไม่ต้องเดา
```
