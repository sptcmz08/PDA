import '../models/tracking_log.dart';
import '../repositories/tracking_repository.dart';

class DuplicateService {
  const DuplicateService({
    required TrackingRepository repository,
  }) : _repository = repository;

  final TrackingRepository _repository;

  Future<TrackingLog?> findDuplicate(String trackingNumber) {
    return _repository.findByTrackingNumber(trackingNumber);
  }
}
