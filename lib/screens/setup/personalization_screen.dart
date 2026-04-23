// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../../state/app_state.dart';
import '../../services/notification_service.dart';

class PersonalizationScreen extends StatefulWidget {
  const PersonalizationScreen({super.key});

  @override
  State<PersonalizationScreen> createState() => _PersonalizationScreenState();
}

class _PersonalizationScreenState extends State<PersonalizationScreen> {
  String focus = ''; // must be set
  final Set<String> selected = {};

  TimeOfDay devotion = const TimeOfDay(hour: 8, minute: 0);
  TimeOfDay study = const TimeOfDay(hour: 16, minute: 0);
  TimeOfDay prayer = const TimeOfDay(hour: 21, minute: 0);

  bool saving = false;
  String? error;

  String fmt(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  Future<void> pickTime({
    required TimeOfDay current,
    required void Function(TimeOfDay) onPicked,
  }) async {
    final t = await showTimePicker(context: context, initialTime: current);
    if (t != null) onPicked(t);
  }

  Future<void> finish() async {
    if (saving) return;

    // ✅ validate
    if (focus.trim().isEmpty) {
      setState(() => error = 'Please choose your focus to continue.');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Choose a focus first.')),
      );
      return;
    }

    setState(() {
      saving = true;
      error = null;
    });

    final app = context.read<AppState>();
    final user = app.auth.currentUser;

    if (user == null) {
      setState(() {
        saving = false;
        error = 'You are not signed in. Please sign in again.';
      });
      return;
    }

    final reminders = <String, String>{
      'devotion': fmt(devotion),
      'study': fmt(study),
      'prayer': fmt(prayer),
    };

    try {
      // 1) Save setup to Firestore
      await app.db.updateUserSetup(
        user.uid,
        focus: focus,
        interests: selected.toList(),
        reminders: reminders.map((k, v) => MapEntry(k, v.toString())), // Firestore expects Map<String,String> in your service
      );

      // 2) Update local user immediately (stops router loop)
      app.applySetupLocal(
        focus: focus,
        interests: selected.toList(),
        reminders: reminders,
      );

      // 3) Try notifications, but don’t block navigation if it fails
      try {
        await NotificationService.instance.scheduleDaily(
          id: 1,
          title: 'Scrolla Devotion',
          body: 'Time to reflect and reset your focus.',
          hour: devotion.hour,
          minute: devotion.minute,
        );
        await NotificationService.instance.scheduleDaily(
          id: 2,
          title: 'Scrolla Study Focus',
          body: 'Quick check-in: what’s your top task?',
          hour: study.hour,
          minute: study.minute,
        );
        await NotificationService.instance.scheduleDaily(
          id: 3,
          title: 'Scrolla Prayer',
          body: 'A moment to pray and breathe.',
          hour: prayer.hour,
          minute: prayer.minute,
        );
      } catch (_) {
        // ignore scheduling failures for now
      }

      // 4) Go to app
      if (mounted) context.go('/app');
    } catch (e) {
      setState(() => error = e.toString());
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Finish failed: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    Widget chip(String label) {
      final isOn = selected.contains(label);
      return FilterChip(
        label: Text(label),
        selected: isOn,
        onSelected: (v) => setState(() {
          if (v) {
            selected.add(label);
          } else {
            selected.remove(label);
          }
        }),
      );
    }

    Widget timeRow(String label, TimeOfDay value, void Function() onTap) {
      return Card(
        child: ListTile(
          title: Text(label),
          subtitle: Text(fmt(value)),
          trailing: const Icon(Icons.schedule),
          onTap: saving ? null : onTap,
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Personalization')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Make Scrolla yours', style: t.titleLarge),
          const SizedBox(height: 6),
          Text('This helps personalize your feed, tools, and reminders.', style: t.bodyMedium),
          const SizedBox(height: 16),

          Text('1) Choose your focus', style: t.titleMedium),
          const SizedBox(height: 8),
          Card(
            child: Column(
              children: [
                RadioListTile<String>(
                  value: 'Grow my faith',
                  groupValue: focus,
                  title: const Text('Grow my faith'),
                  onChanged: saving ? null : (v) => setState(() => focus = v ?? ''),
                ),
                RadioListTile<String>(
                  value: 'Be more productive',
                  groupValue: focus,
                  title: const Text('Be more productive'),
                  onChanged: saving ? null : (v) => setState(() => focus = v ?? ''),
                ),
                RadioListTile<String>(
                  value: 'Balance both',
                  groupValue: focus,
                  title: const Text('Balance both'),
                  onChanged: saving ? null : (v) => setState(() => focus = v ?? ''),
                ),
              ],
            ),
          ),

          const SizedBox(height: 18),
          Text('2) Daily reminder times', style: t.titleMedium),
          const SizedBox(height: 8),
          timeRow('Morning devotion', devotion, () => pickTime(current: devotion, onPicked: (v) => setState(() => devotion = v))),
          timeRow('Study focus', study, () => pickTime(current: study, onPicked: (v) => setState(() => study = v))),
          timeRow('Prayer', prayer, () => pickTime(current: prayer, onPicked: (v) => setState(() => prayer = v))),

          const SizedBox(height: 18),
          Text('3) Interests', style: t.titleMedium),
          const SizedBox(height: 10),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              chip('Bible study'),
              chip('Journaling'),
              chip('Student life'),
              chip('Productivity'),
              chip('Prayer groups'),
            ],
          ),

          if (error != null) ...[
            const SizedBox(height: 14),
            Text(error!, style: const TextStyle(color: Colors.red)),
          ],

          const SizedBox(height: 18),
          FilledButton(
            onPressed: saving ? null : finish,
            child: Text(saving ? 'Finishing...' : 'Finish'),
          ),
        ],
      ),
    );
  }
}