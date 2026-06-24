class TrackingLog {
  const TrackingLog({
    this.id,
    this.sessionId,
    required this.trackingNumber,
    required this.scannedAt,
  });

  final int? id;
  final int? sessionId;
  final String trackingNumber;
  final DateTime scannedAt;

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'session_id': sessionId,
      'tracking_number': trackingNumber,
      'scanned_at': scannedAt.toIso8601String(),
    };
  }

  factory TrackingLog.fromMap(Map<String, Object?> map) {
    return TrackingLog(
      id: map['id'] as int?,
      sessionId: map['session_id'] as int?,
      trackingNumber: map['tracking_number'] as String,
      scannedAt: DateTime.parse(map['scanned_at'] as String),
    );
  }
}
