import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../auth/login_page.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.read<AuthProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Card(
              child: ListTile(
                leading: const CircleAvatar(child: Icon(Icons.person)),
                title: const Text('SkyNova User'),
                subtitle: const Text('Session active'),
                trailing: const Icon(Icons.verified_user),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () async {
                  await authProvider.logout();
                  if (!context.mounted) return;
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginPage()),
                    (_) => false,
                  );
                },
                icon: const Icon(Icons.logout),
                label: const Text('Logout'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}