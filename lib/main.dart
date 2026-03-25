import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skynova_frontend1/auth/login_page.dart';
import 'core/theme/app_theme.dart';
import 'providers/alert_provider.dart';
import 'providers/app_settings_provider.dart';
import 'providers/auth_provider.dart';
import 'providers/search_provider.dart'; 


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final appSettings = AppSettingsProvider();
  await appSettings.loadSettings();

  final authProvider = AuthProvider();
  await authProvider.loadSession();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<AppSettingsProvider>.value(value: appSettings),
        ChangeNotifierProvider<AuthProvider>.value(value: authProvider),
        ChangeNotifierProvider(create: (_) => AlertProvider()),
        ChangeNotifierProvider(create: (_) => SearchProvider()), // ADD THIS
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<AppSettingsProvider>();
    final seed = AppTheme.seedFromKey(settings.themeKey);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Skynova',
      theme: AppTheme.light(seed),
      darkTheme: AppTheme.dark(seed),
      themeMode: settings.themeMode,
      home: const LoginPage(), // OR your real dashboard widget
    );
  }
}