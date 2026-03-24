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
  bool _hasTriedInitialLoad = false;
  bool _isLoadingSearches = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(() => _tryInitialLoad());
  }

  Future<void> _tryInitialLoad() async {
    if (!mounted || _hasTriedInitialLoad) return;

    final authProvider = context.read<AuthProvider>();

    // If auth/session is still loading, wait until build runs again.
    if (authProvider.isCheckingSession) return;

    _hasTriedInitialLoad = true;
    await _loadSearches();
  }

  Future<void> _loadSearches() async {
    if (!mounted || _isLoadingSearches) return;

    final authProvider = context.read<AuthProvider>();
    final token = authProvider.token;

    if (authProvider.isCheckingSession) return;
    if (token == null || token.isEmpty) return;

    _isLoadingSearches = true;

    try {
      await context.read<SearchProvider>().fetchSearches(token);
    } catch (e) {
      debugPrint('Error loading searches: $e');
    } finally {
      _isLoadingSearches = false;
    }
  }

  Future<void> _refreshSearches() async {
    _hasTriedInitialLoad = true;
    await _loadSearches();
  }

  Future<void> _openSearchForm({dynamic search}) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SearchFormPage(search: search),
      ),
    );

    if (!mounted) return;
    await _refreshSearches();
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

    if (success) {
      await _refreshSearches();
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final searchProvider = context.watch<SearchProvider>();

    // When auth finishes, try initial load once.
    if (!authProvider.isCheckingSession &&
        !_hasTriedInitialLoad &&
        !_isLoadingSearches) {
      Future.microtask(() => _tryInitialLoad());
    }

    // While checking session, show loader.
    if (authProvider.isCheckingSession) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    // If no token, user is not logged in.
    if (authProvider.token == null || authProvider.token!.isEmpty) {
      return Scaffold(
        body: RefreshIndicator(
          onRefresh: _refreshSearches,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(24),
            children: const [
              SizedBox(height: 140),
              Icon(
                Icons.lock_outline,
                size: 72,
                color: Colors.grey,
              ),
              SizedBox(height: 16),
              Center(
                child: Text(
                  'You are not logged in',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(height: 8),
              Center(
                child: Text(
                  'Please log in to view your saved searches.',
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (searchProvider.isLoading && searchProvider.searches.isEmpty) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (searchProvider.error != null && searchProvider.searches.isEmpty) {
      return Scaffold(
        body: RefreshIndicator(
          onRefresh: _refreshSearches,
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
                  onPressed: _refreshSearches,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Try Again'),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _refreshSearches,
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