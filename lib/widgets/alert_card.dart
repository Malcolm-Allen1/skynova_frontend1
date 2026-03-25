import 'package:flutter/material.dart';
import '../models/alert_model.dart';

class AlertCard extends StatelessWidget {
  final AlertModel alert;
  final VoidCallback? onDelete;

  const AlertCard({
    super.key,
    required this.alert,
    this.onDelete,
  });

  String _formatRule(String ruleType) {
    switch (ruleType) {
      case 'below_amount':
        return 'Below Amount Alert';
      case 'drop_percent':
        return 'Drop Percent Alert';
      default:
        return ruleType;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: const CircleAvatar(
          child: Icon(Icons.notifications_active),
        ),

        // ✅ FIXED title
        title: Text(_formatRule(alert.ruleType)),

        // ✅ FIXED subtitle (no crash)
        subtitle: Text(
          'Route: ${alert.origin} → ${alert.destination}\n'
          'Threshold: ${alert.thresholdValue}',
        ),

        isThreeLine: true,

        trailing: IconButton(
          onPressed: onDelete,
          icon: const Icon(Icons.delete_outline),
        ),
      ),
    );
  }
}