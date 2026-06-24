import 'package:flutter/material.dart';

import '../core/app_colors.dart';
import '../core/app_text_styles.dart';
import '../core/date_helper.dart';
import '../models/scan_result.dart';

class StatusCard extends StatelessWidget {
  const StatusCard({
    required this.result,
    super.key,
  });

  final ScanResult result;

  @override
  Widget build(BuildContext context) {
    final color = switch (result.status) {
      ScanStatus.ready => AppColors.ready,
      ScanStatus.success => AppColors.success,
      ScanStatus.duplicate => AppColors.duplicate,
      ScanStatus.invalid => AppColors.invalid,
      ScanStatus.error => AppColors.duplicate,
    };
    final foreground = result.status == ScanStatus.ready
        ? AppColors.text
        : Colors.white;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              'สถานะล่าสุด',
              style: AppTextStyles.title.copyWith(color: foreground),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              _buildMessage(),
              style: AppTextStyles.body.copyWith(color: foreground),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  String _buildMessage() {
    final trackingNumber = result.trackingNumber;
    final previousScannedAt = result.previousScannedAt;

    if (result.status == ScanStatus.invalid) {
      return '${result.message}\nต้องเป็นตัวเลข 12 หลัก';
    }
    if (result.status == ScanStatus.duplicate) {
      final previousText = previousScannedAt == null
          ? ''
          : '\nเคยสแกนเมื่อ ${DateHelper.formatDateTime(previousScannedAt)}';
      return '${result.message}\n$trackingNumber$previousText';
    }
    if (trackingNumber == null) {
      return result.message;
    }
    return '${result.message}\n$trackingNumber';
  }
}
