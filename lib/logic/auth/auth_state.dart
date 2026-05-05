import 'package:equatable/equatable.dart';

import 'auth_user.dart';
import 'auth_session_status.dart';

class AuthState extends Equatable {
  const AuthState({
    required this.user,
    required this.deviceId,
    required this.pendingRequestId,
    required this.sessionStatus,
    required this.isLoggingIn,
    required this.errorMessage,
  });

  final AuthUser? user;
  final String? deviceId;
  final String? pendingRequestId;
  final AuthSessionStatus sessionStatus;
  final bool isLoggingIn;
  final String? errorMessage;

  bool get isAuthenticated =>
      sessionStatus == AuthSessionStatus.authenticated && user != null;

  AuthState copyWith({
    AuthUser? user,
    String? deviceId,
    String? pendingRequestId,
    AuthSessionStatus? sessionStatus,
    bool? isLoggingIn,
    String? errorMessage,
    bool clearUser = false,
    bool clearPendingRequestId = false,
    bool clearError = false,
  }) {
    return AuthState(
      user: clearUser ? null : (user ?? this.user),
      deviceId: deviceId ?? this.deviceId,
      pendingRequestId: clearPendingRequestId
          ? null
          : (pendingRequestId ?? this.pendingRequestId),
      sessionStatus: sessionStatus ?? this.sessionStatus,
      isLoggingIn: isLoggingIn ?? this.isLoggingIn,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  static const AuthState initial = AuthState(
    user: null,
    deviceId: null,
    pendingRequestId: null,
    sessionStatus: AuthSessionStatus.loggedOut,
    isLoggingIn: false,
    errorMessage: null,
  );

  @override
  List<Object?> get props => <Object?>[
        user,
        deviceId,
        pendingRequestId,
        sessionStatus,
        isLoggingIn,
        errorMessage,
      ];

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'user': user?.toJson(),
      'deviceId': deviceId,
      'pendingRequestId': pendingRequestId,
      'sessionStatus': sessionStatus.name,
    };
  }

  static AuthState fromJson(Map<String, dynamic> json) {
    final dynamic rawUser = json['user'];
    final AuthUser? user =
        rawUser is Map<String, dynamic> ? AuthUser.fromJson(rawUser) : null;
    final String? rawStatus = json['sessionStatus'] as String?;
    final AuthSessionStatus sessionStatus = AuthSessionStatus.values.firstWhere(
      (AuthSessionStatus value) => value.name == rawStatus,
      orElse: () =>
          user == null ? AuthSessionStatus.loggedOut : AuthSessionStatus.authenticated,
    );
    return AuthState.initial.copyWith(
      user: user,
      deviceId: json['deviceId'] as String?,
      pendingRequestId: json['pendingRequestId'] as String?,
      sessionStatus: sessionStatus,
    );
  }
}

