import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/alert_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/search_provider.dart';
import '../../widgets/alert_card.dart';
import '../searches/search_details_page.dart';

class AlertsPage extends StatefulWidget {
  const AlertsPage({super.key});

  @override
  State<AlertsPage> createState() => _AlertsPageState();
}

class _AlertsPageState extends State<AlertsPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(_loadAlerts);
  }

  Future<void> _loadAlerts() async {
    final token = context.read<AuthProvider>().token;
    if (token == null || token.isEmpty) return;
    await context.read<AlertProvider>().fetchAlerts(token);
  }

  Future<void> _deleteAlert(int alertId) async {
    final token = context.read<AuthProvider>().token;
    if (token == null || token.isEmpty) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete alert?'),
        content: const Text('This will remove the alert from your travel monitoring list.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete')),
        ],
      ),
    );

    if (confirm != true) return;
    final success = await context.read<AlertProvider>().deleteAlert(token: token, alertId: alertId);
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(success ? 'Alert deleted' : (context.read<AlertProvider>().error ?? 'Failed to delete alert'))),
    );

    if (success) _loadAlerts();
  }

  Future<void> _openSmartAddAlert() async {
    final token = context.read<AuthProvider>().token;
    if (token == null || token.isEmpty) return;

    final searchProvider = context.read<SearchProvider>();
    await searchProvider.fetchSearches(token);
    if (!mounted) return;

    final searches = searchProvider.searches;
    if (searches.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Create a saved search first.')));
      return;
    }

    final selected = searches.length == 1
        ? searches.first
        : await showModalBottomSheet<dynamic>(
            context: context,
            showDragHandle: true,
            builder: (context) => SafeArea(
              child: ListView(
                shrinkWrap: true,
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                children: [
                  const Text('Choose a search', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 12),
                  ...searches.map(
                    (search) => ListTile(
                      leading: const Icon(Icons.flight_outlined),
                      title: Text('${search.origin} → ${search.destination}'),
                      subtitle: Text(search.departDate ?? 'Flexible dates'),
                      onTap: () => Navigator.pop(context, search),
                    ),
                  ),
                ],
              ),
            ),
          );

    if (selected == null || !mounted) return;
    await Navigator.push(context, MaterialPageRoute(builder: (_) => SearchDetailPage(search: selected)));
    if (mounted) _loadAlerts();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final alertProvider = context.watch<AlertProvider>();

    if (authProvider.token == null || authProvider.token!.isEmpty) {
      return const Scaffold(body: Center(child: Text('Please log in to view alerts')));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Deal alerts'),
        actions: [
          IconButton(onPressed: _loadAlerts, icon: const Icon(Icons.refresh_rounded)),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppTheme.actionYellow,
        foregroundColor: Colors.black,
        onPressed: _openSmartAddAlert,
        icon: const Icon(Icons.add_alert_outlined),
        label: const Text('Add alert'),
      ),
      body: RefreshIndicator(
        onRefresh: _loadAlerts,
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
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: const Color(0xFFEAF2FF), borderRadius: BorderRadius.circular(16)),
                    child: const Icon(Icons.notifications_active_outlined, color: AppTheme.trustBlue),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${alertProvider.alerts.length} active travel alert${alertProvider.alerts.length == 1 ? '' : 's'}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                        const SizedBox(height: 4),
                        const Text('Monitor specific routes and get notified when fares reach your target.', style: TextStyle(color: AppTheme.textMuted)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            if (alertProvider.isLoading && alertProvider.alerts.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 40),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (alertProvider.alerts.isEmpty)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(color: const Color(0xFFEAF2FF), borderRadius: BorderRadius.circular(20)),
                        child: const Icon(Icons.notifications_none_rounded, size: 34, color: AppTheme.trustBlue),
                      ),
                      const SizedBox(height: 14),
                      const Text('No alerts yet', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                      const SizedBox(height: 8),
                      const Text('Add an alert to get notified when prices drop below your target or move by a percentage.', textAlign: TextAlign.center, style: TextStyle(color: AppTheme.textMuted)),
                      const SizedBox(height: 18),
                      ElevatedButton(onPressed: _openSmartAddAlert, child: const Text('Create alert')),
                    ],
                  ),
                ),
              )
            else
              ...alertProvider.alerts.map(
                (alert) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: AlertCard(alert: alert, onDelete: () => _deleteAlert(alert.id)),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
