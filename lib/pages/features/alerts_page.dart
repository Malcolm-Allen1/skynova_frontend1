import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../providers/alert_provider.dart';
import '../../providers/search_provider.dart';
import '../searches/search_details_page.dart';

class AlertsPage extends StatefulWidget {
  const AlertsPage({super.key});

  @override
  State<AlertsPage> createState() => _AlertsPageState();
}

class _AlertsPageState extends State<AlertsPage> {
  bool _hasLoaded = false;
  bool _isLoadingAlerts = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(() => _loadAlerts());
  }

  Future<void> _loadAlerts() async {
    if (!mounted || _isLoadingAlerts) return;

    final authProvider = context.read<AuthProvider>();

    if (authProvider.isCheckingSession) return;

    final token = authProvider.token;
    if (token == null || token.isEmpty) return;

    _isLoadingAlerts = true;

    try {
      await context.read<AlertProvider>().fetchAlerts(token);
      _hasLoaded = true;
    } catch (e) {
      debugPrint('Error loading alerts: $e');
    } finally {
      _isLoadingAlerts = false;
    }
  }

  Future<void> _refreshAlerts() async {
    await _loadAlerts();
  }

  Future<void> _deleteAlert(int alertId) async {
    final token = context.read<AuthProvider>().token;
    if (token == null || token.isEmpty) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Alert'),
        content: const Text('Are you sure you want to delete this alert?'),
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

    final success = await context.read<AlertProvider>().deleteAlert(
          token: token,
          alertId: alertId,
        );

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? 'Alert deleted successfully'
              : (context.read<AlertProvider>().error ?? 'Failed to delete alert'),
        ),
      ),
    );

    if (success) {
      await _refreshAlerts();
    }
  }

  String _formatRule(String ruleType) {
    switch (ruleType) {
      case 'below_amount':
        return 'Below Amount';
      case 'drop_percent':
        return 'Drop Percent';
      default:
        return ruleType;
    }
  }

  Future<void> _openSmartAddAlert() async {
    final authProvider = context.read<AuthProvider>();
    final token = authProvider.token;

    if (token == null || token.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please log in first')),
      );
      return;
    }

    final searchProvider = context.read<SearchProvider>();
    await searchProvider.fetchSearches(token);

    if (!mounted) return;

    final searches = searchProvider.searches;

    if (searches.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Create a saved search first, then add an alert'),
        ),
      );
      return;
    }

    if (searches.length == 1) {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => SearchDetailPage(search: searches.first),
        ),
      );

      if (!mounted) return;
      await _refreshAlerts();
      return;
    }

    final selectedSearch = await showModalBottomSheet<dynamic>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        final theme = Theme.of(context);

        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Choose a search',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Flexible(
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: searches.length,
                    separatorBuilder: (_, __) => Divider(
                      height: 1,
                      color: theme.colorScheme.outlineVariant,
                    ),
                    itemBuilder: (context, index) {
                      final search = searches[index];
                      return ListTile(
                        leading: Icon(
                          Icons.travel_explore,
                          color: theme.colorScheme.primary,
                        ),
                        title: Text('${search.origin} → ${search.destination}'),
                        subtitle: Text(
                          '${search.departDate ?? "No depart date"}'
                          '${search.returnDate != null ? " • ${search.returnDate}" : ""}',
                          style: TextStyle(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        onTap: () => Navigator.pop(context, search),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (selectedSearch == null || !mounted) return;

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SearchDetailPage(search: selectedSearch),
      ),
    );

    if (!mounted) return;
    await _refreshAlerts();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final authProvider = context.watch<AuthProvider>();
    final alertProvider = context.watch<AlertProvider>();

    if (!authProvider.isCheckingSession && !_hasLoaded && !_isLoadingAlerts) {
      Future.microtask(() => _loadAlerts());
    }

    if (authProvider.isCheckingSession) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (authProvider.token == null || authProvider.token!.isEmpty) {
      return const Scaffold(
        body: Center(
          child: Text('Please log in to view alerts'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Alerts'),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: _refreshAlerts,
        child: alertProvider.isLoading && alertProvider.alerts.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : alertProvider.error != null && alertProvider.alerts.isEmpty
                ? ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(24),
                    children: [
                      const SizedBox(height: 120),
                      Icon(
                        Icons.notifications_off_outlined,
                        size: 70,
                        color: colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(height: 16),
                      Center(
                        child: Text(
                          'Unable to load alerts',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Center(
                        child: Text(
                          alertProvider.error!,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Center(
                        child: FilledButton.icon(
                          onPressed: _refreshAlerts,
                          icon: const Icon(Icons.refresh),
                          label: const Text('Try Again'),
                        ),
                      ),
                    ],
                  )
                : alertProvider.alerts.isEmpty
                    ? ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.all(24),
                        children: [
                          const SizedBox(height: 100),
                          Container(
                            height: 170,
                            decoration: BoxDecoration(
                              color: colorScheme.primaryContainer.withOpacity(0.35),
                              borderRadius: BorderRadius.circular(24),
                            ),
                            child: Icon(
                              Icons.notifications_active_outlined,
                              size: 72,
                              color: colorScheme.primary,
                            ),
                          ),
                          const SizedBox(height: 24),
                          Center(
                            child: Text(
                              'No alerts yet',
                              style: theme.textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Center(
                            child: Text(
                              'Tap Add Alert to choose a saved search and set a price alert.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 14,
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                        ],
                      )
                    : ListView.builder(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                        itemCount: alertProvider.alerts.length,
                        itemBuilder: (context, index) {
                          final alert = alertProvider.alerts[index];

                          return Container(
                            margin: const EdgeInsets.only(bottom: 14),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: theme.cardColor,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: colorScheme.primaryContainer,
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                      child: Icon(
                                        Icons.notifications_active,
                                        color: colorScheme.primary,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        '${alert.origin} → ${alert.destination}',
                                        style: theme.textTheme.titleMedium?.copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    PopupMenuButton<String>(
                                      onSelected: (value) {
                                        if (value == 'delete') {
                                          _deleteAlert(alert.id);
                                        }
                                      },
                                      itemBuilder: (_) => const [
                                        PopupMenuItem(
                                          value: 'delete',
                                          child: Text('Delete'),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 14),
                                Text(
                                  'Rule: ${_formatRule(alert.ruleType)}',
                                  style: TextStyle(
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'Threshold: ${alert.thresholdValue}',
                                  style: TextStyle(
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'Status: ${alert.isActive ? "Active" : "Inactive"}',
                                  style: TextStyle(
                                    color: alert.isActive
                                        ? colorScheme.primary
                                        : colorScheme.error,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openSmartAddAlert,
        icon: const Icon(Icons.add_alert),
        label: const Text('Add Alert'),
      ),
    );
  }
}