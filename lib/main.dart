import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'configs/app/bootstrap/app_bootstrap.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations(<DeviceOrientation>[
    DeviceOrientation.portraitUp,
  ]);
  final Widget app = await AppBootstrap.build();
  runApp(app);
}
