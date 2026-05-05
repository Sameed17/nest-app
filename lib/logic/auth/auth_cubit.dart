import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:signalr_netcore/signalr_client.dart';
import 'package:uuid/uuid.dart';

import '../../configs/app/app_globals.dart';
import '../../data/auth/auth_api.dart';
import '../../data/auth/auth_login_result.dart';
import 'auth_state.dart';
import 'auth_session_status.dart';

class AuthCubit extends HydratedCubit<AuthState> {
  AuthCubit({
    required AuthApi authApi,
  })  : _authApi = authApi,
        super(AuthState.initial);

  final AuthApi _authApi;
  HubConnection? _hubConnection;

  Future<void> login({
    required String username,
    required String password,
  }) async {
    final String deviceId = state.deviceId ?? const Uuid().v4();
    emit(state.copyWith(isLoggingIn: true, clearError: true));
    try {
      final AuthLoginResult result = await _authApi.login(
        username: username,
        password: password,
        deviceId: deviceId,
      );
      if (result.type == LoginResultType.pending) {
        emit(
          state.copyWith(
            isLoggingIn: false,
            sessionStatus: AuthSessionStatus.pendingApproval,
            pendingRequestId: result.requestId,
            deviceId: deviceId,
            clearUser: true,
          ),
        );
        await _connectRefreshHub();
        return;
      }

      emit(
        state.copyWith(
          user: result.user,
          isLoggingIn: false,
          deviceId: deviceId,
          sessionStatus: AuthSessionStatus.authenticated,
          clearPendingRequestId: true,
        ),
      );
      await _disconnectRefreshHub();
    } catch (e) {
      emit(
        state.copyWith(
          isLoggingIn: false,
          sessionStatus: AuthSessionStatus.loggedOut,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> refreshPendingApproval() async {
    final String? requestId = state.pendingRequestId;
    final String? deviceId = state.deviceId;
    if (requestId == null || deviceId == null || state.isLoggingIn) {
      return;
    }
    emit(state.copyWith(isLoggingIn: true, clearError: true));
    try {
      final AuthLoginResult result = await _authApi.refreshLoginStatus(
        requestId: requestId,
        deviceId: deviceId,
      );
      if (result.type == LoginResultType.pending) {
        emit(state.copyWith(isLoggingIn: false));
        return;
      }
      emit(
        state.copyWith(
          user: result.user,
          isLoggingIn: false,
          sessionStatus: AuthSessionStatus.authenticated,
          clearPendingRequestId: true,
        ),
      );
      await _disconnectRefreshHub();
    } catch (e) {
      emit(
        state.copyWith(
          isLoggingIn: false,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  void logout() {
    _disconnectRefreshHub();
    emit(AuthState.initial.copyWith(deviceId: state.deviceId));
  }

  Future<void> _connectRefreshHub() async {
    if (_hubConnection != null) {
      return;
    }
    final String normalizedBaseUrl = AppGlobals.apiBaseUrl.endsWith('/api')
        ? AppGlobals.apiBaseUrl.substring(0, AppGlobals.apiBaseUrl.length - 4)
        : AppGlobals.apiBaseUrl;
    final String hubUrl = '$normalizedBaseUrl/refreshhub';
    final HubConnection hub = HubConnectionBuilder().withUrl(hubUrl).build();
    hub.on('Refresh', (List<Object?>? _) {
      refreshPendingApproval();
    });
    await hub.start();
    _hubConnection = hub;
  }

  Future<void> _disconnectRefreshHub() async {
    final HubConnection? existing = _hubConnection;
    _hubConnection = null;
    if (existing != null) {
      await existing.stop();
    }
  }

  @override
  AuthState? fromJson(Map<String, dynamic> json) {
    try {
      return AuthState.fromJson(json);
    } catch (_) {
      return AuthState.initial;
    }
  }

  @override
  Map<String, dynamic>? toJson(AuthState state) {
    return state.toJson();
  }

  @override
  Future<void> close() async {
    await _disconnectRefreshHub();
    return super.close();
  }
}

