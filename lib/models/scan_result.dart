enum ScanStatus {
  ready,
  success,
  duplicate,
  invalid,
  error,
}

class ScanResult {
  const ScanResult({
    required this.status,
    required this.message,
    this.trackingNumber,
    this.previousScannedAt,
  });

  final ScanStatus status;
  final String message;
  final String? trackingNumber;
  final DateTime? previousScannedAt;

  static const ready = ScanResult(
    status: ScanStatus.ready,
    message: 'พร้อมสแกน',
  );
}
