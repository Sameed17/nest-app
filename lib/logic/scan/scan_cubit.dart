import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:audioplayers/audioplayers.dart';

import '../../data/scan/scan_api.dart';
import 'scan_state.dart';

class ScanCubit extends Cubit<ScanState> {
  ScanCubit() : super(ScanState.initial);

  String? processRollNumber(String raw) {
    final cleaned = raw.trim().toUpperCase().replaceAll(RegExp(r'[\s-]'), '');

    final match =
        RegExp(r'([A-Z]?)(\d{2})([A-Z]?)(\d+)').firstMatch(cleaned);

    if (match == null) return null;

    final l1 = match.group(1) ?? '';
    final batch = match.group(2) ?? '';
    final l2 = match.group(3) ?? '';
    final id = match.group(4) ?? '';

    final campus = l1.isNotEmpty ? l1 : l2;

    return campus.isNotEmpty ? '$batch$campus-$id' : null;
  }

  Future<void> submit({
    required String code,
    required String contextLabel,
    required String endpoint,
  }) async {
    final AudioPlayer audioPlayer = AudioPlayer();
    await audioPlayer.play(AssetSource('audio/beep.mp3'));
    final String? cleaned = processRollNumber(code);
    if (cleaned == null) {
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
          await ScanApi.submitCode(
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

