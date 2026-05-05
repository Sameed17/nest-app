import 'package:dio/dio.dart';

import '../../configs/app/remote/api/api_endpoints.dart';
import 'auth_login_result.dart';
import '../../logic/auth/auth_user.dart';
import '../../logic/auth/user_role.dart';

class AuthApi {
  const AuthApi({
    required Dio dio,
  }) : _dio = dio;

  final Dio _dio;

  Future<AuthLoginResult> login({
    required String username,
    required String password,
    required String deviceId,
  }) async {
    final Response<dynamic> res = await _dio.post<dynamic>(
      XEndpoint.loginEndpoint,
      data: <String, dynamic>{
        'username': username,
        'password': password,
        'deviceId': deviceId,
      },
    );

    final dynamic data = res.data;
    if (data is! Map<String, dynamic>) {
      throw const FormatException('Unexpected login response shape');
    }

    final String? status = data['status'] as String?;
    if (status == 'pending') {
      final String? requestId = data['requestId'] as String?;
      if (requestId == null || requestId.isEmpty) {
        throw const FormatException('Missing pending request id');
      }
      return AuthLoginResult.pending(requestId);
    }

    final String? id = data['id'] as String?;
    final String? name = data['name'] as String?;
    final String? roleRaw = data['role'] as String?;
    final String? token = data['token'] as String?;
    final UserRole? role = UserRole.tryParse(roleRaw);
    if (id == null || name == null || role == null) {
      throw const FormatException('Missing required login fields');
    }

    return AuthLoginResult.approved(
      AuthUser(id: id, name: name, role: role, token: token),
    );
  }

  Future<AuthLoginResult> refreshLoginStatus({
    required String requestId,
    required String deviceId,
  }) async {
    final Response<dynamic> res = await _dio.get<dynamic>(
      '${XEndpoint.loginStatusEndpoint}/$requestId',
      queryParameters: <String, dynamic>{'deviceId': deviceId},
    );

    final dynamic data = res.data;
    if (data is! Map<String, dynamic>) {
      throw const FormatException('Unexpected login-status response shape');
    }

    final String? status = data['status'] as String?;
    if (status == 'pending') {
      return AuthLoginResult.pending(requestId);
    }

    final String? id = data['id'] as String?;
    final String? name = data['name'] as String?;
    final String? roleRaw = data['role'] as String?;
    final String? token = data['token'] as String?;
    final UserRole? role = UserRole.tryParse(roleRaw);
    if (id == null || name == null || role == null) {
      throw const FormatException('Missing required login-status fields');
    }

    return AuthLoginResult.approved(
      AuthUser(id: id, name: name, role: role, token: token),
    );
  }
}

