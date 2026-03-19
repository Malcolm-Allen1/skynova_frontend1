import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/helpers/destination_image_helper.dart';
import '../../models/search_model.dart';
import '../../providers/alert_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/alert_card.dart';
import '../../widgets/price_chart.dart';
import '../../widgets/receipt_upload_card.dart';

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
        context.read<AlertProvider>().fetchAlerts(token, widget.search.id);
        context.read<AlertProvider>().fetchPriceHistory(token, widget.search.id);
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
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
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
    final imageUrl = getRouteImage(
      widget.search.origin,
      widget.search.destination,
    );

    final chartPoints = alertProvider.prices.map((price) {
      String label = price.capturedAt;
      try {
        final parsed = DateTime.parse(price.capturedAt);
        final shortMonth = [
          'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
          'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
        ][parsed.month - 1];
        label = '$shortMonth ${parsed.day}';
      } catch (_) {}
      return PricePoint(
        price: price.price,
        label: label,
      );
    }).toList();

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            stretch: true,
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
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        color: Colors.blue.shade50,
                        alignment: Alignment.center,
                        child: const CircularProgressIndicator(),
                      );
                    },
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withOpacity(0.15),
                          Colors.black.withOpacity(0.50),
                        ],
                      ),
                    ),
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
                  const SizedBox(height: 8),
                  Text(
                    'Monitor this trip for price changes and future deal alerts.',
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
                  ),
                  const SizedBox(height: 18),

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

                  const SizedBox(height: 28),
                  const Text(
                    'Price History',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  PriceChart(
                    points: chartPoints,
                    currency: widget.search.currency,
                  ),

                  const SizedBox(height: 28),
                  const Text(
                    'Receipt',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  const ReceiptUploadCard(),

                  const SizedBox(height: 28),
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
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        DropdownButtonFormField<String>(
                          value: selectedRuleType,
                          decoration: const InputDecoration(
                            labelText: 'Rule Type',
                          ),
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

                                    final success = await alertProvider.createAlert(
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
                                              : (alertProvider.error ?? 'Failed to create alert'),
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

                  const SizedBox(height: 28),
                  const Text(
                    'Alerts',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  if (alertProvider.alerts.isEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Text('No alerts created yet'),
                    )
                  else
                    ...alertProvider.alerts.map(
                      (alert) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: AlertCard(
                          alert: alert,
                          onDelete: token == null
                              ? null
                              : () {
                                  alertProvider.deleteAlert(
                                    token,
                                    alert.id,
                                    widget.search.id,
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
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: const Color(0xFF1565C0)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}