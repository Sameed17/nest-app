import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../configs/utils/core/x_utils.dart';
import '../../logic/scan/scan_cubit.dart';
import '../../logic/scan/scan_state.dart';
import 'widgets/scan_input_card.dart';
import 'widgets/scan_response_view.dart';
import 'widgets/scanner_card.dart';

class ScanPage extends StatelessWidget {
  const ScanPage({
    required this.title,
    required this.endpoint,
    super.key,
  });

  final String title;
  final String endpoint;

  void _showOrReplaceDialog(BuildContext context, ScanState state) {
    final navigator = Navigator.of(context, rootNavigator: true);

    if (navigator.canPop()) {
      navigator.pop();
    }

    showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (_) {
        return Dialog(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: ScanResponseView(
              isLoading: state.isSubmitting,
              errorMessage: state.errorMessage,
              html: state.responseHtml,
              lastCode: state.lastCode,
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final XDimensions d = XUtils.getDimensions(context);

    return BlocProvider<ScanCubit>(
      create: (BuildContext context) => ScanCubit(),
      child: Builder(
        builder: (BuildContext context) {
          return BlocListener<ScanCubit, ScanState>(
            listenWhen: (previous, current) =>
                previous.isSubmitting != current.isSubmitting ||
                previous.responseHtml != current.responseHtml ||
                previous.errorMessage != current.errorMessage,
            listener: (BuildContext context, ScanState state) {
              // Open/update dialog whenever scan state changes
              if (state.isSubmitting ||
                  state.responseHtml != null ||
                  state.errorMessage != null) {
                _showOrReplaceDialog(context, state);
              }
            },
            child: SafeArea(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: d.wp(0.04),
                  vertical: d.hp(0.02),
                ),
                child: Column(
                  children: <Widget>[
                    ScannerCard(
                      onCode: (String code) =>
                          context.read<ScanCubit>().submit(
                                code: code,
                                contextLabel: title,
                                endpoint: endpoint,
                              ),
                    ),
                    SizedBox(height: d.hp(0.02)),
                    ScanInputCard(
                      onSubmit: (String code) =>
                          context.read<ScanCubit>().submit(
                                code: code,
                                contextLabel: title,
                                endpoint: endpoint,
                              ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }
      ),
    );
  }
}