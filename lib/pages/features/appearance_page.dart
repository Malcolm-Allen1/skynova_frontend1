import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/app_settings_provider.dart';

class AppearancePage extends StatelessWidget {
  const AppearancePage({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<AppSettingsProvider>();
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final accentOptions = [
      _AccentOption('Emerald', 'green', const Color(0xFF16A34A)),
      _AccentOption('Ocean', 'blue', const Color(0xFF2563EB)),
      _AccentOption('Sunset', 'orange', const Color(0xFFF97316)),
      _AccentOption('Royal', 'purple', const Color(0xFF7C3AED)),
      _AccentOption('Teal', 'teal', const Color(0xFF0F766E)),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Appearance'), centerTitle: true),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            'Display Mode',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Choose how Skynova looks across the app.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurface.withOpacity(0.68),
            ),
          ),
          const SizedBox(height: 16),

          _ModeCard(
            title: 'System Default',
            subtitle: 'Match your device appearance automatically',
            icon: Icons.phone_android_rounded,
            selected: settings.themeMode == ThemeMode.system,
            onTap: () {
              context.read<AppSettingsProvider>().setThemeMode(
                ThemeMode.system,
              );
              _showAppliedMessage(context, 'System appearance enabled');
            },
          ),
          const SizedBox(height: 12),
          _ModeCard(
            title: 'Light Mode',
            subtitle: 'Bright and clean look',
            icon: Icons.light_mode_rounded,
            selected: settings.themeMode == ThemeMode.light,
            onTap: () {
              context.read<AppSettingsProvider>().setThemeMode(ThemeMode.light);
              _showAppliedMessage(context, 'Light mode applied');
            },
          ),
          const SizedBox(height: 12),
          _ModeCard(
            title: 'Dark Mode',
            subtitle: 'Modern low-light experience',
            icon: Icons.dark_mode_rounded,
            selected: settings.themeMode == ThemeMode.dark,
            onTap: () {
              context.read<AppSettingsProvider>().setThemeMode(ThemeMode.dark);
              _showAppliedMessage(context, 'Dark mode applied');
            },
          ),

          const SizedBox(height: 28),

          Text(
            'Accent Theme',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Choose the color style used for highlights, buttons, and active elements.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurface.withOpacity(0.68),
            ),
          ),
          const SizedBox(height: 16),

          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: accentOptions.map((option) {
              final isSelected = settings.themeKey == option.key;

              return InkWell(
                borderRadius: BorderRadius.circular(18),
                onTap: () {
                  context.read<AppSettingsProvider>().setThemeKey(option.key);
                  _showAppliedMessage(
                    context,
                    '${option.label} accent applied',
                  );
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  width: 110,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: isSelected
                          ? option.color
                          : colorScheme.outline.withOpacity(0.18),
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
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
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
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 28),

          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: colorScheme.outline.withOpacity(0.14)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.visibility_rounded, color: colorScheme.primary),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Your appearance changes should update across the app. If a screen still shows hard-to-read text, that page may still be using fixed colors and needs a theme-based update.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurface.withOpacity(0.72),
                      height: 1.45,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showAppliedMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
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
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: colorScheme.onSurface,
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
