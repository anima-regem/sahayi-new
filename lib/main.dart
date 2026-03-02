import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'config/app_config.dart';
import 'core/storage_keys.dart';
import 'providers/app_providers.dart';
import 'screens/main_screen.dart';
import 'screens/missing_config_screen.dart';
import 'screens/splashscreen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await Hive.openBox<String>(StorageKeys.catalogBox);
  await Hive.openBox<String>(StorageKeys.downloadsBox);

  final config = AppConfig.fromEnvironment();

  runApp(
    ProviderScope(
      overrides: [
        appConfigProvider.overrideWithValue(config),
      ],
      child: SahayiApp(config: config),
    ),
  );
}

class SahayiApp extends StatelessWidget {
  const SahayiApp({
    super.key,
    required this.config,
  });

  final AppConfig config;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Sahayi',
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Poppins',
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFB4233A),
        ),
      ),
      home: config.isValid
          ? const Scaffold(
              body: SplashScreen(
                destination: HomeScreen(),
              ),
            )
          : MissingConfigScreen(
              missingFields: config.missingFields,
            ),
    );
  }
}
