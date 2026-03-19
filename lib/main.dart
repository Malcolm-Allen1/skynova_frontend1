import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skynova_frontend1/core/theme/app_theme.dart';
import 'core/routes/app_routes.dart';
import 'pages/auth/login_page.dart';
import 'pages/dashboard/main_dashboard.dart';
import 'providers/alert_provider.dart';
import 'providers/auth_provider.dart';
import 'providers/search_provider.dart';

void main() {
  runApp(const SkyNovaApp());
}

class SkyNovaApp extends StatelessWidget {
  const SkyNovaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()..loadSession()),
        ChangeNotifierProvider(create: (_) => SearchProvider()),
        ChangeNotifierProvider(create: (_) => AlertProvider()),
      ],
      child: Consumer<AuthProvider>(
        builder: (context, authProvider, _) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'SkyNova',
            theme: AppTheme.lightTheme,
            onGenerateRoute: AppRoutes.onGenerateRoute,
            home: authProvider.isCheckingSession
                ? const Scaffold(
                    body: Center(
                      child: CircularProgressIndicator(),
                    ),
                  )
                : authProvider.isLoggedIn
                    ? const MainDashboard()
                    : const LoginPage(),
          );
        },
      ),
    );
  }
}