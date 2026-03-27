import 'package:flutter/material.dart';
import '../core/helpers/destination_image_helper.dart';
import '../core/theme/app_theme.dart';
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
    if (date == null || date.trim().isEmpty) return 'Flexible';
    try {
      final parsed = DateTime.parse(date);
      const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      return '${months[parsed.month - 1]} ${parsed.day}';
    } catch (_) {
      return date;
    }
  }

  String _budgetLabel() {
    if (search.maxPrice == null) return 'Any fare';
    return '${search.currency} ${search.maxPrice!.toStringAsFixed(0)} max';
  }

  @override
  Widget build(BuildContext context) {
    final imageUrl = getDestinationImage(search.destination);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Image.network(
                  imageUrl,
                  height: 168,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    height: 168,
                    color: const Color(0xFFE8F1FF),
                    alignment: Alignment.center,
                    child: const Icon(Icons.flight_takeoff, size: 56, color: AppTheme.trustBlue),
                  ),
                ),
                Positioned(
                  left: 14,
                  top: 14,
                  child: _TopBadge(
                    icon: Icons.notifications_active_outlined,
                    label: 'Price tracking on',
                    bg: Colors.white,
                    fg: AppTheme.trustBlue,
                  ),
                ),
                Positioned(
                  right: 14,
                  top: 14,
                  child: _TopBadge(
                    icon: Icons.local_fire_department_outlined,
                    label: search.maxPrice == null ? 'Live fares' : 'Deal watch',
                    bg: const Color(0xFFFFF4CC),
                    fg: const Color(0xFF8A5B00),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          '${search.origin} → ${search.destination}',
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
                        ),
                      ),
                      Text(
                        _budgetLabel(),
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.trustBlue,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Track this route for fresh deals, price drops, and trip-ready alerts.',
                    style: TextStyle(color: AppTheme.textMuted, height: 1.35),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: _MetaTile(
                          icon: Icons.calendar_today_outlined,
                          label: 'Depart',
                          value: _formatDate(search.departDate),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _MetaTile(
                          icon: Icons.event_outlined,
                          label: 'Return',
                          value: _formatDate(search.returnDate),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppTheme.cardBorder),
                    ),
                    child: Row(
                      children: const [
                        Icon(Icons.insights_outlined, size: 18, color: AppTheme.successGreen),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Real-time alerts, historical fares, and saved search actions all in one place.',
                            style: TextStyle(fontSize: 13, color: AppTheme.textMuted),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: onEdit,
                          icon: const Icon(Icons.edit_outlined),
                          label: const Text('Edit search'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: onDelete,
                          icon: const Icon(Icons.delete_outline),
                          label: const Text('Remove'),
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
    );
  }
}

class _TopBadge extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color bg;
  final Color fg;

  const _TopBadge({required this.icon, required this.label, required this.bg, required this.fg});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: bg.withOpacity(0.96),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: fg),
          const SizedBox(width: 6),
          Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: fg)),
        ],
      ),
    );
  }
}

class _MetaTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _MetaTile({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.cardBorder),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppTheme.trustBlue),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 12, color: AppTheme.textMuted)),
                const SizedBox(height: 3),
                Text(value, style: const TextStyle(fontWeight: FontWeight.w700)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
