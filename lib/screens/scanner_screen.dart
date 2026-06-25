import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';

import '../core/app_colors.dart';
import '../core/constants.dart';
import '../database/sqlite_helper.dart';
import '../models/scan_result.dart';
import '../models/scan_session.dart';
import '../repositories/tracking_repository.dart';
import '../services/alert_service.dart';
import '../services/duplicate_service.dart';
import '../services/export_service.dart';
import '../services/scanner_service.dart';
import '../widgets/action_button.dart';
import '../widgets/confirm_dialog.dart';
import '../widgets/counter_card.dart';
import '../widgets/scanner_input.dart';
import '../widgets/search_dialog.dart';
import '../widgets/session_form_dialog.dart';
import '../widgets/status_card.dart';
import 'history_screen.dart';

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  late final TrackingRepository _repository;
  late final ScannerService _scannerService;
  late final AlertService _alertService;
  late final ExportService _exportService;

  final _controller = TextEditingController();
  final _focusNode = FocusNode();

  Timer? _debounceTimer;
  ScanResult _result = ScanResult.ready;
  ScanSession? _session;
  int _count = 0;
  bool _isProcessing = false;
  bool _isSessionDialogOpen = false;
  final List<String> _pendingRawInputs = [];

  @override
  void initState() {
    super.initState();
    _repository = TrackingRepository(sqliteHelper: SqliteHelper.instance);
    final duplicateService = DuplicateService(repository: _repository);
    _scannerService = ScannerService(
      repository: _repository,
      duplicateService: duplicateService,
    );
    _alertService = AlertService();
    _exportService = ExportService(repository: _repository);
    _loadInitialState();
    _requestScannerFocus();
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _controller.dispose();
    _focusNode.dispose();
    _alertService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppConstants.appTitle),
      ),
      body: SafeArea(
        child: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: _requestScannerFocus,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildSessionCard(),
                const SizedBox(height: 12),
                CounterCard(count: _count),
                const SizedBox(height: 12),
                ScannerInput(
                  controller: _controller,
                  focusNode: _focusNode,
                  onChanged: _handleChanged,
                  onSubmitted: _handleSubmitted,
                ),
                const SizedBox(height: 12),
                StatusCard(result: _result),
                const SizedBox(height: 12),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final width = (constraints.maxWidth - 12) / 2;
                    return Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        SizedBox(
                          width: width,
                          child: ActionButton(
                            label: 'ค้นหา',
                            onPressed: _openSearch,
                          ),
                        ),
                        SizedBox(
                          width: width,
                          child: ActionButton(
                            label: 'ประวัติ',
                            onPressed: _openHistory,
                          ),
                        ),
                        SizedBox(
                          width: width,
                          child: ActionButton(
                            label: 'Export Excel',
                            onPressed: _exportExcel,
                          ),
                        ),
                        SizedBox(
                          width: width,
                          child: FilledButton(
                            style: FilledButton.styleFrom(
                              backgroundColor: AppColors.invalid,
                              minimumSize: const Size.fromHeight(56),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            onPressed: _startNewRound,
                            child: const Text('เริ่มรอบใหม่'),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSessionCard() {
    final session = _session;
    if (session == null) {
      return OutlinedButton(
        onPressed: _showSessionDialog,
        child: const Padding(
          padding: EdgeInsets.symmetric(vertical: 14),
          child: Text('กรอกข้อมูลก่อนเริ่มยิง'),
        ),
      );
    }

    return Card(
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'ข้อมูลรอบสแกน',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                TextButton(
                  onPressed: _showSessionDialog,
                  child: const Text('แก้ไข'),
                ),
              ],
            ),
            Text('ผู้สแกน: ${session.scannerName}'),
            Text('รอบส่งออก: ${session.exportRound} | ขนส่ง: ${session.carrier}'),
            Text('คนขับ: ${session.driverName} | ทะเบียน: ${session.vehiclePlate}'),
          ],
        ),
      ),
    );
  }

  void _handleChanged(String value) {
    _debounceTimer?.cancel();
    if (value.trim().isEmpty) {
      return;
    }
    _debounceTimer = Timer(
      const Duration(milliseconds: 280),
      () => _processScan(value),
    );
  }

  void _handleSubmitted(String value) {
    _debounceTimer?.cancel();
    _processScan(value);
  }

  Future<void> _processScan(String rawInput) async {
    final session = _session;
    if (session?.id == null) {
      _clearAndFocus();
      await _showSessionDialog();
      return;
    }

    final cleaned = _scannerService.cleanInput(rawInput);
    if (cleaned.isEmpty) {
      _clearAndFocus();
      return;
    }
    if (_isProcessing) {
      _pendingRawInputs.add(rawInput);
      _clearAndFocus();
      return;
    }

    setState(() => _isProcessing = true);
    _clearAndFocus();
    try {
      final result = await _scannerService.process(cleaned, sessionId: session!.id!);
      await _alertService.play(result.status);
      final count = await _repository.countBySession(session.id!);

      if (!mounted) {
        return;
      }
      setState(() {
        _result = result;
        _count = count;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _result = const ScanResult(
          status: ScanStatus.error,
          message: 'ไม่สามารถบันทึกข้อมูลได้ กรุณาลองใหม่',
        );
      });
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }

    if (_pendingRawInputs.isNotEmpty) {
      final pendingRawInput = _pendingRawInputs.removeAt(0);
      await _processScan(pendingRawInput);
    } else {
      _requestScannerFocus();
    }
  }

  Future<void> _loadInitialState() async {
    try {
      final session = await _repository.getLatestSession();
      final count = session != null ? await _repository.countBySession(session.id!) : 0;
      if (mounted) {
        setState(() {
          _count = count;
          _session = session;
        });
      }
      if (mounted && session == null) {
        await _showSessionDialog();
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _result = const ScanResult(
            status: ScanStatus.error,
            message: 'ไม่สามารถเปิดฐานข้อมูลได้',
          );
        });
      }
    }
  }

  Future<void> _showSessionDialog() async {
    if (_isSessionDialogOpen || !mounted) {
      return;
    }
    _isSessionDialogOpen = true;
    try {
      final currentSession = _session;
      final sessionsToday = currentSession == null ? await _repository.countSessionsToday() : 0;
      final suggestedRound = currentSession == null ? (sessionsToday + 1).toString() : null;

      final nextSession = await showDialog<ScanSession>(
        context: context,
        barrierDismissible: currentSession != null,
        builder: (context) => SessionFormDialog(
          initialSession: currentSession,
          suggestedRound: suggestedRound,
        ),
      );
      if (nextSession == null) {
        _requestScannerFocus();
        return;
      }

      ScanSession savedSession;
      if (nextSession.id == null) {
        final id = await _repository.createSession(nextSession);
        savedSession = nextSession.copyWith(id: id);
      } else {
        await _repository.updateSession(nextSession);
        savedSession = nextSession;
      }

      if (mounted) {
        setState(() {
          _session = savedSession;
          _result = const ScanResult(
            status: ScanStatus.ready,
            message: 'พร้อมสแกน',
          );
        });
      }
    } catch (_) {
      if (mounted) {
        await _showMessage('ไม่สามารถบันทึกข้อมูลรอบสแกนได้');
      }
    } finally {
      _isSessionDialogOpen = false;
      _requestScannerFocus();
    }
  }

  Future<void> _openSearch() async {
    await showDialog<void>(
      context: context,
      builder: (context) => SearchDialog(repository: _repository),
    );
    _requestScannerFocus();
  }

  Future<void> _openHistory() async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => HistoryScreen(
          repository: _repository,
          sessionId: _session?.id,
        ),
      ),
    );
    _requestScannerFocus();
  }

  Future<void> _exportExcel() async {
    try {
      final file = await _exportService.exportExcel(session: _session);
      if (!mounted) {
        return;
      }
      await _showExportSuccess(file);
    } on NoExportSessionException {
      if (mounted) {
        await _showMessage('กรุณากรอกข้อมูลก่อนเริ่มยิง');
        await _showSessionDialog();
      }
    } on NoExportDataException {
      if (mounted) {
        await _showMessage('ไม่มีข้อมูลสำหรับ Export');
      }
    } catch (_) {
      if (mounted) {
        await _showMessage('ไม่สามารถ Export Excel ได้');
      }
    }
    _requestScannerFocus();
  }

  Future<void> _showExportSuccess(File file) {
    final fileName = file.uri.pathSegments.last;
    return showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Export สำเร็จ'),
          content: Text(fileName),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('ปิด'),
            ),
            FilledButton(
              onPressed: () async {
                try {
                  await _exportService.shareFile(file);
                } catch (_) {
                  if (context.mounted) {
                    Navigator.of(context).pop();
                    await _showMessage('ไม่สามารถแชร์ไฟล์ได้');
                  }
                }
              },
              child: const Text('แชร์ไฟล์'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _startNewRound() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => const ConfirmDialog(),
    );
    if (confirmed != true) {
      _requestScannerFocus();
      return;
    }

    try {
      await _repository.clearOldData();
      if (!mounted) {
        return;
      }
      setState(() {
        _session = null;
        _count = 0;
        _result = const ScanResult(
          status: ScanStatus.ready,
          message: 'เริ่มรอบใหม่แล้ว\nกรุณากรอกข้อมูลก่อนเริ่มยิง',
        );
      });
      await _showSessionDialog();
    } catch (_) {
      if (mounted) {
        await _showMessage('ไม่สามารถล้างข้อมูลได้ กรุณาลองใหม่');
      }
    }
    _clearAndFocus();
  }

  Future<void> _showMessage(String message) {
    return showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        content: Text(message),
        actions: [
          FilledButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('ปิด'),
          ),
        ],
      ),
    );
  }

  void _clearAndFocus() {
    _controller.clear();
    _requestScannerFocus();
  }

  void _requestScannerFocus() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _focusNode.requestFocus();
      }
    });
  }
}
