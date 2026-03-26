import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/app_settings_provider.dart';

class AppearancePage extends StatelessWidget {
  const AppearancePage({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<AppSettingsProvider>();

    final accentOptions = [
  _AccentOption('Emerald', 'green', const Color(0xFF16A34A)),
  _AccentOption('Ocean', 'blue', const Color(0xFF2563EB)),
  _AccentOption('Sunset', 'orange', const Color(0xFFF97316)),
  _AccentOption('Royal', 'purple', const Color(0xFF7C3AED)),
  _AccentOption('Teal', 'teal', const Color(0xFF0F766E)),
];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Appearance'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            'Mode',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 12),

          _ModeCard(
            title: 'Light Mode',
            subtitle: 'Bright and clean look',
            icon: Icons.light_mode_rounded,
            selected: settings.themeMode == ThemeMode.light,
            onTap: () => context.read<AppSettingsProvider>().setThemeMode(
                  ThemeMode.light,
                ),
          ),
          const SizedBox(height: 12),
          _ModeCard(
            title: 'Dark Mode',
            subtitle: 'Modern low-light experience',
            icon: Icons.dark_mode_rounded,
            selected: settings.themeMode == ThemeMode.dark,
            onTap: () => context.read<AppSettingsProvider>().setThemeMode(
                  ThemeMode.dark,
                ),
          ),

          const SizedBox(height: 28),

          Text(
            'Accent Theme',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Choose a color style for your app',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.65),
                ),
          ),
          const SizedBox(height: 16),

          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: accentOptions.map((option) {
              final isSelected = settings.themeKey == option.key;

              return GestureDetector(
                onTap: () => context.read<AppSettingsProvider>().setThemeKey(option.key),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  width: 110,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: isSelected
                          ? option.color
                          : Theme.of(context).colorScheme.outline.withOpacity(0.18),
                      width: isSelected ? 2 : 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Container(
                        height: 42,
                        width: 42,
                        decoration: BoxDecoration(
                          color: option.color,
                          shape: BoxShape.circle,
                        ),
                        child: isSelected
                            ? const Icon(Icons.check, color: Colors.white)
                            : null,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        option.label,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _ModeCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _ModeCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: colorScheme.surface,
          border: Border.all(
            color: selected
                ? colorScheme.primary
                : colorScheme.outline.withOpacity(0.18),
            width: selected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              height: 46,
              width: 46,
              decoration: BoxDecoration(
                color: selected
                    ? colorScheme.primary.withOpacity(0.12)
                    : colorScheme.surfaceVariant.withOpacity(0.6),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                icon,
                color: selected ? colorScheme.primary : colorScheme.onSurface,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      color: colorScheme.onSurface.withOpacity(0.65),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              selected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: selected ? colorScheme.primary : colorScheme.outline,
            ),
          ],
        ),
      ),
    );
  }
}

class _AccentOption {
  final String label;
  final String key;
  final Color color;

  const _AccentOption(this.label, this.key, this.color);
}