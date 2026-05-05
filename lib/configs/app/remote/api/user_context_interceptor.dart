import 'package:dio/dio.dart';

import '../../../../logic/auth/auth_user.dart';
import '../../../../logic/auth/auth_cubit.dart';

class UserContextInterceptor extends Interceptor {
  UserContextInterceptor({
    required AuthCubit authCubit,
  }) : _authCubit = authCubit;

  final AuthCubit _authCubit;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final String? deviceId = _authCubit.state.deviceId;
    if (deviceId != null && deviceId.isNotEmpty) {
      options.headers['x-device-id'] = deviceId;
    }
    final AuthUser? user = _authCubit.state.user;
    if (user != null) {
      options.headers['x-user-id'] = user.id;
      options.headers['x-user-role'] = user.role.name;
      if (user.token != null && user.token!.isNotEmpty) {
        options.headers['authorization'] = 'Bearer ${user.token}';
      }

      final dynamic data = options.data;
      if (data is Map<String, dynamic>) {
        options.data = <String, dynamic>{
          ...data,
          'userId': user.id,
          'userRole': user.role.name,
        };
      }
    }
    handler.next(options);
  }
}

