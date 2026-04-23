import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';

import '../../state/app_state.dart';
import '../../models/group.dart';

class GroupsScreen extends StatelessWidget {
  const GroupsScreen({super.key});

  Future<void> _createGroup(BuildContext context) async {
    final name = TextEditingController();
    final desc = TextEditingController();
    bool isPrivate = false;

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Create group'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: name, decoration: const InputDecoration(labelText: 'Name')),
            TextField(controller: desc, decoration: const InputDecoration(labelText: 'Description')),
            StatefulBuilder(
              builder: (context, setState) => SwitchListTile(
                value: isPrivate,
                onChanged: (v) => setState(() => isPrivate = v),
                title: const Text('Private'),
              ),
            )
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          FilledButton(
            onPressed: () async {
              final app = context.read<AppState>();
              final uid = app.auth.currentUser!.uid;
              final g = Group(
                id: const Uuid().v4(),
                name: name.text.trim(),
                description: desc.text.trim(),
                ownerId: uid,
                createdAt: Timestamp.now(),
                memberCount: 1,
                isPrivate: isPrivate,
              );
              await app.db.createGroup(g, uid);
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final uid = app.auth.currentUser!.uid;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _createGroup(context),
                  icon: const Icon(Icons.add),
                  label: const Text('Create group'),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: StreamBuilder(
            stream: app.db.watchGroups(),
            builder: (_, snap) {
              final groups = snap.data ?? [];
              if (groups.isEmpty) return const Center(child: Text('No groups yet. Create the first 🤝'));
              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: groups.length,
                itemBuilder: (_, i) {
                  final g = groups[i];
                  return Card(
                    child: ListTile(
                      title: Text(g.name),
                      subtitle: Text('${g.memberCount} members • ${g.isPrivate ? "Private" : "Public"}\n${g.description}'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () async {
                        await app.db.joinGroup(g.id, uid);
                        if (context.mounted) context.push('/groups/${g.id}');
                      },
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}