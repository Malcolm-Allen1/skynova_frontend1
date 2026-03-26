import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/app_settings_provider.dart';
import '../../providers/auth_provider.dart';

class PersonalInformationPage extends StatefulWidget {
  const PersonalInformationPage({super.key});

  @override
  State<PersonalInformationPage> createState() =>
      _PersonalInformationPageState();
}

class _PersonalInformationPageState extends State<PersonalInformationPage> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;

  late String _country;
  bool _isSaving = false;

  final List<String> _countries = const [
    'Jamaica',
    'United States',
    'Canada',
    'United Kingdom',
    'Trinidad and Tobago',
    'Barbados',
    'Bahamas',
  ];

  @override
  void initState() {
    super.initState();

    final settings = context.read<AppSettingsProvider>();
    final authProvider = context.read<AuthProvider>();
    final user = authProvider.user ?? {};

    _nameController = TextEditingController(
      text: settings.fullName.isNotEmpty
          ? settings.fullName
          : (user['name'] ?? user['full_name'] ?? '').toString(),
    );

    _phoneController = TextEditingController(
      text: settings.phoneNumber,
    );

    _country = settings.country;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Widget _buildInputCard({
    required IconData icon,
    required String label,
    required TextEditingController controller,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        validator: validator,
        style: const TextStyle(fontSize: 14),
        decoration: InputDecoration(
          prefixIcon: Icon(icon, size: 20),
          labelText: label,
          border: InputBorder.none,
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildCountryCard() {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: ListTile(
        dense: true,
        leading: const Icon(Icons.public, size: 20),
        title: const Text(
          'Country / Location',
          style: TextStyle(fontSize: 14),
        ),
        subtitle: Text(
          _country,
          style: const TextStyle(fontSize: 13),
        ),
        trailing: const Icon(Icons.keyboard_arrow_down, size: 18),
        onTap: () async {
          final selected = await showModalBottomSheet<String>(
            context: context,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            builder: (_) {
              return SafeArea(
                child: ListView(
                  shrinkWrap: true,
                  children: _countries
                      .map(
                        (country) => ListTile(
                          title: Text(country),
                          onTap: () => Navigator.pop(context, country),
                        ),
                      )
                      .toList(),
                ),
              );
            },
          );

          if (selected != null) {
            setState(() {
              _country = selected;
            });
          }
        },
      ),
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSaving = true;
    });

    try {
      await context.read<AppSettingsProvider>().savePersonalInfo(
            fullName: _nameController.text.trim(),
            phoneNumber: _phoneController.text.trim(),
            country: _country,
          );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Personal information saved')),
      );

      _nameController.clear();
      _phoneController.clear();

      setState(() {
        _country = 'Jamaica';
      });
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<AppSettingsProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Personal Information'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text(
              'Update your personal details',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  _buildInputCard(
                    icon: Icons.person_outline,
                    label: 'Full Name',
                    controller: _nameController,
                    validator: (value) {
                      final text = value?.trim() ?? '';
                      if (text.isEmpty) return 'Enter your full name';
                      if (text.length < 2) return 'Name is too short';
                      return null;
                    },
                  ),
                  _buildInputCard(
                    icon: Icons.phone_outlined,
                    label: 'Phone Number',
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    validator: (value) {
                      final text = value?.trim() ?? '';
                      if (text.isEmpty) return 'Enter your phone number';
                      return null;
                    },
                  ),
                  _buildCountryCard(),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isSaving ? null : _save,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: _isSaving
                          ? const SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Save Changes'),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Saved Information',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 14),
                  _SavedInfoRow(
                    icon: Icons.person_outline,
                    label: 'Full Name',
                    value: settings.fullName.isNotEmpty
                        ? settings.fullName
                        : 'Not added',
                  ),
                  const SizedBox(height: 12),
                  _SavedInfoRow(
                    icon: Icons.phone_outlined,
                    label: 'Phone Number',
                    value: settings.phoneNumber.isNotEmpty
                        ? settings.phoneNumber
                        : 'Not added',
                  ),
                  const SizedBox(height: 12),
                  _SavedInfoRow(
                    icon: Icons.public,
                    label: 'Country / Location',
                    value: settings.country.isNotEmpty
                        ? settings.country
                        : 'Not added',
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

class _SavedInfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _SavedInfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: TextStyle(
              fontSize: 13,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.75),
            ),
          ),
        ),
      ],
    );
  }
}