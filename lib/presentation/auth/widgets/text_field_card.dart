import 'package:flutter/material.dart';

import '../../../configs/app/theme/app_colors.dart';
import '../../../configs/utils/core/x_utils.dart';

class TextFieldCard extends StatelessWidget {
  const TextFieldCard({
    required this.controller,
    required this.label,
    required this.obscure,
    super.key,
  });

  final TextEditingController controller;
  final String label;
  final bool obscure;

  @override
  Widget build(BuildContext context) {
    final XDimensions d = XUtils.getDimensions(context);
    final double radius = d.wp(0.03).clamp(10.0, 18.0);
    return TextField(
      controller: controller,
      obscureText: obscure,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: AppColors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radius),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radius),
          borderSide: const BorderSide(color: AppColors.border),
        ),
      ),
    );
  }
}

