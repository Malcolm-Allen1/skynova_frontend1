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
    final token = context.read<AuthProvider>().token;

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SearchFormPage(search: search),
      ),
    );

    if (!mounted) return;

    if (token != null && token.isNotEmpty) {
      await context.read<SearchProvider>().fetchSearches(token);
    }

    setState(() {});
  }

  Future<void> _deleteSearch(int searchId) async {
    final token = context.read<AuthProvider>().token;
    if (token == null || token.isEmpty) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
        title: const Text('Delete Search'),
        content: const Text(
          'Are you sure you want to delete this saved search?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
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

    final provider = context.read<SearchProvider>();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? 'Search deleted successfully'
              : (provider.error ?? 'Failed to delete search'),
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

    if (!authProvider.isCheckingSession &&
        !_hasTriedInitialLoad &&
        !_isLoadingSearches) {
      Future.microtask(() => _tryInitialLoad());
    }

    if (authProvider.isCheckingSession) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (authProvider.token == null || authProvider.token!.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Saved Searches'),
        ),
        body: const Center(
          child: Text('You are not logged in'),
        ),
      );
    }

    if (searchProvider.isLoading && searchProvider.searches.isEmpty) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (searchProvider.error != null && searchProvider.searches.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Saved Searches'),
        ),
        body: Center(
          child: Text(searchProvider.error!),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        title: const Text(
          'Saved Searches',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        backgroundColor: Theme.of(context).colorScheme.surface,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
      ),
      body: RefreshIndicator(
        onRefresh: _refreshSearches,
        child: searchProvider.searches.isEmpty
            ? ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(24),
                children: [
                  const SizedBox(height: 100),
                  const Icon(Icons.travel_explore, size: 72),
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
                  const Center(
                    child: Text(
                      'Create a travel search to start tracking deals.',
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              )
            : ListView.builder(
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
                          builder: (_) =>
                              SearchDetailPage(search: search),
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