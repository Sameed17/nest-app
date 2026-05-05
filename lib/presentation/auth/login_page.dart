import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../configs/app/app_globals.dart';
import '../../configs/app/theme/app_colors.dart';
import '../../configs/utils/core/x_utils.dart';
import '../../logic/auth/auth_cubit.dart';
import '../../logic/auth/auth_session_status.dart';
import '../../logic/auth/auth_state.dart';
import 'widgets/text_field_card.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final XDimensions d = XUtils.getDimensions(context);

    return BlocListener<AuthCubit, AuthState>(
      listenWhen: (AuthState prev, AuthState next) =>
          prev.errorMessage != next.errorMessage &&
          next.errorMessage != null &&
          next.errorMessage!.isNotEmpty,
      listener: (BuildContext context, AuthState state) {
        final String? message = state.errorMessage;
        if (message == null || message.isEmpty) {
          return;
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: d.wp(0.92)),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: d.wp(0.06)),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    BlocBuilder<AuthCubit, AuthState>(
                      builder: (BuildContext context, AuthState state) {
                        if (state.sessionStatus ==
                            AuthSessionStatus.pendingApproval) {
                          return Column(
                            children: <Widget>[
                              Text(
                                'Waiting for approval',
                                style: TextStyle(
                                  fontSize: AppGlobals.dts.h1,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.text,
                                ),
                              ),
                              SizedBox(height: d.hp(0.01)),
                              Text(
                                'Your device is pending admin approval.',
                                style: TextStyle(
                                  fontSize: AppGlobals.dts.body,
                                  color: AppColors.mutedText,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              SizedBox(height: d.hp(0.02)),
                              SizedBox(
                                width: double.infinity,
                                child: FilledButton(
                                  onPressed: state.isLoggingIn
                                      ? null
                                      : () => context
                                          .read<AuthCubit>()
                                          .refreshPendingApproval(),
                                  child: state.isLoggingIn
                                      ? const SizedBox(
                                          height: 18,
                                          width: 18,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                          ),
                                        )
                                      : const Text('Refresh now'),
                                ),
                              ),
                            ],
                          );
                        }
                        return Column(
                          children: <Widget>[
                            Text(
                              'Login',
                              style: TextStyle(
                                fontSize: AppGlobals.dts.h1,
                                fontWeight: FontWeight.w700,
                                color: AppColors.text,
                              ),
                            ),
                            SizedBox(height: d.hp(0.02)),
                            TextFieldCard(
                              controller: _usernameController,
                              label: 'Username',
                              obscure: false,
                            ),
                            SizedBox(height: d.hp(0.014)),
                            TextFieldCard(
                              controller: _passwordController,
                              label: 'Password',
                              obscure: true,
                            ),
                            SizedBox(height: d.hp(0.02)),
                            SizedBox(
                              width: double.infinity,
                              child: FilledButton(
                                onPressed: state.isLoggingIn
                                    ? null
                                    : () => context.read<AuthCubit>().login(
                                          username:
                                              _usernameController.text.trim(),
                                          password:
                                              _passwordController.text.trim(),
                                        ),
                                child: state.isLoggingIn
                                    ? const SizedBox(
                                        height: 18,
                                        width: 18,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : const Text('Continue'),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                    SizedBox(height: d.hp(0.02)),
                    Text(
                      'Backend: ${AppGlobals.apiBaseUrl}',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: AppGlobals.dts.small,
                        color: AppColors.mutedText,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
