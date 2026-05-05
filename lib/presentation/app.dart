import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../logic/auth/auth_cubit.dart';
import '../logic/auth/auth_state.dart';
import '../configs/app/theme/app_colors.dart';
import 'auth/login_page.dart';
import 'shell/shell_page.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Nest',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          primary: AppColors.primary,
          onPrimary: AppColors.onPrimary,
          surface: AppColors.surface,
        ),
        scaffoldBackgroundColor: AppColors.background,
        useMaterial3: true,
      ),
      home: BlocBuilder<AuthCubit, AuthState>(
        buildWhen: (AuthState prev, AuthState next) =>
            prev.user != next.user ||
            prev.sessionStatus != next.sessionStatus,
        builder: (BuildContext context, AuthState state) {
          if (state.isAuthenticated) {
            return const ShellPage();
          }
          return const LoginPage();
        },
      ),
    );
  }
}

