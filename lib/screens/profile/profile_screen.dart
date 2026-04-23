import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../../state/app_state.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final me = app.me;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(onPressed: () => context.go('/settings'), icon: const Icon(Icons.settings_rounded)),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              child: ListTile(
                leading: CircleAvatar(child: Text((me?.displayName ?? 'U').characters.first)),
                title: Text(me?.displayName ?? 'User'),
                subtitle: Text(me?.email ?? ''),
              ),
            ),
            const SizedBox(height: 10),
            Card(
              child: ListTile(
                title: const Text('Faith focus'),
                subtitle: Text(me?.focus ?? 'Not set'),
              ),
            ),
            Card(
              child: ListTile(
                title: const Text('Streak stats'),
                subtitle: Text('Streak: ${me?.streak ?? 0} • Journals: ${me?.journalCount ?? 0}'),
              ),
            ),
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: () async => app.auth.signOut(),
              child: const Text('Log out'),
            ),
          ],
        ),
      ),
    );
  }
}