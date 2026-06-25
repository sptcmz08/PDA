import 'dart:io';

import 'package:share_plus/share_plus.dart';
import 'package:syncfusion_flutter_xlsio/xlsio.dart' as xlsio;

import '../core/date_helper.dart';
import '../core/file_helper.dart';
import '../models/scan_session.dart';
import '../models/tracking_log.dart';
import '../repositories/tracking_repository.dart';

class NoExportDataException implements Exception {
  const NoExportDataException();
}

class NoExportSessionException implements Exception {
  const NoExportSessionException();
}

class ExportService {
  const ExportService({
    required TrackingRepository repository,
  }) : _repository = repository;

  final TrackingRepository _repository;

  static const _excelMimeType =
      'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet';

  Future<File> exportExcel({required ScanSession? session}) async {
    if (session == null) {
      throw const NoExportSessionException();
    }

    final logs = await _repository.getAll(newestFirst: false);
    if (logs.isEmpty) {
      throw const NoExportDataException();
    }

    final workbook = xlsio.Workbook();
    try {
      final sheet = workbook.worksheets[0];
      sheet.name = 'PDA Scan Report';
      _buildReport(sheet, session, logs);

      final bytes = workbook.saveAsStream();
      final now = DateTime.now();
      
      // Format date as YYMMDD
      final dateStr = DateHelper.formatYyMMdd(now);
      
      // Clean and pad the export round
      final rawRound = session.exportRound.replaceAll(RegExp(r'[^0-9]'), '');
      final roundStr = rawRound.isEmpty ? '01' : rawRound.padLeft(2, '0');
      
      final fileName = 'VIP_${dateStr}_R${roundStr}_${logs.length}.xlsx';
      return FileHelper.createBinaryDocumentFile(fileName: fileName, bytes: bytes);
    } finally {
      workbook.dispose();
    }
  }

  Future<void> shareFile(File file) async {
    final fileName = file.uri.pathSegments.last;
    await Share.shareXFiles(
      [XFile(file.path, mimeType: _excelMimeType, name: fileName)],
      subject: fileName,
      fileNameOverrides: [fileName],
    );
  }

  void _buildReport(
    xlsio.Worksheet sheet,
    ScanSession session,
    List<TrackingLog> logs,
  ) {
    _setColumnWidths(sheet);

    final firstScanAt = logs.first.scannedAt;
    final lastScanAt = logs.last.scannedAt;

    _mergeText(
      sheet,
      'A1:K1',
      'PDA SCAN REPORT / รายงานยิงเลขพัสดุก่อนส่งออก',
      backColor: '#0F766E',
      fontColor: '#FFFFFF',
      bold: true,
      center: true,
    );

    final labels = <String>[
      'Scan ID / เลขรอบสแกน',
      'วันที่สแกน',
      'เวลาเริ่มสแกน',
      'เวลาสิ้นสุด',
      'รอบส่งออก',
      'ขนส่ง',
      'พนักงานสแกน',
      'ชื่อคนขับรถ',
      'เลขทะเบียนรถที่เข้ารับ',
      'หมายเหตุ',
    ];
    final values = <String>[
      session.scanId,
      DateHelper.formatDate(session.createdAt),
      DateHelper.formatTime(firstScanAt),
      DateHelper.formatTime(lastScanAt),
      session.exportRound,
      session.carrier,
      session.scannerName,
      session.driverName,
      session.vehiclePlate,
      '',
    ];

    for (var i = 0; i < labels.length; i++) {
      final row = i + 3;
      _setText(sheet, row, 1, labels[i], backColor: '#E2F0D9', bold: true);
      _mergeText(sheet, 'B$row:D$row', values[i]);
    }

    _setText(sheet, 4, 5, 'จำนวนที่สแกนจริง', backColor: '#E2F0D9', bold: true);
    _setNumber(sheet, 4, 6, logs.length.toDouble(), center: true);
    _setText(sheet, 5, 5, 'เลขซ้ำ', backColor: '#E2F0D9', bold: true);
    _setNumber(sheet, 5, 6, 0, center: true);

    _mergeText(
      sheet,
      'H3:K3',
      'ข้อแนะนำในแอ: ให้กรอกก่อนเริ่มยิง',
      backColor: '#0F766E',
      fontColor: '#FFFFFF',
      bold: true,
      center: true,
    );
    final guide = <String>[
      'ชื่อผู้สแกน',
      'รอบส่งออก',
      'ขนส่ง',
      'ชื่อคนขับรถ',
      'เลขทะเบียนรถที่เข้ารับ',
    ];
    for (var i = 0; i < guide.length; i++) {
      final row = i + 4;
      _setNumber(sheet, row, 8, (i + 1).toDouble(), backColor: '#E2F0D9', center: true, bold: true);
      _mergeText(sheet, 'I$row:K$row', guide[i], bold: true);
    }

    const headerRow = 14;
    final headers = <String>[
      'No.',
      'เลขพัสดุ / Tracking No.',
      'เวลาสแกน',
      'ผลตรวจซ้ำ',
    ];
    for (var i = 0; i < headers.length; i++) {
      _setText(
        sheet,
        headerRow,
        i + 1,
        headers[i],
        backColor: '#0F766E',
        fontColor: '#FFFFFF',
        bold: true,
        center: true,
      );
    }

    for (var i = 0; i < logs.length; i++) {
      final row = headerRow + i + 1;
      final log = logs[i];
      _setNumber(sheet, row, 1, (i + 1).toDouble(), center: true);
      _setText(sheet, row, 2, log.trackingNumber, center: true);
      _setText(sheet, row, 3, DateHelper.formatTime(log.scannedAt), center: true);
      _setText(sheet, row, 4, 'ผ่าน', center: true);
    }

    final tableEndRow = headerRow + logs.length;
    _applyBorders(sheet.getRangeByName('A3:D12'));
    _applyBorders(sheet.getRangeByName('E4:F5'));
    _applyBorders(sheet.getRangeByName('H3:K8'));
    _applyBorders(sheet.getRangeByName('A$headerRow:D$tableEndRow'));

    sheet.getRangeByName('A1:K$tableEndRow').cellStyle.fontName = 'Arial';
    sheet.getRangeByName('A1:K$tableEndRow').cellStyle.fontSize = 11;
    sheet.getRangeByName('A1:K$tableEndRow').cellStyle.vAlign = xlsio.VAlignType.center;
    sheet.getRangeByName('B15:B$tableEndRow').cellStyle.numberFormat = '@';
  }

  void _setColumnWidths(xlsio.Worksheet sheet) {
    final widths = <int, double>{
      1: 11,
      2: 28,
      3: 16,
      4: 16,
      5: 18,
      6: 12,
      7: 4,
      8: 10,
      9: 18,
      10: 18,
      11: 18,
    };
    for (final entry in widths.entries) {
      sheet.getRangeByIndex(1, entry.key).columnWidth = entry.value;
    }
    for (var row = 1; row <= 80; row++) {
      sheet.getRangeByIndex(row, 1).rowHeight = row == 1 ? 22 : 19;
    }
  }

  void _setText(
    xlsio.Worksheet sheet,
    int row,
    int column,
    String value, {
    String? backColor,
    String? fontColor,
    bool bold = false,
    bool center = false,
  }) {
    final range = sheet.getRangeByIndex(row, column);
    range.setText(value);
    _styleRange(
      range,
      backColor: backColor,
      fontColor: fontColor,
      bold: bold,
      center: center,
    );
  }

  void _setNumber(
    xlsio.Worksheet sheet,
    int row,
    int column,
    double value, {
    String? backColor,
    bool bold = false,
    bool center = false,
  }) {
    final range = sheet.getRangeByIndex(row, column);
    range.setNumber(value);
    _styleRange(range, backColor: backColor, bold: bold, center: center);
  }

  void _mergeText(
    xlsio.Worksheet sheet,
    String cellRange,
    String value, {
    String? backColor,
    String? fontColor,
    bool bold = false,
    bool center = false,
  }) {
    final range = sheet.getRangeByName(cellRange);
    range.merge();
    range.setText(value);
    _styleRange(
      range,
      backColor: backColor,
      fontColor: fontColor,
      bold: bold,
      center: center,
    );
  }

  void _styleRange(
    xlsio.Range range, {
    String? backColor,
    String? fontColor,
    bool bold = false,
    bool center = false,
  }) {
    if (backColor != null) {
      range.cellStyle.backColor = backColor;
    }
    if (fontColor != null) {
      range.cellStyle.fontColor = fontColor;
    }
    range.cellStyle.bold = bold;
    range.cellStyle.wrapText = true;
    if (center) {
      range.cellStyle.hAlign = xlsio.HAlignType.center;
    }
    range.cellStyle.vAlign = xlsio.VAlignType.center;
  }

  void _applyBorders(xlsio.Range range) {
    range.cellStyle.borders.all.lineStyle = xlsio.LineStyle.thin;
    range.cellStyle.borders.all.color = '#D9D9D9';
  }
}

