// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

import '../../state/app_state.dart';
import '../../models/journal_entry.dart';
import '../../services/bible_service.dart';
import '../../widgets/responsive_page.dart';
import 'journal_entry_screen.dart';

class JournalScreen extends StatelessWidget {
  const JournalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final uid = app.auth.currentUser?.uid;

    if (uid == null) {
      return const Scaffold(
        body: Center(child: Text('Please sign in to view your journal.')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Journal')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          showDragHandle: true,
          builder: (_) => _NewEntrySheet(uid: uid),
        ),
        icon: const Icon(Icons.add),
        label: const Text('New'),
      ),
      body: ResponsivePage(
        maxContentWidth: 850,
        child: StreamBuilder<List<JournalEntry>>(
          stream: app.db.watchJournal(uid),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    'Journal error:\n${snapshot.error}',
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            }

            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final items = snapshot.data ?? <JournalEntry>[];

            if (items.isEmpty) {
              return const Center(child: Text('No entries yet. Start your first journal ✍️'));
            }

            return ListView.builder(
              itemCount: items.length,
              itemBuilder: (_, i) {
                final e = items[i];

                return Card(
                  child: ListTile(
                    title: Text(e.title.isEmpty ? 'Journal Entry' : e.title),
                    subtitle: Text(
                      '${e.date} • ${e.scriptureRef}\n${e.content}',
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => JournalEntryScreen(entry: e)),
                      );
                    },
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _NewEntrySheet extends StatefulWidget {
  final String uid;
  const _NewEntrySheet({required this.uid});

  @override
  State<_NewEntrySheet> createState() => _NewEntrySheetState();
}

class _NewEntrySheetState extends State<_NewEntrySheet> {
  final title = TextEditingController(text: 'Today');
  final content = TextEditingController();
  String mood = 'peaceful';

  final scriptureRef = TextEditingController(text: 'Philippians 4:6-7');
  String scriptureText = '';
  bool fetching = false;
  bool saving = false;
  String? error;

  @override
  void dispose() {
    title.dispose();
    content.dispose();
    scriptureRef.dispose();
    super.dispose();
  }

  Future<void> fetchScripture() async {
    setState(() {
      fetching = true;
      error = null;
    });

    try {
      final v = await BibleService.instance.fetchVerse(scriptureRef.text.trim());
      scriptureText = v.text;
    } catch (_) {
      scriptureText = '';
      error = 'Could not fetch scripture. Check reference.';
    } finally {
      if (mounted) setState(() => fetching = false);
    }
  }

  Future<void> save() async {
    if (content.text.trim().isEmpty) {
      setState(() => error = 'Write something first ✍️');
      return;
    }

    setState(() {
      saving = true;
      error = null;
    });

    try {
      if (scriptureText.trim().isEmpty) {
        await fetchScripture();
      }

      final app = context.read<AppState>();
      final id = const Uuid().v4();
      final dateKey = DateFormat('yyyy-MM-dd').format(DateTime.now());

      final entry = JournalEntry(
        id: id,
        uid: widget.uid,
        date: dateKey,
        mood: mood,
        title: title.text.trim(),
        content: content.text.trim(),
        scriptureRef: scriptureRef.text.trim(),
        scriptureText: scriptureText,
        createdAt: Timestamp.now(),
      );

      await app.db.addJournalEntry(entry);

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
          const Text(
            'New Journal Entry',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 10),

          TextField(controller: title, decoration: const InputDecoration(labelText: 'Title')),
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
            decoration: InputDecoration(
              labelText: 'Scripture reference',
              suffixIcon: IconButton(
                icon: fetching
                    ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.search),
                onPressed: fetching ? null : fetchScripture,
              ),
            ),
          ),

          if (scriptureText.isNotEmpty) ...[
            const SizedBox(height: 10),
            Card(child: Padding(padding: const EdgeInsets.all(12), child: Text(scriptureText))),
          ],

          const SizedBox(height: 10),

          TextField(
            controller: content,
            maxLines: 6,
            decoration: const InputDecoration(labelText: 'Reflection'),
          ),

          if (error != null) ...[
            const SizedBox(height: 10),
            Text(error!, style: const TextStyle(color: Colors.red)),
          ],

          const SizedBox(height: 14),

          FilledButton(
            onPressed: saving ? null : save,
            child: Text(saving ? 'Saving...' : 'Save'),
          ),
        ],
      ),
    );
  }
}