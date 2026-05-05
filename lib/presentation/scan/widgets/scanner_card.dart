import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../../configs/app/theme/app_colors.dart';

class ScannerCard extends StatefulWidget {
  const ScannerCard({
    required this.onCode,
    super.key,
  });

  final ValueChanged<String> onCode;

  @override
  State<ScannerCard> createState() => _ScannerCardState();
}

class _ScannerCardState extends State<ScannerCard> {
  final MobileScannerController _controller = MobileScannerController();
  bool _isSubmitting = false;

  Future<void> _handleCode(String value) async {
    if (_isSubmitting) {
      return;
    }
    final String cleaned = value.trim();
    if (cleaned.isEmpty) {
      return;
    }
    setState(() => _isSubmitting = true);
    widget.onCode(cleaned);
    await Future<void>.delayed(const Duration(seconds: 2));
    if (!mounted) {
      return;
    }
    setState(() => _isSubmitting = false);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: AspectRatio(
          aspectRatio: 1,
          child: MobileScanner(
            controller: _controller,
            onDetect: (BarcodeCapture capture) {
              final List<Barcode> barcodes = capture.barcodes;
              final Barcode? first =
                  barcodes.isNotEmpty ? barcodes.first : null;
              final String? value = first?.rawValue;
              if (value == null) {
                return;
              }
              _handleCode(value);
            },
          ),
        ),
      ),
    );
  }
}

