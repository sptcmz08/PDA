import 'package:flutter/material.dart';

import '../models/scan_session.dart';

class SessionFormDialog extends StatefulWidget {
  const SessionFormDialog({
    this.initialSession,
    super.key,
  });

  final ScanSession? initialSession;

  @override
  State<SessionFormDialog> createState() => _SessionFormDialogState();
}

class _SessionFormDialogState extends State<SessionFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _scannerNameController;
  late final TextEditingController _exportRoundController;
  late final TextEditingController _carrierController;
  late final TextEditingController _driverNameController;
  late final TextEditingController _vehiclePlateController;

  @override
  void initState() {
    super.initState();
    final session = widget.initialSession;
    _scannerNameController = TextEditingController(text: session?.scannerName ?? '');
    _exportRoundController = TextEditingController(text: session?.exportRound ?? '');
    _carrierController = TextEditingController(text: session?.carrier ?? '');
    _driverNameController = TextEditingController(text: session?.driverName ?? '');
    _vehiclePlateController = TextEditingController(text: session?.vehiclePlate ?? '');
  }

  @override
  void dispose() {
    _scannerNameController.dispose();
    _exportRoundController.dispose();
    _carrierController.dispose();
    _driverNameController.dispose();
    _vehiclePlateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('ข้อมูลก่อนเริ่มยิง'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildField(_scannerNameController, 'ชื่อผู้สแกน'),
              _buildField(_exportRoundController, 'รอบส่งออก'),
              _buildField(_carrierController, 'ขนส่ง'),
              _buildField(_driverNameController, 'ชื่อคนขับรถ'),
              _buildField(_vehiclePlateController, 'เลขทะเบียนรถที่เข้ารับ'),
            ],
          ),
        ),
      ),
      actions: [
        if (widget.initialSession != null)
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('ยกเลิก'),
          ),
        FilledButton(
          onPressed: _submit,
          child: const Text('บันทึก'),
        ),
      ],
    );
  }

  Widget _buildField(TextEditingController controller, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        textInputAction: TextInputAction.next,
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return 'กรุณากรอก$label';
          }
          return null;
        },
      ),
    );
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    final initial = widget.initialSession;
    Navigator.of(context).pop(
      ScanSession(
        id: initial?.id,
        scannerName: _scannerNameController.text.trim(),
        exportRound: _exportRoundController.text.trim(),
        carrier: _carrierController.text.trim(),
        driverName: _driverNameController.text.trim(),
        vehiclePlate: _vehiclePlateController.text.trim(),
        createdAt: initial?.createdAt ?? DateTime.now(),
      ),
    );
  }
}
