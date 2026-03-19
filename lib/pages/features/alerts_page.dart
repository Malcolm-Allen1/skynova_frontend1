import 'package:flutter/material.dart';

class AlertsPage extends StatelessWidget {
  const AlertsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text(
          'Open a search card from Home to manage alerts.',
          style: TextStyle(fontSize: 16),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}