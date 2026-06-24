class ScanSession {
  const ScanSession({
    this.id,
    required this.scannerName,
    required this.exportRound,
    required this.carrier,
    required this.driverName,
    required this.vehiclePlate,
    required this.createdAt,
  });

  final int? id;
  final String scannerName;
  final String exportRound;
  final String carrier;
  final String driverName;
  final String vehiclePlate;
  final DateTime createdAt;

  String get scanId {
    final date =
        '${createdAt.year}${createdAt.month.toString().padLeft(2, '0')}${createdAt.day.toString().padLeft(2, '0')}';
    return '$date--$carrier';
  }

  ScanSession copyWith({int? id}) {
    return ScanSession(
      id: id ?? this.id,
      scannerName: scannerName,
      exportRound: exportRound,
      carrier: carrier,
      driverName: driverName,
      vehiclePlate: vehiclePlate,
      createdAt: createdAt,
    );
  }

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'scanner_name': scannerName,
      'export_round': exportRound,
      'carrier': carrier,
      'driver_name': driverName,
      'vehicle_plate': vehiclePlate,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory ScanSession.fromMap(Map<String, Object?> map) {
    return ScanSession(
      id: map['id'] as int?,
      scannerName: map['scanner_name'] as String,
      exportRound: map['export_round'] as String,
      carrier: map['carrier'] as String,
      driverName: map['driver_name'] as String,
      vehiclePlate: map['vehicle_plate'] as String,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }
}
