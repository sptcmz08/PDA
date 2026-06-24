import 'package:flutter/material.dart';

class ConfirmDialog extends StatelessWidget {
  const ConfirmDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('ต้องการเริ่มรอบใหม่หรือไม่?'),
      content: const Text('ข้อมูลเดิมจะถูกล้างออกจากเครื่อง'),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('ยกเลิก'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: const Text('ยืนยัน'),
        ),
      ],
    );
  }
}
