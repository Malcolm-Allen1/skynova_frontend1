import 'package:flutter/material.dart';
import 'package:skynova_frontend1/pages/features/alerts_page.dart';
import 'package:skynova_frontend1/pages/features/home_page.dart';
import 'package:skynova_frontend1/pages/features/profile_page.dart';
import 'package:skynova_frontend1/pages/searches/saved_searches_page.dart';


class MainDashboard extends StatefulWidget {
  const MainDashboard({super.key});

  @override
  State<MainDashboard> createState() => _MainDashboardState();
}

class _MainDashboardState extends State<MainDashboard> {
  int _index = 0;

  final List<Widget> _pages = const [
    HomePage(),
    SavedSearchesPage(),
    AlertsPage(),
    ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_index],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (value) {
          setState(() => _index = value);
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.search), label: 'Searches'),
          NavigationDestination(icon: Icon(Icons.notifications_none), label: 'Alerts'),
          NavigationDestination(icon: Icon(Icons.person_outline), label: 'Profile'),
        ],
      ),
    );
  }
}