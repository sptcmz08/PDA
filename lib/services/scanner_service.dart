import '../core/constants.dart';
import '../models/scan_result.dart';
import '../models/tracking_log.dart';
import '../repositories/tracking_repository.dart';
import 'duplicate_service.dart';

class ScannerService {
  const ScannerService({
    required TrackingRepository repository,
    required DuplicateService duplicateService,
  })  : _repository = repository,
        _duplicateService = duplicateService;

  final TrackingRepository _repository;
  final DuplicateService _duplicateService;

  Future<ScanResult> process(String rawInput, {required int sessionId}) async {
    final trackingNumber = cleanInput(rawInput);
    if (!isValidTracking(trackingNumber)) {
      return const ScanResult(
        status: ScanStatus.invalid,
        message: 'รูปแบบ Tracking ไม่ถูกต้อง',
      );
    }

    try {
      final duplicate = await _duplicateService.findDuplicate(trackingNumber);
      if (duplicate != null) {
        return ScanResult(
          status: ScanStatus.duplicate,
          message: 'เลขนี้ถูกสแกนแล้ว',
          trackingNumber: duplicate.trackingNumber,
          previousScannedAt: duplicate.scannedAt,
        );
      }

      final log = TrackingLog(
        sessionId: sessionId,
        trackingNumber: trackingNumber,
        scannedAt: DateTime.now(),
      );
      await _repository.insert(log);
      return ScanResult(
        status: ScanStatus.success,
        message: 'บันทึกสำเร็จ',
        trackingNumber: trackingNumber,
      );
    } on DuplicateTrackingException {
      final duplicate = await _repository.findByTrackingNumber(trackingNumber);
      return ScanResult(
        status: ScanStatus.duplicate,
        message: 'เลขนี้ถูกสแกนแล้ว',
        trackingNumber: trackingNumber,
        previousScannedAt: duplicate?.scannedAt,
      );
    } catch (_) {
      return const ScanResult(
        status: ScanStatus.error,
        message: 'ไม่สามารถบันทึกข้อมูลได้ กรุณาลองใหม่',
      );
    }
  }

  String cleanInput(String rawInput) {
    return rawInput.trim().replaceAll('\n', '').replaceAll('\r', '');
  }

  bool isValidTracking(String trackingNumber) {
    return AppConstants.trackingRegex.hasMatch(trackingNumber);
  }
}
