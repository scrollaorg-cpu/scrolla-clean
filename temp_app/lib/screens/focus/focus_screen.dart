import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';

import '../../models/task_item.dart';
import '../../widgets/responsive_page.dart';

class FocusScreen extends StatelessWidget {
  const FocusScreen({super.key});

  String _todayKey() {
    final now = DateTime.now();
    final y = now.year.toString().padLeft(4, '0');
    final m = now.month.toString().padLeft(2, '0');
    final d = now.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  Stream<List<TaskItem>> _watchTasksForDate(String uid, String dateKey) {
    return FirebaseFirestore.instance
        .collection('tasks')
        .where('uid', isEqualTo: uid)
        .where('date', isEqualTo: dateKey)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((s) => s.docs
            .map((d) => TaskItem.fromDoc(d as DocumentSnapshot<Map<String, dynamic>>))
            .toList());
  }

  Future<void> _toggleTaskDone(String taskId, bool done) {
    return FirebaseFirestore.instance.collection('tasks').doc(taskId).update({'done': done});
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
    if (uid.isEmpty) {
      return const Scaffold(
        body: Center(child: Text('Please sign in to view Focus.')),
      );
    }

    final todayKey = _todayKey();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Focus'),
        actions: [
          IconButton(
            tooltip: 'Add task',
            icon: const Icon(Icons.add),
            onPressed: () => showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              showDragHandle: true,
              builder: (_) => _AddTaskSheet(uid: uid, dateKey: todayKey),
            ),
          ),
        ],
      ),
      body: ResponsivePage(
        maxContentWidth: 900,
        child: ListView(
          children: [
            _DailyFocusCard(dateKey: todayKey),

            const SizedBox(height: 14),
            Text('Today’s Tasks', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),

            StreamBuilder<List<TaskItem>>(
              stream: _watchTasksForDate(uid, todayKey),
              builder: (context, snap) {
                if (snap.hasError) {
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Text('Tasks error:\n${snap.error}'),
                    ),
                  );
                }

                if (!snap.hasData) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(12),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }

                final tasks = snap.data ?? <TaskItem>[];

                if (tasks.isEmpty) {
                  return const Card(
                    child: ListTile(
                      title: Text('No tasks yet'),
                      subtitle: Text('Add your top task for today ✅'),
                      trailing: Icon(Icons.checklist),
                    ),
                  );
                }

                return Column(
                  children: tasks.map((t) {
                    return Card(
                      child: CheckboxListTile(
                        value: t.done,
                        title: Text(t.title),
                        subtitle: Text('Priority: ${t.priority}'),
                        onChanged: (v) async {
                          if (v == null) return;
                          await _toggleTaskDone(t.id, v);
                        },
                      ),
                    );
                  }).toList(),
                );
              },
            ),

            const SizedBox(height: 20),

            Card(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    FilledButton.tonalIcon(
                      onPressed: () => showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        showDragHandle: true,
                        builder: (_) => _AddTaskSheet(uid: uid, dateKey: todayKey),
                      ),
                      icon: const Icon(Icons.checklist),
                      label: const Text('Add task'),
                    ),
                    OutlinedButton.icon(
                      onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Hook this to Bible screen 📖')),
                      ),
                      icon: const Icon(Icons.menu_book),
                      label: const Text('Bible'),
                    ),
                    OutlinedButton.icon(
                      onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Hook this to Community 🤝')),
                      ),
                      icon: const Icon(Icons.people),
                      label: const Text('Community'),
                    ),
                    OutlinedButton.icon(
                      onPressed: () => context.go('/setup'),
                      icon: const Icon(Icons.tune),
                      label: const Text('Personalization'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          showDragHandle: true,
          builder: (_) => _AddTaskSheet(uid: uid, dateKey: todayKey),
        ),
        icon: const Icon(Icons.add),
        label: const Text('New Task'),
      ),
    );
  }
}

class _DailyFocusCard extends StatelessWidget {
  final String dateKey;
  const _DailyFocusCard({required this.dateKey});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    const verseRef = 'Philippians 4:6–7';
    const verseText =
        'Do not be anxious about anything, but in every situation, by prayer and petition...';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Daily Focus', style: t.titleMedium),
            const SizedBox(height: 6),
            Text(dateKey, style: t.bodySmall),
            const SizedBox(height: 12),
            Text(verseRef, style: t.labelLarge),
            const SizedBox(height: 6),
            Text(
              verseText,
              style: t.bodyMedium,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class _AddTaskSheet extends StatefulWidget {
  final String uid;
  final String dateKey;

  const _AddTaskSheet({required this.uid, required this.dateKey});

  @override
  State<_AddTaskSheet> createState() => _AddTaskSheetState();
}

class _AddTaskSheetState extends State<_AddTaskSheet> {
  final title = TextEditingController();
  String priority = 'med';
  bool saving = false;
  String? error;

  @override
  void dispose() {
    title.dispose();
    super.dispose();
  }

  Future<void> save() async {
    if (title.text.trim().isEmpty) {
      setState(() => error = 'Add a task title.');
      return;
    }

    setState(() {
      saving = true;
      error = null;
    });

    try {
      final id = const Uuid().v4();
      final task = TaskItem(
        id: id,
        uid: widget.uid,
        date: widget.dateKey,
        title: title.text.trim(),
        priority: priority,
        done: false,
        createdAt: Timestamp.now(),
      );

      await FirebaseFirestore.instance.collection('tasks').doc(task.id).set(task.toMap());

      if (mounted) Navigator.pop(context);
    } catch (e) {
      setState(() => error = e.toString());
    } finally {
      if (mounted) setState(() => saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(left: 16, right: 16, top: 10, bottom: bottom + 16),
      child: ListView(
        shrinkWrap: true,
        children: [
          const Text('New Task', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          const SizedBox(height: 10),
          TextField(
            controller: title,
            textInputAction: TextInputAction.done,
            decoration: const InputDecoration(labelText: 'Task title'),
          ),
          const SizedBox(height: 10),
          DropdownButtonFormField<String>(
            initialValue: priority,
            items: const [
              DropdownMenuItem(value: 'low', child: Text('Low')),
              DropdownMenuItem(value: 'med', child: Text('Medium')),
              DropdownMenuItem(value: 'high', child: Text('High')),
            ],
            onChanged: (v) => setState(() => priority = v ?? 'med'),
            decoration: const InputDecoration(labelText: 'Priority'),
          ),
          if (error != null) ...[
            const SizedBox(height: 10),
            Text(error!, style: const TextStyle(color: Colors.red)),
          ],
          const SizedBox(height: 14),
          FilledButton(
            onPressed: saving ? null : save,
            child: Text(saving ? 'Saving...' : 'Add task'),
          ),
        ],
      ),
    );
  }
}