import 'package:flutter/widgets.dart';

class XDimensions {
  const XDimensions({
    required this.size,
  });

  final Size size;

  double get w => size.width;
  double get h => size.height;

  double wp(double factor) => w * factor;
  double hp(double factor) => h * factor;
}

class XUtils {
  const XUtils._();

  static XDimensions getDimensions(BuildContext context) {
    return XDimensions(size: MediaQuery.sizeOf(context));
  }
}
