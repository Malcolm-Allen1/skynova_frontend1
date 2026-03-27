import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:skynova_frontend1/core/routes/app_routes.dart';
import 'package:skynova_frontend1/core/theme/app_theme.dart';
import 'package:skynova_frontend1/pages/features/personal_information_page.dart';
import '../../providers/app_settings_provider.dart';
import '../../providers/auth_provider.dart';
import 'appearance_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final ImagePicker _picker = ImagePicker();
  String? _customDisplayName;

  bool _dealAlertsEnabled = true;
  bool _priceDropNotifications = true;
  bool _trackingUpdatesEnabled = true;
  bool _sessionProtectionEnabled = true;
  bool _fareInsightsEnabled = true;

  Future<void> _pickProfileImage() async {
    final file = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (file == null || !mounted) return;

    await context.read<AppSettingsProvider>().setProfileImagePath(file.path);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profile photo updated')),
    );
  }

  Future<void> _editDisplayName(String currentName) async {
    final controller = TextEditingController(text: currentName);

    final newName = await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Edit display name'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Enter your name',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(
              context,
              controller.text.trim(),
            ),
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (newName == null || newName.trim().isEmpty) return;

    setState(() => _customDisplayName = newName.trim());

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Display name updated')),
    );
  }

  Future<void> _openNotificationsSettings() async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Notification preferences',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Choose how Skynova keeps you updated on fare changes and route activity.',
                      style: TextStyle(
                        color: AppTheme.textMuted,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 18),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Deal alerts'),
                      subtitle: const Text(
                        'Get notified when a tracked fare becomes a deal',
                      ),
                      value: _dealAlertsEnabled,
                      onChanged: (value) {
                        setModalState(() => _dealAlertsEnabled = value);
                        setState(() => _dealAlertsEnabled = value);
                      },
                    ),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Price drop alerts'),
                      subtitle: const Text(
                        'Surface alerts when prices drop below previous fares',
                      ),
                      value: _priceDropNotifications,
                      onChanged: (value) {
                        setModalState(() => _priceDropNotifications = value);
                        setState(() => _priceDropNotifications = value);
                      },
                    ),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Tracking updates'),
                      subtitle: const Text(
                        'See updates when your saved routes are refreshed',
                      ),
                      value: _trackingUpdatesEnabled,
                      onChanged: (value) {
                        setModalState(() => _trackingUpdatesEnabled = value);
                        setState(() => _trackingUpdatesEnabled = value);
                      },
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Save preferences'),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Notification preferences updated')),
    );
  }

  Future<void> _openSecuritySettings() async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Security settings',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Manage session protection and account safety for Skynova.',
                      style: TextStyle(
                        color: AppTheme.textMuted,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 18),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Session protection'),
                      subtitle: const Text(
                        'Keep automatic session checks enabled',
                      ),
                      value: _sessionProtectionEnabled,
                      onChanged: (value) {
                        setModalState(() => _sessionProtectionEnabled = value);
                        setState(() => _sessionProtectionEnabled = value);
                      },
                    ),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.lock_reset_rounded),
                      title: const Text('Password reset'),
                      subtitle: const Text(
                        'Use your auth flow to update password securely',
                      ),
                      trailing: const Icon(Icons.chevron_right_rounded),
                      onTap: () {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(this.context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Password reset flow can be connected next',
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Done'),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _openInsightsSettings() async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Saved search insights',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Control how Skynova shows fare history and search insights.',
                      style: TextStyle(
                        color: AppTheme.textMuted,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 18),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Fare insights'),
                      subtitle: const Text(
                        'Show historical price movement on tracked routes',
                      ),
                      value: _fareInsightsEnabled,
                      onChanged: (value) {
                        setModalState(() => _fareInsightsEnabled = value);
                        setState(() => _fareInsightsEnabled = value);
                      },
                    ),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.show_chart_rounded),
                      title: const Text('Chart visibility'),
                      subtitle: const Text(
                        'Price charts appear in saved search details',
                      ),
                      trailing: const Icon(Icons.check_circle_rounded),
                    ),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.auto_graph_rounded),
                      title: const Text('Deal insights'),
                      subtitle: const Text(
                        'Track route movement and summarize fare opportunities',
                      ),
                      trailing: const Icon(Icons.chevron_right_rounded),
                      onTap: () {
                        ScaffoldMessenger.of(this.context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Deal insight settings are ready for expansion',
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Save insight settings'),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Saved search insight settings updated')),
    );
  }

  Future<void> _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Log out?'),
        content: const Text(
          'You’ll need to sign in again to access your saved searches and alerts.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Log out'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    await context.read<AuthProvider>().logout();

    if (!mounted) return;
    Navigator.of(context).pushNamedAndRemoveUntil(
      AppRoutes.login,
      (route) => false,
    );
  }

  Future<void> _deleteAccount() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete account?'),
        content: const Text(
          'This will permanently remove your Skynova account, saved searches, alerts, and related travel data. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete account'),
          ),
        ],
      ),
    );

    if (confirm != true || !mounted) return;

    try {
      final authProvider = context.read<AuthProvider>();
      await authProvider.deleteAccount();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Your account has been deleted')),
      );

      Navigator.of(context).pushNamedAndRemoveUntil(
        AppRoutes.login,
        (route) => false,
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete account: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final settings = context.watch<AppSettingsProvider>();
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (authProvider.isCheckingSession) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (authProvider.token == null || authProvider.token!.isEmpty) {
      return const Scaffold(
        body: Center(child: Text('Please log in to view your account')),
      );
    }

    final defaultUserName =
        authProvider.user?['name'] ??
        authProvider.user?['full_name'] ??
        'Skynova User';
    final userName = (_customDisplayName != null &&
            _customDisplayName!.trim().isNotEmpty)
        ? _customDisplayName!
        : defaultUserName.toString();
    final userEmail =
        authProvider.user?['email']?.toString() ?? 'No email available';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Account'),
      ),
      body: RefreshIndicator(
        onRefresh: () async => context.read<AuthProvider>().loadSession(),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF003580), Color(0xFF0A4DA3)],
                ),
                borderRadius: BorderRadius.circular(28),
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: _pickProfileImage,
                    child: Stack(
                      children: [
                        CircleAvatar(
                          radius: 34,
                          backgroundColor: Colors.white24,
                          backgroundImage: settings.profileImagePath != null
                              ? FileImage(File(settings.profileImagePath!))
                              : null,
                          child: settings.profileImagePath == null
                              ? const Icon(
                                  Icons.person,
                                  size: 34,
                                  color: Colors.white,
                                )
                              : null,
                        ),
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.camera_alt,
                              size: 16,
                              color: AppTheme.trustBlue,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          userName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          userEmail,
                          style: const TextStyle(color: Colors.white70),
                        ),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            const _ProfilePill(label: 'Travel watcher'),
                            _ProfilePill(
                              label: _dealAlertsEnabled
                                  ? 'Deal alerts on'
                                  : 'Deal alerts off',
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            Text(
              'Account settings',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 12),
            _SettingsGroup(
              children: [
                _SettingsTile(
                  icon: Icons.person_outline_rounded,
                  title: 'Personal information',
                  subtitle: 'Manage your account details',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const PersonalInformationPage(),
                      ),
                    );
                  },
                ),
                _SettingsTile(
                  icon: Icons.badge_outlined,
                  title: 'Display name',
                  subtitle: userName,
                  onTap: () => _editDisplayName(userName),
                ),
                _SettingsTile(
                  icon: Icons.palette_outlined,
                  title: 'Appearance',
                  subtitle: 'Theme, colors, and display style',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const AppearancePage(),
                      ),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Travel preferences',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 12),
            _SettingsGroup(
              children: [
                _SettingsTile(
                  icon: Icons.notifications_active_outlined,
                  title: 'Notifications',
                  subtitle: 'Price drops, new deals, and tracking updates',
                  onTap: _openNotificationsSettings,
                ),
                _SettingsTile(
                  icon: Icons.security_outlined,
                  title: 'Security',
                  subtitle: _sessionProtectionEnabled
                      ? 'Authentication and session protection enabled'
                      : 'Session protection disabled',
                  onTap: _openSecuritySettings,
                ),
                _SettingsTile(
                  icon: Icons.insights_outlined,
                  title: 'Saved search insights',
                  subtitle: _fareInsightsEnabled
                      ? 'Charts and historical prices appear on tracked routes'
                      : 'Saved search insights are limited',
                  onTap: _openInsightsSettings,
                ),
              ],
            ),
            const SizedBox(height: 22),
            OutlinedButton.icon(
              onPressed: _logout,
              icon: const Icon(Icons.logout_rounded),
              label: const Text('Log out'),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: _deleteAccount,
              icon: const Icon(Icons.delete_forever_rounded),
              label: const Text('Delete account'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                side: const BorderSide(color: Colors.red),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfilePill extends StatelessWidget {
  final String label;

  const _ProfilePill({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.16),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w700,
          fontSize: 12,
        ),
      ),
    );
  }
}

class _SettingsGroup extends StatelessWidget {
  final List<Widget> children;

  const _SettingsGroup({required this.children});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.cardBorder),
      ),
      child: Column(children: children),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final onSurface = theme.colorScheme.onSurface;
    final subtitleColor =
        theme.textTheme.bodyMedium?.color?.withOpacity(0.70) ??
            AppTheme.textMuted;
    final iconBg = theme.brightness == Brightness.dark
        ? const Color(0xFF162033)
        : const Color(0xFFEAF2FF);

    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: iconBg,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Icon(icon, color: AppTheme.trustBlue),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w700,
          color: onSurface,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(color: subtitleColor),
      ),
      trailing: Icon(
        Icons.chevron_right_rounded,
        color: onSurface,
      ),
      onTap: onTap,
    );
  }
}