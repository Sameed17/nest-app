import '../../logic/auth/auth_user.dart';

enum LoginResultType { approved, pending }

class AuthLoginResult {
  const AuthLoginResult._({
    required this.type,
    this.user,
    this.requestId,
  });

  factory AuthLoginResult.approved(AuthUser user) {
    return AuthLoginResult._(type: LoginResultType.approved, user: user);
  }

  factory AuthLoginResult.pending(String requestId) {
    return AuthLoginResult._(type: LoginResultType.pending, requestId: requestId);
  }

  final LoginResultType type;
  final AuthUser? user;
  final String? requestId;
}

