import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:nest/data/scan/scan_api.dart';

import '../../../configs/app/app_globals.dart';
import '../../../configs/app/theme/app_colors.dart';
import '../../../configs/utils/core/x_utils.dart';

class ScanResponseView extends StatelessWidget {
  const ScanResponseView({
    required this.isLoading,
    required this.errorMessage,
    required this.html,
    required this.lastCode,
    super.key,
  });

  final bool isLoading;
  final String? errorMessage;
  final String? html;
  final String? lastCode;

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
          Row(
            children: <Widget>[
              Text(
                'Response',
                style: TextStyle(
                  fontSize: AppGlobals.dts.body,
                  fontWeight: FontWeight.w700,
                  color: AppColors.text,
                ),
              ),
              const Spacer(),
              if (isLoading)
                const SizedBox(
                  height: 18,
                  width: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
            ],
          ),
          if (lastCode != null) ...<Widget>[
            SizedBox(height: d.hp(0.01)),
            Text(
              'Code: $lastCode',
              style: TextStyle(
                fontSize: AppGlobals.dts.small,
                color: AppColors.mutedText,
              ),
            ),
          ],
          if (errorMessage != null && errorMessage!.isNotEmpty) ...<Widget>[
            SizedBox(height: d.hp(0.014)),
            Text(
              errorMessage!,
              style: TextStyle(
                fontSize: AppGlobals.dts.body,
                color: AppColors.danger,
              ),
            ),
          ],
          if (html != null && html!.isNotEmpty) ...<Widget>[
            SizedBox(height: d.hp(0.014)),
            FutureBuilder<Uint8List>(
              future: ScanApi.getStudentPhoto(lastCode!),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const CircleAvatar(
                    radius: 50,
                    child: CircularProgressIndicator(),
                  );
                }

                return SizedBox(
                  width: d.wp(0.2),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.memory(
                      snapshot.data!,
                      fit: BoxFit.contain,
                    ),
                  ),
                );
              },
            ),
            SizedBox(height: d.hp(0.014)),
            HtmlWidget(html!),
            SizedBox(height: d.hp(0.02)),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
          if ((html == null || html!.isEmpty) &&
              (errorMessage == null || errorMessage!.isEmpty) &&
              !isLoading) ...<Widget>[
            SizedBox(height: d.hp(0.014)),
            Text(
              'No response yet.',
              style: TextStyle(
                fontSize: AppGlobals.dts.small,
                color: AppColors.mutedText,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

