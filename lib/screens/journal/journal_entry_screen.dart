// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../state/app_state.dart';
import '../../models/journal_entry.dart';

class JournalEntryScreen extends StatefulWidget {
  final JournalEntry entry;
  const JournalEntryScreen({super.key, required this.entry});

  @override
  State<JournalEntryScreen> createState() => _JournalEntryScreenState();
}

class _JournalEntryScreenState extends State<JournalEntryScreen> {
  late final title = TextEditingController(text: widget.entry.title);
  late final content = TextEditingController(text: widget.entry.content);
  late final scriptureRef = TextEditingController(text: widget.entry.scriptureRef);
  late String mood = widget.entry.mood;

  bool saving = false;
  String? error;

  @override
  void dispose() {
    title.dispose();
    content.dispose();
    scriptureRef.dispose();
    super.dispose();
  }

  Future<void> save() async {
    setState(() {
      saving = true;
      error = null;
    });

    try {
      final app = context.read<AppState>();

      final updated = JournalEntry(
        id: widget.entry.id,
        uid: widget.entry.uid,
        date: widget.entry.date.isEmpty
            ? DateFormat('yyyy-MM-dd').format(DateTime.now())
            : widget.entry.date,
        mood: mood,
        title: title.text.trim(),
        content: content.text.trim(),
        scriptureRef: scriptureRef.text.trim(),
        scriptureText: widget.entry.scriptureText, // keep as-is for MVP
        createdAt: widget.entry.createdAt, // keep original
      );

      await app.db.updateJournalEntry(updated);

      if (mounted) Navigator.pop(context);
    } catch (e) {
      setState(() => error = e.toString());
    } finally {
      if (mounted) setState(() => saving = false);
    }
  }

  Future<void> delete() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete entry?'),
        content: const Text('This cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete')),
        ],
      ),
    );

    if (ok != true) return;

    try {
      final app = context.read<AppState>();
      await app.db.deleteJournalEntry(widget.entry.id);
      if (mounted) Navigator.pop(context);
    } catch (e) {
      setState(() => error = e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Journal Entry'),
        actions: [
          IconButton(
            tooltip: 'Delete',
            icon: const Icon(Icons.delete_outline),
            onPressed: delete,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(widget.entry.date, style: t.bodySmall),
          const SizedBox(height: 10),

          TextField(
            controller: title,
            decoration: const InputDecoration(labelText: 'Title'),
          ),
          const SizedBox(height: 10),

          DropdownButtonFormField<String>(
            initialValue: mood,
            items: const [
              DropdownMenuItem(value: 'peaceful', child: Text('Peaceful')),
              DropdownMenuItem(value: 'okay', child: Text('Okay')),
              DropdownMenuItem(value: 'stressed', child: Text('Stressed')),
            ],
            onChanged: (v) => setState(() => mood = v ?? 'peaceful'),
            decoration: const InputDecoration(labelText: 'Mood / Faith'),
          ),
          const SizedBox(height: 10),

          TextField(
            controller: scriptureRef,
            decoration: const InputDecoration(labelText: 'Scripture reference'),
          ),
          const SizedBox(height: 10),

          if (widget.entry.scriptureText.isNotEmpty) ...[
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Text(widget.entry.scriptureText),
              ),
            ),
            const SizedBox(height: 10),
          ],

          TextField(
            controller: content,
            maxLines: 10,
            decoration: const InputDecoration(labelText: 'Reflection'),
          ),

          if (error != null) ...[
            const SizedBox(height: 10),
            Text(error!, style: const TextStyle(color: Colors.red)),
          ],

          const SizedBox(height: 14),
          FilledButton(
            onPressed: saving ? null : save,
            child: Text(saving ? 'Saving...' : 'Save changes'),
          ),
        ],
      ),
    );
  }
}