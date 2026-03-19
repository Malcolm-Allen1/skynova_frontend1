import 'package:flutter/material.dart';
import 'package:skynova_frontend1/pages/searches/saved_searches_page.dart';

class MainDashboard extends StatefulWidget {
  const MainDashboard({super.key});

  @override
  State<MainDashboard> createState() => _MainDashboardState();
}

class _MainDashboardState extends State<MainDashboard> {
  int _index = 0;

  final List<Widget> _pages = const [
    _HomePage(),
    SavedSearchesPage(),
    _AlertsPage(),
    _ProfilePage(),
  ];

  final List<String> _titles = const [
    'SkyNova',
    'Saved Searches',
    'Deal Alerts',
    'Profile',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_index]),
        centerTitle: true,
      ),
      body: _pages[_index],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (value) {
          setState(() => _index = value);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.search_outlined),
            selectedIcon: Icon(Icons.search),
            label: 'Searches',
          ),
          NavigationDestination(
            icon: Icon(Icons.notifications_none),
            selectedIcon: Icon(Icons.notifications),
            label: 'Alerts',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

class _HomePage extends StatelessWidget {
  const _HomePage();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: ListView(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: const LinearGradient(
                colors: [
                  Color(0xFF1565C0),
                  Color(0xFF42A5F5),
                ],
              ),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Track flight deals smarter',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Create saved searches, monitor price drops, and stay ready for the best travel deals.',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: const [
              Expanded(
                child: _QuickStatCard(
                  icon: Icons.search,
                  title: 'Searches',
                  value: 'Track routes',
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _QuickStatCard(
                  icon: Icons.local_offer,
                  title: 'Deals',
                  value: 'Spot drops',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: const [
              Expanded(
                child: _QuickStatCard(
                  icon: Icons.show_chart,
                  title: 'History',
                  value: 'View trends',
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _QuickStatCard(
                  icon: Icons.notifications_active,
                  title: 'Alerts',
                  value: 'Stay updated',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _QuickStatCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _QuickStatCard({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            Icon(icon, size: 30),
            const SizedBox(height: 10),
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _AlertsPage extends StatelessWidget {
  const _AlertsPage();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Alerts screen coming next'),
    );
  }
}

class _ProfilePage extends StatelessWidget {
  const _ProfilePage();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Profile screen coming next'),
    );
  }
}