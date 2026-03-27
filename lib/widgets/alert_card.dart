import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import '../models/alert_model.dart';

class AlertCard extends StatelessWidget {
  final AlertModel alert;
  final VoidCallback? onDelete;

  const AlertCard({super.key, required this.alert, this.onDelete});

  String _formatRule(String ruleType) {
    switch (ruleType) {
      case 'below_amount':
        return 'Alert when fare goes below target';
      case 'drop_percent':
        return 'Alert when fare drops by percent';
      default:
        return ruleType;
    }
  }

  String _thresholdText() {
    if (alert.ruleType == 'drop_percent') {
      return '${alert.thresholdValue.toStringAsFixed(0)}% drop';
    }
    return 'Below ${alert.thresholdValue.toStringAsFixed(0)}';
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEAF2FF),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(Icons.notifications_active_outlined, color: AppTheme.trustBlue),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${alert.origin} → ${alert.destination}',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 4),
                      Text(_formatRule(alert.ruleType), style: const TextStyle(color: AppTheme.textMuted)),
                    ],
                  ),
                ),
                if (onDelete != null)
                  IconButton(
                    onPressed: onDelete,
                    icon: const Icon(Icons.delete_outline),
                  ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                _pill(alert.isActive ? 'Active' : 'Paused', alert.isActive ? const Color(0xFFEAFBF4) : const Color(0xFFF2F4F7), alert.isActive ? AppTheme.successGreen : AppTheme.textMuted),
                const SizedBox(width: 8),
                _pill(_thresholdText(), const Color(0xFFFFF4CC), const Color(0xFF8A5B00)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _pill(String text, Color bg, Color fg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(999)),
      child: Text(text, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: fg)),
    );
  }
}
