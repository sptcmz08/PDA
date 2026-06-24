import 'package:flutter/material.dart';

import '../core/date_helper.dart';
import '../models/tracking_log.dart';
import '../repositories/tracking_repository.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({
    required this.repository,
    super.key,
  });

  final TrackingRepository repository;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ประวัติการสแกน'),
      ),
      body: FutureBuilder<List<TrackingLog>>(
        future: repository.getAll(),
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text('ไม่สามารถโหลดประวัติได้'));
          }

          final logs = snapshot.data ?? const <TrackingLog>[];
          if (logs.isEmpty) {
            return const Center(child: Text('ไม่พบข้อมูล'));
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: logs.length,
            separatorBuilder: (context, index) => const Divider(height: 24),
            itemBuilder: (context, index) {
              final log = logs[index];
              return ListTile(
                title: Text('${index + 1}. ${log.trackingNumber}'),
                subtitle: Text(DateHelper.formatDateTime(log.scannedAt)),
              );
            },
          );
        },
      ),
    );
  }
}
