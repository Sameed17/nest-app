import 'package:flutter/material.dart';

import '../../../configs/app/app_globals.dart';
import '../../../configs/app/theme/app_colors.dart';
import '../../../configs/utils/core/x_utils.dart';

class ScanInputCard extends StatefulWidget {
  const ScanInputCard({
    required this.onSubmit,
    super.key,
  });

  final ValueChanged<String> onSubmit;

  @override
  State<ScanInputCard> createState() => _ScanInputCardState();
}

class _ScanInputCardState extends State<ScanInputCard> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final XDimensions d = XUtils.getDimensions(context);
    return Container(
      padding: EdgeInsets.all(d.wp(0.04)),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Text(
            'Manual input (fallback)',
            style: TextStyle(
              fontSize: AppGlobals.dts.body,
              fontWeight: FontWeight.w700,
              color: AppColors.text,
            ),
          ),
          SizedBox(height: d.hp(0.014)),
          TextField(
            controller: _controller,
            decoration: const InputDecoration(
              labelText: 'Enter code',
              border: OutlineInputBorder(),
            ),
            onSubmitted: (String value) => widget.onSubmit(value),
          ),
          SizedBox(height: d.hp(0.014)),
          FilledButton(
            onPressed: () => widget.onSubmit(_controller.text),
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }
}

