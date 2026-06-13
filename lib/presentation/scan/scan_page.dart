import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../configs/utils/core/x_utils.dart';
import '../../data/scan/scan_api.dart';
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

  @override
  Widget build(BuildContext context) {
    final XDimensions d = XUtils.getDimensions(context);

    return RepositoryProvider<ScanApi>(
      create: (BuildContext context) => ScanApi(dio: context.read<Dio>()),
      child: BlocProvider<ScanCubit>(
        create: (BuildContext context) =>
            ScanCubit(scanApi: context.read<ScanApi>()),
        child: Builder(
          builder: (BuildContext context) {
            return SafeArea(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: d.wp(0.04),
                  vertical: d.hp(0.02),
                ),
                child: Column(
                  children: <Widget>[
                    ScannerCard(
                      onCode: (String code) => context.read<ScanCubit>().submit(
                            code: code,
                            contextLabel: title,
                            endpoint: endpoint,
                          ),
                    ),
                    SizedBox(height: d.hp(0.02)),
                    ScanInputCard(
                      onSubmit: (String code) => context.read<ScanCubit>().submit(
                            code: code,
                            contextLabel: title,
                            endpoint: endpoint,
                          ),
                    ),
                    SizedBox(height: d.hp(0.02)),
                    BlocBuilder<ScanCubit, ScanState>(
                      builder: (BuildContext context, ScanState state) {
                        return ScanResponseView(
                          isLoading: state.isSubmitting,
                          errorMessage: state.errorMessage,
                          html: state.responseHtml,
                          lastCode: state.lastCode,
                        );
                      },
                    ),
                  ],
                ),
              ),
            );
          }
        ),
      ),
    );
  }
}

