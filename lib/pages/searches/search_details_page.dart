import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/helpers/destination_image_helper.dart';
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

  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      final token = context.read<AuthProvider>().token;

      if (token != null && token.isNotEmpty) {
        await context.read<AlertProvider>().fetchSearchAlerts(
              token,
              widget.search.id,
            );

        await context.read<AlertProvider>().fetchPriceHistory(
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
        'Jul','Aug','Sep','Oct','Nov','Dec'
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

    // ✅ FIXED price chart mapping
    final chartPoints = alertProvider.prices.map((price) {
      String label = '';
      try {
        final parsed = price.capturedAt;
        final shortMonth = [
          'Jan','Feb','Mar','Apr','May','Jun',
          'Jul','Aug','Sep','Oct','Nov','Dec'
        ][parsed.month - 1];

        label = '$shortMonth ${parsed.day}';
      } catch (_) {}

      return PricePoint(
        price: price.price,
        label: label,
      );
    }).toList();

    // ✅ PRICE DROP DETECTION
    if (alertProvider.hasPriceDropped()) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Price dropped from ${alertProvider.previousPrice()?.toStringAsFixed(2)} '
              'to ${alertProvider.latestPrice()?.toStringAsFixed(2)}',
            ),
          ),
        );
      });
    }

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                '${widget.search.origin} → ${widget.search.destination}',
              ),
              background: Image.network(
                imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: Colors.blue.shade50,
                  alignment: Alignment.center,
                  child: const Icon(Icons.travel_explore, size: 80),
                ),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Trip Info',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 12),

                  Text('Origin: ${widget.search.origin}'),
                  Text('Destination: ${widget.search.destination}'),
                  Text('Departure: ${_formatDate(widget.search.departDate)}'),
                  Text('Return: ${_formatDate(widget.search.returnDate)}'),
                  Text('Budget: ${_formatBudget()}'),

                  const SizedBox(height: 24),

                  const Text(
                    'Price History',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 12),

                  PriceChart(
                    points: chartPoints,
                    currency: widget.search.currency,
                  ),

                  const SizedBox(height: 24),

                  const Text(
                    'Create Alert',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 12),

                  DropdownButtonFormField<String>(
                    value: selectedRuleType,
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
                    onChanged: (val) {
                      if (val != null) {
                        setState(() => selectedRuleType = val);
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

                  const SizedBox(height: 12),

                  ElevatedButton(
                    onPressed: token == null
                        ? null
                        : () async {
                            final value = double.tryParse(
                              thresholdController.text.trim(),
                            );

                            if (value == null || value <= 0) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Enter valid value'),
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
                                      : (alertProvider.error ??
                                          'Failed to create alert'),
                                ),
                              ),
                            );

                            if (success) {
                              thresholdController.clear();

                              await alertProvider.fetchSearchAlerts(
                                token,
                                widget.search.id,
                              );
                            }
                          },
                    child: const Text('Save Alert'),
                  ),

                  const SizedBox(height: 24),

                  const Text(
                    'Alerts',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 12),

                  // ✅ FIXED: ONLY SEARCH ALERTS
                  if (alertProvider.searchAlerts.isEmpty)
                    const Text('No alerts yet')
                  else
                    ...alertProvider.searchAlerts.map(
                      (alert) => AlertCard(
                        alert: alert,
                        onDelete: token == null
                            ? null
                            : () {
                                alertProvider.deleteAlert(
                                  token: token,
                                  alertId: alert.id,
                                  searchId: widget.search.id,
                                );
                              },
                      ),
                    ),

                  const SizedBox(height: 20),
              
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}