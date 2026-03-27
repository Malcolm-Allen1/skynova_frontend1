import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/helpers/destination_image_helper.dart';
import '../../core/theme/app_theme.dart';
import '../../models/search_model.dart';
import '../../providers/alert_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/alert_card.dart';
import '../../widgets/price_chart.dart';

class SearchDetailPage extends StatefulWidget {
  final SearchModel search;

  const SearchDetailPage({super.key, required this.search});

  @override
  State<SearchDetailPage> createState() => _SearchDetailPageState();
}

class _SearchDetailPageState extends State<SearchDetailPage> {
  final thresholdController = TextEditingController();
  String selectedRuleType = 'below_amount';
  bool _snackShown = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(_load);
  }

  Future<void> _load() async {
    final token = context.read<AuthProvider>().token;
    if (token == null || token.isEmpty) return;

    await context.read<AlertProvider>().fetchSearchAlerts(token, widget.search.id);
    await context.read<AlertProvider>().fetchPriceHistory(token, widget.search.id);
  }

  @override
  void dispose() {
    thresholdController.dispose();
    super.dispose();
  }

  String _formatDate(String? date) {
    if (date == null || date.trim().isEmpty) return 'Flexible';
    try {
      final parsed = DateTime.parse(date);
      const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      return '${months[parsed.month - 1]} ${parsed.day}, ${parsed.year}';
    } catch (_) {
      return date;
    }
  }

  String _formatBudget() {
    if (widget.search.maxPrice == null) return 'Any fare';
    return '${widget.search.currency} ${widget.search.maxPrice!.toStringAsFixed(2)}';
  }

  @override
  Widget build(BuildContext context) {
    final alertProvider = context.watch<AlertProvider>();
    final authProvider = context.read<AuthProvider>();
    final token = authProvider.token;

    final imageUrl = getRouteImage(widget.search.origin, widget.search.destination);
    final chartPoints = alertProvider.prices.map((price) {
      const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      return PricePoint(
        price: price.price,
        label: '${months[price.capturedAt.month - 1]} ${price.capturedAt.day}',
      );
    }).toList();

    if (!_snackShown && alertProvider.hasPriceDropped()) {
      _snackShown = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Deal found: price dropped from ${alertProvider.previousPrice()?.toStringAsFixed(2)} to ${alertProvider.latestPrice()?.toStringAsFixed(2)}',
            ),
          ),
        );
      });
    }

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _load,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverAppBar(
              expandedHeight: 250,
              pinned: true,
              title: Text('${widget.search.origin} → ${widget.search.destination}'),
              flexibleSpace: FlexibleSpaceBar(
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(color: const Color(0xFFEAF2FF)),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [Colors.black.withOpacity(0.50), Colors.transparent],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(18),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Trip snapshot', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
                            const SizedBox(height: 14),
                            Row(
                              children: [
                                Expanded(child: _InfoCard(icon: Icons.flight_takeoff_rounded, label: 'Origin', value: widget.search.origin)),
                                const SizedBox(width: 10),
                                Expanded(child: _InfoCard(icon: Icons.flight_land_rounded, label: 'Destination', value: widget.search.destination)),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                Expanded(child: _InfoCard(icon: Icons.calendar_today_outlined, label: 'Depart', value: _formatDate(widget.search.departDate))),
                                const SizedBox(width: 10),
                                Expanded(child: _InfoCard(icon: Icons.event_outlined, label: 'Return', value: _formatDate(widget.search.returnDate))),
                              ],
                            ),
                            const SizedBox(height: 10),
                            _InfoCard(icon: Icons.attach_money_outlined, label: 'Target budget', value: _formatBudget()),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    const Text('Price history', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
                    const SizedBox(height: 10),
                    PriceChart(points: chartPoints, currency: widget.search.currency),
                    const SizedBox(height: 18),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(18),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Create alert', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
                            const SizedBox(height: 6),
                            const Text('Get notified when fares move in your favor.', style: TextStyle(color: AppTheme.textMuted)),
                            const SizedBox(height: 14),
                            DropdownButtonFormField<String>(
                              value: selectedRuleType,
                              items: const [
                                DropdownMenuItem(value: 'below_amount', child: Text('Alert when price goes below amount')),
                                DropdownMenuItem(value: 'drop_percent', child: Text('Alert when price drops by percent')),
                              ],
                              onChanged: (val) {
                                if (val != null) setState(() => selectedRuleType = val);
                              },
                            ),
                            const SizedBox(height: 12),
                            TextField(
                              controller: thresholdController,
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              decoration: InputDecoration(
                                labelText: selectedRuleType == 'drop_percent' ? 'Percent drop' : 'Target fare amount',
                              ),
                            ),
                            const SizedBox(height: 14),
                            ElevatedButton.icon(
                              onPressed: token == null
                                  ? null
                                  : () async {
                                      final value = double.tryParse(thresholdController.text.trim());
                                      if (value == null || value <= 0) {
                                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Enter a valid threshold value')));
                                        return;
                                      }

                                      final success = await alertProvider.createAlert(token, widget.search.id, selectedRuleType, value);
                                      if (!mounted) return;

                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text(success ? 'Alert created successfully' : (alertProvider.error ?? 'Failed to create alert'))),
                                      );

                                      if (success) thresholdController.clear();
                                    },
                              icon: const Icon(Icons.notifications_active_outlined),
                              label: const Text('Save alert'),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    const Text('Active alerts', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
                    const SizedBox(height: 10),
                    if (alertProvider.isLoading && alertProvider.searchAlerts.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 24),
                        child: Center(child: CircularProgressIndicator()),
                      )
                    else if (alertProvider.searchAlerts.isEmpty)
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            children: const [
                              Icon(Icons.notifications_off_outlined, size: 34, color: AppTheme.textMuted),
                              SizedBox(height: 10),
                              Text('No alerts yet', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
                              SizedBox(height: 6),
                              Text('Create your first alert above to get notified when this fare changes.', textAlign: TextAlign.center, style: TextStyle(color: AppTheme.textMuted)),
                            ],
                          ),
                        ),
                      )
                    else
                      ...alertProvider.searchAlerts.map(
                        (alert) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: AlertCard(
                            alert: alert,
                            onDelete: token == null
                                ? null
                                : () async {
                                    final success = await alertProvider.deleteAlert(token: token, alertId: alert.id, searchId: widget.search.id);
                                    if (!mounted) return;
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text(success ? 'Alert deleted' : (alertProvider.error ?? 'Failed to delete alert'))),
                                    );
                                  },
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoCard({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.cardBorder),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.trustBlue),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 12, color: AppTheme.textMuted)),
                const SizedBox(height: 4),
                Text(value, style: const TextStyle(fontWeight: FontWeight.w700)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
