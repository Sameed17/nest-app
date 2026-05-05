import 'package:equatable/equatable.dart';

class ScanState extends Equatable {
  const ScanState({
    required this.isSubmitting,
    required this.lastCode,
    required this.responseHtml,
    required this.errorMessage,
  });

  final bool isSubmitting;
  final String? lastCode;
  final String? responseHtml;
  final String? errorMessage;

  ScanState copyWith({
    bool? isSubmitting,
    String? lastCode,
    String? responseHtml,
    String? errorMessage,
    bool clearError = false,
    bool clearResponse = false,
  }) {
    return ScanState(
      isSubmitting: isSubmitting ?? this.isSubmitting,
      lastCode: lastCode ?? this.lastCode,
      responseHtml: clearResponse ? null : (responseHtml ?? this.responseHtml),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  static const ScanState initial = ScanState(
    isSubmitting: false,
    lastCode: null,
    responseHtml: null,
    errorMessage: null,
  );

  @override
  List<Object?> get props => <Object?>[
        isSubmitting,
        lastCode,
        responseHtml,
        errorMessage,
      ];
}

