import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../providers/search_provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool hasLoaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!hasLoaded) {
      hasLoaded = true;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;

        final token = context.read<AuthProvider>().token;
        if (token != null && token.isNotEmpty) {
          context.read<SearchProvider>().fetchSearches(token);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SearchProvider>();

    final totalSearches = provider.searches.length;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: provider.isLoading && provider.searches.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              children: [
                /// 🔵 Hero Card
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(22),
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
                        'Track travel deals smarter ✈️',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Monitor price drops and never miss a great deal.',
                        style: TextStyle(color: Colors.white70),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                /// 📊 Stats Row
                Row(
                  children: [
                    Expanded(
                      child: _StatCard(
                        icon: Icons.search,
                        title: 'Searches',
                        value: '$totalSearches',
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: _StatCard(
                        icon: Icons.notifications_active,
                        title: 'Alerts',
                        value: 'Coming soon',
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                /// 🧭 Section Title
                const Text(
                  'Recent Searches',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 12),

                /// 🧾 Show only top 2 searches
                if (provider.searches.isEmpty)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.only(top: 40),
                      child: Text('No searches yet'),
                    ),
                  )
                else
                  ...provider.searches.take(2).map(
                        (search) => Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 10,
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.flight, size: 28),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  '${search.origin} → ${search.destination}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
              ],
            ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _StatCard({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, size: 28, color: const Color(0xFF1565C0)),
            const SizedBox(height: 10),
            Text(
              value,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(title),
          ],
        ),
      ),
    );
  }
}