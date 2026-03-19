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

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: const CircleAvatar(
          child: Icon(Icons.notifications_active),
        ),
        title: Text(
          alert.ruleType == 'below_amount'
              ? 'Below amount alert'
              : 'Drop percent alert',
        ),
        subtitle: Text(
          'Threshold: ${alert.thresholdValue}\nLast triggered: ${alert.lastTriggeredAt ?? "Never"}',
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