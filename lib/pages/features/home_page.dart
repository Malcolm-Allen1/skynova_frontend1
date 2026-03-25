import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/alert_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/search_provider.dart';
import '../searches/search_details_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _hasLoaded = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(_loadData);
  }

  Future<void> _loadData() async {
    if (_hasLoaded) return;

    final authProvider = context.read<AuthProvider>();
    final token = authProvider.token;

    if (token == null || token.isEmpty) return;

    _hasLoaded = true;

    await context.read<SearchProvider>().fetchSearches(token);
    await context.read<AlertProvider>().fetchAlerts(token);

    // ✅ also load user profile (NAME)
    await authProvider.loadUserProfile();
  }

  @override
  Widget build(BuildContext context) {
    final searchProvider = context.watch<SearchProvider>();
    final alertProvider = context.watch<AlertProvider>();
    final authProvider = context.watch<AuthProvider>();

    final searches = searchProvider.searches;
    final alerts = alertProvider.alerts;

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            final token = authProvider.token;
            if (token == null || token.isEmpty) return;

            await context.read<SearchProvider>().fetchSearches(token);
            await context.read<AlertProvider>().fetchAlerts(token);
            await authProvider.loadUserProfile();
          },
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 6, 16, 24),
            children: [
              _buildHeader(context),
              const SizedBox(height: 16),
              _buildHeroCard(searches.length, alerts.length),
              const SizedBox(height: 18),
              _buildQuickStats(searches.length, alerts.length),
              const SizedBox(height: 20),
              _buildSectionTitle('Recent Searches'),
              const SizedBox(height: 10),

              if (searches.isEmpty)
                _buildEmptyCard(
                  icon: Icons.travel_explore,
                  title: 'No searches yet',
                  subtitle: 'Create your first trip search to start tracking deals.',
                )
              else
                ...searches.take(4).map(
                  (search) => _buildSearchCard(
                    context: context,
                    title: '${search.origin} → ${search.destination}',
                    subtitle:
                        '${_cleanDate(search.departDate)}${search.returnDate != null && search.returnDate!.isNotEmpty ? ' • ${_cleanDate(search.returnDate)}' : ''}',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => SearchDetailPage(search: search),
                        ),
                      );
                    },
                  ),
                ),

              const SizedBox(height: 20),
              _buildSectionTitle('Travel Insights'),
              const SizedBox(height: 10),
              _buildInsightCard(alertProvider),
            ],
          ),
        ),
      ),
    );
  }

  // ✅ UPDATED HEADER WITH USER NAME
  Widget _buildHeader(BuildContext context) {
  final user = context.watch<AuthProvider>().user;
  final displayName =
      user?['name']?.toString() ??
      user?['full_name']?.toString() ??
      '';

  return Row(
    children: [
      Expanded(
        child: Text(
          displayName.isNotEmpty
              ? 'Welcome, $displayName 👋'
              : 'Welcome 👋',
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    ],
  );
}
  Widget _buildHeroCard(int searchCount, int alertCount) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1565C0), Color(0xFF1E88E5)],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Skynova Travel Tracker ✈️',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Track routes and monitor price drops.',
            style: TextStyle(color: Colors.white70),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _miniPill('$searchCount searches'),
              const SizedBox(width: 8),
              _miniPill('$alertCount alerts'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _miniPill(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: const TextStyle(color: Colors.white),
      ),
    );
  }

  Widget _buildQuickStats(int searchCount, int alertCount) {
    return Row(
      children: [
        Expanded(
          child: _statCard(Icons.search, '$searchCount', 'Searches'),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _statCard(Icons.notifications, '$alertCount', 'Alerts'),
        ),
      ],
    );
  }

  Widget _statCard(IconData icon, String value, String label) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          Icon(icon),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Text(label),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
    );
  }

  Widget _buildSearchCard({
    required BuildContext context,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        tileColor: Colors.grey.shade100,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        leading: const Icon(Icons.flight),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }

  Widget _buildEmptyCard({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Column(
      children: [
        Icon(icon, size: 50),
        const SizedBox(height: 10),
        Text(title),
        Text(subtitle),
      ],
    );
  }

  Widget _buildInsightCard(AlertProvider alertProvider) {
    final latest = alertProvider.latestPrice();
    final previous = alertProvider.previousPrice();

    final dropped =
        latest != null && previous != null && latest < previous;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: dropped ? Colors.green.shade50 : Colors.orange.shade50,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Text(
        dropped
            ? 'Price dropped to \$${latest!.toStringAsFixed(2)} 🔥'
            : 'No price drop yet',
      ),
    );
  }

  String _cleanDate(String? value) {
    if (value == null || value.isEmpty) return '';
    if (value.contains('T')) return value.split('T').first;
    return value;
  }
}