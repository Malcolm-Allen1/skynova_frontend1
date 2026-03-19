import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
  @override
  void initState() {
    super.initState();
    Future.microtask(() => _loadSearches());
  }

  Future<void> _loadSearches() async {
    final token = context.read<AuthProvider>().token;
    if (token != null && token.isNotEmpty) {
      await context.read<SearchProvider>().fetchSearches(token);
    }
  }

  Future<void> _openSearchForm({dynamic search}) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SearchFormPage(search: search),
      ),
    );

    if (!mounted) return;
    await _loadSearches();
  }

  Future<void> _deleteSearch(int searchId) async {
    final token = context.read<AuthProvider>().token;
    if (token == null || token.isEmpty) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Search'),
        content: const Text(
          'Are you sure you want to delete this saved search?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final success = await context.read<SearchProvider>().deleteSearch(
          token: token,
          id: searchId,
        );

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? 'Search deleted successfully'
              : (context.read<SearchProvider>().error ??
                  'Failed to delete search'),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final searchProvider = context.watch<SearchProvider>();

    if (searchProvider.isLoading && searchProvider.searches.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (searchProvider.error != null && searchProvider.searches.isEmpty) {
      return RefreshIndicator(
        onRefresh: _loadSearches,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(24),
          children: [
            const SizedBox(height: 120),
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.grey.shade500,
            ),
            const SizedBox(height: 16),
            Center(
              child: Text(
                'Something went wrong',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: Text(
                searchProvider.error!,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey.shade700),
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton.icon(
                onPressed: _loadSearches,
                icon: const Icon(Icons.refresh),
                label: const Text('Try Again'),
              ),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _loadSearches,
        child: searchProvider.searches.isEmpty
            ? ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(24),
                children: [
                  const SizedBox(height: 100),
                  Container(
                    height: 160,
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: const Icon(
                      Icons.travel_explore,
                      size: 72,
                      color: Color(0xFF1565C0),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Center(
                    child: Text(
                      'No saved searches yet',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Center(
                    child: Text(
                      'Create a travel search to start tracking flight deals and price changes.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Center(
                    child: ElevatedButton.icon(
                      onPressed: () => _openSearchForm(),
                      icon: const Icon(Icons.add),
                      label: const Text('Create Search'),
                    ),
                  ),
                ],
              )
            : ListView.builder(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                itemCount: searchProvider.searches.length,
                itemBuilder: (context, index) {
                  final search = searchProvider.searches[index];
                  return SearchCard(
                    search: search,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => SearchDetailPage(search: search),
                        ),
                      );
                    },
                    onEdit: () => _openSearchForm(search: search),
                    onDelete: () => _deleteSearch(search.id),
                  );
                },
              ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openSearchForm(),
        icon: const Icon(Icons.add),
        label: const Text('Add Search'),
      ),
    );
  }
}