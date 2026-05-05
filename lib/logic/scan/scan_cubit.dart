import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/scan/scan_api.dart';
import 'scan_state.dart';

class ScanCubit extends Cubit<ScanState> {
  ScanCubit({
    required ScanApi scanApi,
  })  : _scanApi = scanApi,
        super(ScanState.initial);

  final ScanApi _scanApi;

  Future<void> submit({
    required String code,
    required String contextLabel,
    required String endpoint,
  }) async {
    final String cleaned = code.trim();
    if (cleaned.isEmpty) {
      emit(
        state.copyWith(
          errorMessage: 'Please provide a code',
          clearError: false,
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        isSubmitting: true,
        lastCode: cleaned,
        clearError: true,
        clearResponse: true,
      ),
    );

    try {
      final String html =
          await _scanApi.submitCode(
            code: cleaned,
            contextLabel: contextLabel,
            endpoint: endpoint,
          );
      emit(state.copyWith(isSubmitting: false, responseHtml: html));
    } catch (e) {
      emit(
        state.copyWith(
          isSubmitting: false,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  void clear() {
    emit(ScanState.initial);
  }
}

