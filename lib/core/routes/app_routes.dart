import 'package:flutter/material.dart';

import '../../models/search_model.dart';
import '../../pages/auth/login_page.dart';
import '../../pages/auth/register_page.dart';
import '../../pages/dashboard/main_dashboard.dart';
import '../../pages/features/search_detail_page.dart';

class AppRoutes {
  static const String login = '/login';
  static const String register = '/register';
  static const String dashboard = '/dashboard';
  static const String searchDetail = '/search-detail';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case login:
        return MaterialPageRoute(
          builder: (_) => const LoginPage(),
        );

      case register:
        return MaterialPageRoute(
          builder: (_) => const RegisterPage(),
        );

      case dashboard:
        return MaterialPageRoute(
          builder: (_) => const MainDashboard(),
        );

      case searchDetail:
        final search = settings.arguments as SearchModel;
        return MaterialPageRoute(
          builder: (_) => SearchDetailPage(search: search),
        );

      default:
        return MaterialPageRoute(
          builder: (_) => const LoginPage(),
        );
    }
  }
}