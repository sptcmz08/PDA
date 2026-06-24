import 'package:flutter/material.dart';

import '../core/date_helper.dart';
import '../repositories/tracking_repository.dart';

class SearchDialog extends StatefulWidget {
  const SearchDialog({
    required this.repository,
    super.key,
  });

  final TrackingRepository repository;

  @override
  State<SearchDialog> createState() => _SearchDialogState();
}

class _SearchDialogState extends State<SearchDialog> {
  final _controller = TextEditingController();
  String? _resultText;
  bool _isSearching = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('ค้นหาเลข Tracking'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: _controller,
            keyboardType: TextInputType.number,
            autofocus: true,
            decoration: const InputDecoration(
              labelText: 'กรอกเลข Tracking',
            ),
            onSubmitted: (_) => _search(),
          ),
          if (_resultText != null) ...[
            const SizedBox(height: 16),
            Text(_resultText!),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('ปิด'),
        ),
        FilledButton(
          onPressed: _isSearching ? null : _search,
          child: const Text('ค้นหา'),
        ),
      ],
    );
  }

  Future<void> _search() async {
    final trackingNumber = _controller.text.trim();
    if (trackingNumber.isEmpty) {
      setState(() => _resultText = 'ไม่พบข้อมูล');
      return;
    }

    setState(() => _isSearching = true);
    try {
      final log = await widget.repository.findByTrackingNumber(trackingNumber);
      if (!mounted) {
        return;
      }
      setState(() {
        if (log == null) {
          _resultText = 'ไม่พบข้อมูล';
        } else {
          _resultText = 'พบข้อมูล\n'
              '${log.trackingNumber}\n'
              'วันที่ ${DateHelper.formatDate(log.scannedAt)}\n'
              'เวลา ${DateHelper.formatTime(log.scannedAt)}';
        }
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() => _resultText = 'ไม่พบข้อมูล');
    } finally {
      if (mounted) {
        setState(() => _isSearching = false);
      }
    }
  }
}
