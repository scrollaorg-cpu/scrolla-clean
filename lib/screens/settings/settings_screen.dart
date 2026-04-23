// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../../state/app_state.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final t = Theme.of(context).textTheme;

    String modeLabel(ThemeMode m) {
      switch (m) {
        case ThemeMode.light:
          return 'light';
        case ThemeMode.dark:
          return 'dark';
        case ThemeMode.system:
        return 'system';
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),

        // ✅ Always show back button
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            } else {
              context.go('/app');
            }
          },
        ),
      ),

      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ===== Appearance =====
          Text('Appearance', style: t.titleMedium),
          const SizedBox(height: 8),

          Card(
            child: ListTile(
              title: const Text('Theme'),
              subtitle: Text('Current: ${modeLabel(app.themeMode)}'),
              trailing: DropdownButton<String>(
                value: modeLabel(app.themeMode),
                underline: const SizedBox(),
                items: const [
                  DropdownMenuItem(value: 'system', child: Text('System')),
                  DropdownMenuItem(value: 'light', child: Text('Light')),
                  DropdownMenuItem(value: 'dark', child: Text('Dark')),
                ],
                onChanged: (v) {
                  if (v != null) {
                    app.setThemeMode(v);
                  }
                },
              ),
            ),
          ),

          const SizedBox(height: 20),

          // ===== Notifications (placeholder for now) =====
          Text('Notifications', style: t.titleMedium),
          const SizedBox(height: 8),

          const Card(
            child: ListTile(
              title: Text('Reminder times'),
              subtitle: Text('Manage devotion, study, and prayer reminders'),
            ),
          ),

          const SizedBox(height: 20),

          // ===== Account =====
          Text('Account', style: t.titleMedium),
          const SizedBox(height: 8),

          Card(
            child: ListTile(
              title: const Text('Log out'),
              leading: const Icon(Icons.logout),
              onTap: () async {
                final app = context.read<AppState>();
                await app.auth.signOut();

                if (context.mounted) {
                  context.go('/onboarding');
                }
              },
            ),
          ),

          const SizedBox(height: 24),

          Center(
            child: Text(
              'Scrolla v1.0',
              style: t.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          ),
        ],
      ),
    );
  }
}