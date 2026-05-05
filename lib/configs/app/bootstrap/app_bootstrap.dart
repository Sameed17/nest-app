import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:path_provider/path_provider.dart';

import '../../../presentation/app.dart';
import '../app_globals.dart';
import '../remote/api/api_configs.dart';
import '../remote/api/user_context_interceptor.dart';
import '../../../data/auth/auth_api.dart';
import '../../../logic/auth/auth_cubit.dart';

class AppBootstrap {
  const AppBootstrap._();

  static Future<Widget> build() async {
    await dotenv.load(fileName: '.env');
    final String baseUrl = (dotenv.env['API_BASE_URL'] ?? '').trim();
    if (baseUrl.isEmpty) {
      throw StateError('Missing API_BASE_URL in .env');
    }

    HydratedBloc.storage = await HydratedStorage.build(
      storageDirectory: HydratedStorageDirectory(
        (await getApplicationDocumentsDirectory()).path,
      ),
    );

    final Dio dio = ApiManager.instance.apiConfigs.dioAdapter;
    ApiManager.instance.apiConfigs.setBaseUrl(baseUrl);

    final AuthApi authApi = AuthApi(dio: dio);
    final AuthCubit authCubit = AuthCubit(authApi: authApi);
    dio.interceptors.add(UserContextInterceptor(authCubit: authCubit));

    AppGlobals.apiBaseUrl = baseUrl;
    AppGlobals.dio = dio;
    AppGlobals.authCubit = authCubit;

    return MultiRepositoryProvider(
      providers: <RepositoryProvider<dynamic>>[
        RepositoryProvider<Dio>.value(value: dio),
        RepositoryProvider<AuthApi>.value(value: authApi),
      ],
      child: MultiBlocProvider(
        providers: <BlocProvider<dynamic>>[
          BlocProvider<AuthCubit>.value(value: authCubit),
        ],
        child: const App(),
      ),
    );
  }
}

