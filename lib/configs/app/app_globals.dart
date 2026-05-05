import 'package:dio/dio.dart';

import '../../logic/auth/auth_cubit.dart';

class AppTextSizes {
  const AppTextSizes();

  final double h1 = 24;
  final double h2 = 20;
  final double body = 16;
  final double small = 14;
}

class AppGlobals {
  const AppGlobals._();

  static const AppTextSizes dts = AppTextSizes();

  static late final String apiBaseUrl;
  static late final Dio dio;

  static late final AuthCubit authCubit;
}
