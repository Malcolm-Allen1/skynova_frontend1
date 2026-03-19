import 'package:flutter/material.dart';
import '../core/helpers/destination_image_helper.dart';
import '../models/search_model.dart';

class SearchCard extends StatelessWidget {
  final SearchModel search;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback? onTap;

  const SearchCard({
    super.key,
    required this.search,
    required this.onEdit,
    required this.onDelete,
    this.onTap,
  });

  String _formatDate(String? date) {
    if (date == null || date.trim().isEmpty) return 'Not set';

    try {
      final parsed = DateTime.parse(date);
      final monthNames = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec'
      ];
      return '${monthNames[parsed.month - 1]} ${parsed.day}, ${parsed.year}';
    } catch (_) {
      return date;
    }
  }

  String _formatBudget() {
    if (search.maxPrice == null) return 'No max price';
    return '${search.currency} ${search.maxPrice!.toStringAsFixed(2)}';
  }

  @override
  Widget build(BuildContext context) {
    final imageUrl = getDestinationImage(search.destination);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 18),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Card(
          margin: EdgeInsets.zero,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  Image.network(
                    imageUrl,
                    height: 180,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) {
                      return Container(
                        height: 180,
                        width: double.infinity,
                        color: Colors.blue.shade50,
                        alignment: Alignment.center,
                        child: const Icon(
                          Icons.travel_explore,
                          size: 64,
                          color: Color(0xFF1565C0),
                        ),
                      );
                    },
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        height: 180,
                        width: double.infinity,
                        color: Colors.blue.shade50,
                        alignment: Alignment.center,
                        child: const CircularProgressIndicator(),
                      );
                    },
                  ),
                  Positioned(
                    top: 14,
                    right: 14,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.92),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.flight_takeoff,
                            size: 16,
                            color: Color(0xFF1565C0),
                          ),
                          SizedBox(width: 6),
                          Text(
                            'Tracked',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${search.origin} → ${search.destination}',
                      style: const TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Monitor this route for price drops and deal alerts.',
                      style: TextStyle(
                        fontSize: 13.5,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: _InfoTile(
                            icon: Icons.calendar_today_outlined,
                            label: 'Departure',
                            value: _formatDate(search.departDate),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _InfoTile(
                            icon: Icons.event_outlined,
                            label: 'Return',
                            value: _formatDate(search.returnDate),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    _InfoTile(
                      icon: Icons.attach_money,
                      label: 'Budget',
                      value: _formatBudget(),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: onEdit,
                            icon: const Icon(Icons.edit_outlined),
                            label: const Text('Edit'),
                            style: OutlinedButton.styleFrom(
                              minimumSize: const Size.fromHeight(46),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: onDelete,
                            icon: const Icon(Icons.delete_outline),
                            label: const Text('Delete'),
                            style: ElevatedButton.styleFrom(
                              minimumSize: const Size.fromHeight(46),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.grey.shade200,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 18,
            color: const Color(0xFF1565C0),
          ),
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
                const SizedBox(height: 3),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
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