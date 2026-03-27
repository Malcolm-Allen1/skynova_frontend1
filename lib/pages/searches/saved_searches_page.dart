import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skynova_frontend1/core/theme/app_theme.dart';
import 'package:skynova_frontend1/pages/searches/search_details_page.dart';
import '../../providers/auth_provider.dart';
import '../../providers/search_provider.dart';
import '../../widgets/search_card.dart';
import 'search_form_page.dart';

class SavedSearchesPage extends StatefulWidget {
  const SavedSearchesPage({super.key});

  @override
  State<SavedSearchesPage> createState() => _SavedSearchesPageState();
}

class _SavedSearchesPageState extends State<SavedSearchesPage> {
  bool _hasTriedInitialLoad = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(_loadSearches);
  }

  Future<void> _loadSearches() async {
    if (_hasTriedInitialLoad && !mounted) return;
    final authProvider = context.read<AuthProvider>();
    final token = authProvider.token;
    if (token == null || token.isEmpty) return;
    _hasTriedInitialLoad = true;
    await context.read<SearchProvider>().fetchSearches(token);
  }

  Future<void> _deleteSearch(int id) async {
    final token = context.read<AuthProvider>().token;
    if (token == null || token.isEmpty) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Remove search?'),
        content: const Text('This will stop tracking the route and remove its saved search details.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Remove')),
        ],
      ),
    );

    if (confirm != true) return;

    final success = await context.read<SearchProvider>().deleteSearch(token: token, id: id);
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(success ? 'Saved search removed' : (context.read<SearchProvider>().error ?? 'Failed to remove search'))),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SearchProvider>();
    final searches = provider.searches;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Saved searches'),
        actions: [
          IconButton(onPressed: _loadSearches, icon: const Icon(Icons.refresh_rounded)),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppTheme.actionYellow,
        foregroundColor: Colors.black,
        onPressed: () async {
          await Navigator.push(context, MaterialPageRoute(builder: (_) => const SearchFormPage()));
          if (mounted) _loadSearches();
        },
        icon: const Icon(Icons.add_rounded),
        label: const Text('New search'),
      ),
      body: RefreshIndicator(
        onRefresh: _loadSearches,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 110),
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppTheme.cardBorder),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Track the routes that matter most', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
                  SizedBox(height: 6),
                  Text('Each saved search stores your origin, destination, travel dates, and budget so Skynova can watch for fresh deals.', style: TextStyle(color: AppTheme.textMuted, height: 1.4)),
                ],
              ),
            ),
            const SizedBox(height: 16),
            if (provider.isLoading && searches.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 40),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (searches.isEmpty)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(color: const Color(0xFFEAF2FF), borderRadius: BorderRadius.circular(18)),
                        child: const Icon(Icons.search_rounded, size: 34, color: AppTheme.trustBlue),
                      ),
                      const SizedBox(height: 14),
                      const Text('No saved searches yet', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                      const SizedBox(height: 8),
                      const Text('Create a route to unlock price history, alerts, and real travel-style tracking.', textAlign: TextAlign.center, style: TextStyle(color: AppTheme.textMuted)),
                      const SizedBox(height: 18),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(context, MaterialPageRoute(builder: (_) => const SearchFormPage()));
                        },
                        child: const Text('Create first search'),
                      ),
                    ],
                  ),
                ),
              )
            else
              ...searches.map(
                (search) => Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: SearchCard(
                    search: search,
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => SearchDetailPage(search: search)));
                    },
                    onEdit: () async {
                      await Navigator.push(context, MaterialPageRoute(builder: (_) => SearchFormPage(search: search)));
                      if (mounted) _loadSearches();
                    },
                    onDelete: () => _deleteSearch(search.id),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
