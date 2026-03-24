import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_settings_provider.dart';

class AppearancePage extends StatelessWidget {
  const AppearancePage({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<AppSettingsProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Appearance'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            'Theme Mode',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 12),

          RadioListTile<ThemeMode>(
            value: ThemeMode.system,
            groupValue: settings.themeMode,
            title: const Text('System Default'),
            subtitle: const Text('Follow the phone theme'),
            onChanged: (value) {
              if (value != null) {
                context.read<AppSettingsProvider>().setThemeMode(value);
              }
            },
          ),
          RadioListTile<ThemeMode>(
            value: ThemeMode.light,
            groupValue: settings.themeMode,
            title: const Text('Light Mode'),
            onChanged: (value) {
              if (value != null) {
                context.read<AppSettingsProvider>().setThemeMode(value);
              }
            },
          ),
          RadioListTile<ThemeMode>(
            value: ThemeMode.dark,
            groupValue: settings.themeMode,
            title: const Text('Dark Mode'),
            onChanged: (value) {
              if (value != null) {
                context.read<AppSettingsProvider>().setThemeMode(value);
              }
            },
          ),

          const SizedBox(height: 24),

          Text(
            'Accent Theme',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 12),

          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: const [
              _ThemeChoice(label: 'Mint', value: 'mint', color: Color(0xFF70C9B0)),
              _ThemeChoice(label: 'Blue', value: 'blue', color: Colors.blue),
              _ThemeChoice(label: 'Purple', value: 'purple', color: Colors.deepPurple),
              _ThemeChoice(label: 'Orange', value: 'orange', color: Colors.orange),
              _ThemeChoice(label: 'Green', value: 'green', color: Colors.green),
            ],
          ),
        ],
      ),
    );
  }
}

class _ThemeChoice extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _ThemeChoice({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<AppSettingsProvider>();
    final selected = settings.themeKey == value;

    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: () => context.read<AppSettingsProvider>().setThemeKey(value),
      child: Container(
        width: 110,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: selected ? color.withOpacity(0.15) : Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: selected ? color : Colors.transparent,
            width: 2,
          ),
        ),
        child: Column(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: color,
            ),
            const SizedBox(height: 8),
            Text(label),
          ],
        ),
      ),
    );
  }
}