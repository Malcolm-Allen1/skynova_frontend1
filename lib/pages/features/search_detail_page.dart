import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/helpers/destination_image_helper.dart';
import '../../models/search_model.dart';
import '../../providers/alert_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/alert_card.dart';

class SearchDetailPage extends StatefulWidget {
  final SearchModel search;

  const SearchDetailPage({
    super.key,
    required this.search,
  });

  @override
  State<SearchDetailPage> createState() => _SearchDetailPageState();
}

class _SearchDetailPageState extends State<SearchDetailPage> {
  final thresholdController = TextEditingController();
  String selectedRuleType = 'below_amount';

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final token = context.read<AuthProvider>().token;
      if (token != null && token.isNotEmpty) {
        context.read<AlertProvider>().fetchSearchAlerts(
              token,
              widget.search.id,
            );
        context.read<AlertProvider>().fetchPriceHistory(
              token,
              widget.search.id,
            );
      }
    });
  }

  @override
  void dispose() {
    thresholdController.dispose();
    super.dispose();
  }

  String _formatDate(String? date) {
    if (date == null || date.trim().isEmpty) return 'Not set';

    try {
      final parsed = DateTime.parse(date);
      final monthNames = [
        'Jan','Feb','Mar','Apr','May','Jun',
        'Jul','Aug','Sep','Oct','Nov','Dec',
      ];
      return '${monthNames[parsed.month - 1]} ${parsed.day}, ${parsed.year}';
    } catch (_) {
      return date;
    }
  }

  String _formatBudget() {
    if (widget.search.maxPrice == null) return 'No max price set';
    return '${widget.search.currency} ${widget.search.maxPrice!.toStringAsFixed(2)}';
  }

  @override
  Widget build(BuildContext context) {
    final alertProvider = context.watch<AlertProvider>();
    final authProvider = context.read<AuthProvider>();
    final token = authProvider.token;

    final imageUrl = getDestinationImage(widget.search.destination);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text('${widget.search.origin} → ${widget.search.destination}'),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) {
                      return Container(
                        color: Colors.blue.shade50,
                        alignment: Alignment.center,
                        child: const Icon(
                          Icons.travel_explore,
                          size: 80,
                          color: Color(0xFF1565C0),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 18, 16, 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Tracked Route',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 20),

                  Row(
                    children: [
                      Expanded(
                        child: _InfoCard(
                          icon: Icons.flight_takeoff,
                          label: 'Origin',
                          value: widget.search.origin,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _InfoCard(
                          icon: Icons.flight_land,
                          label: 'Destination',
                          value: widget.search.destination,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  Row(
                    children: [
                      Expanded(
                        child: _InfoCard(
                          icon: Icons.calendar_today_outlined,
                          label: 'Departure',
                          value: _formatDate(widget.search.departDate),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _InfoCard(
                          icon: Icons.event_outlined,
                          label: 'Return',
                          value: _formatDate(widget.search.returnDate),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  _InfoCard(
                    icon: Icons.attach_money,
                    label: 'Budget',
                    value: _formatBudget(),
                  ),

                  const SizedBox(height: 30),

                  const Text(
                    'Create Alert',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 12),

                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      children: [
                        DropdownButtonFormField<String>(
                          value: selectedRuleType,
                          decoration: const InputDecoration(labelText: 'Rule Type'),
                          items: const [
                            DropdownMenuItem(
                              value: 'below_amount',
                              child: Text('Below Amount'),
                            ),
                            DropdownMenuItem(
                              value: 'drop_percent',
                              child: Text('Drop Percent'),
                            ),
                          ],
                          onChanged: (value) {
                            if (value != null) {
                              setState(() => selectedRuleType = value);
                            }
                          },
                        ),

                        const SizedBox(height: 12),

                        TextField(
                          controller: thresholdController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Threshold value',
                          ),
                        ),

                        const SizedBox(height: 14),

                        SizedBox(
                          width: double.infinity,
                          child: FilledButton(
                            onPressed: token == null
                                ? null
                                : () async {
                                    final value = double.tryParse(
                                      thresholdController.text.trim(),
                                    );

                                    if (value == null || value <= 0) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text('Enter a valid value'),
                                        ),
                                      );
                                      return;
                                    }

                                    final success =
                                        await alertProvider.createAlert(
                                      token,
                                      widget.search.id,
                                      selectedRuleType,
                                      value,
                                    );

                                    if (!context.mounted) return;

                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          success
                                              ? 'Alert created'
                                              : (alertProvider.error ?? 'Failed'),
                                        ),
                                      ),
                                    );

                                    if (success) {
                                      thresholdController.clear();
                                    }
                                  },
                            child: const Text('Save Alert'),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),

                  const Text(
                    'Alerts',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 12),

                  if (alertProvider.searchAlerts.isEmpty)
                    const Text('No alerts created yet')
                  else
                    ...alertProvider.searchAlerts.map(
                      (alert) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: AlertCard(
                          alert: alert,
                          onDelete: token == null
                              ? null
                              : () async {
                                  final success =
                                      await alertProvider.deleteAlert(
                                    token: token,
                                    alertId: alert.id,
                                    searchId: widget.search.id,
                                  );

                                  if (!context.mounted) return;

                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        success
                                            ? 'Alert deleted'
                                            : (alertProvider.error ??
                                                'Failed to delete'),
                                      ),
                                    ),
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
    );
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoCard({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.blue),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label),
              Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }
}