import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';

import '../../services/bible_api_service.dart';
import '../../widgets/responsive_page.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  String _firstName(String fullName) {
    final trimmed = fullName.trim();
    if (trimmed.isEmpty) return '';
    final parts = trimmed.split(RegExp(r'\s+'));
    return parts.isNotEmpty ? parts.first : trimmed;
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final rawName = (user?.displayName ?? '').trim();
    final fallbackFromEmail = (user?.email ?? '').split('@').first.trim();
    final name = _firstName (
      rawName.isNotEmpty ? rawName : (fallbackFromEmail.isNotEmpty ? fallbackFromEmail : 'Friend')
    );

    final t = Theme.of(context).textTheme;
    final bible = BibleApiService();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Scrolla'),
        actions: [
          IconButton(
            icon: const Icon(Icons.menu_book),
            onPressed: () => context.pushNamed('Bible'),
          )
        ],
      ),
      body: ResponsivePage(
        maxContentWidth: 900,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isTablet = constraints.maxWidth >= 800;

            if (!isTablet) {
              return ListView(
                children: [
                  _HeaderCard(name: name, greeting: _greeting()),
                  const SizedBox(height:16),
                  Text('Verse of the Day', style: t.titleMedium),
                  const SizedBox(height: 8),
                  _VerseCard(bible: bible),
                  const SizedBox(height: 16),
                  Text('Quick Actions', style: t.titleMedium),
                  const SizedBox(height: 8),
                  const _QuickActionCard(),
                ],
              );
            }

            return ListView(
              children: [
                _HeaderCard(name: name, greeting: _greeting()),
                const SizedBox(height:16),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 3,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Verse of the Day', style: t.titleMedium),
                          const SizedBox(height: 8),
                          _VerseCard(bible: bible),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Expanded(
                      flex: 2,
                      child: _QuickActionsSection(),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _HeaderCard extends StatelessWidget {
  final String name;
  final String greeting;

  const _HeaderCard({
    required this.name,
    required this.greeting,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$greeting, $name',
              style: t.titleSmall?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 6),
            Text(
              'Focus on what matters today',
              style: t.bodyMedium,
            ),
            const SizedBox(height: 10),
            Text(
              'Focus, Faith & Fellowship',
              style: t.bodySmall?.copyWith(fontWeight: FontWeight.w600, fontStyle: FontStyle.italic),
            )
          ],
        ),
      ),
    );
  }
}

class _VerseCard extends StatelessWidget {
  final BibleApiService bible;

  const _VerseCard({required this.bible});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<VerseResult>(
      future: bible.getVerseOfDay(),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Row(
                children: [
                  SizedBox(width: 20, height: 20, child: CircularProgressIndicator()),
                  SizedBox(width: 12),
                  Expanded(child: Text('Loading verse...')),
                ]
             ),
           ),
          );
        }

        if (snap.hasError) {
          return const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Text('Failed to load verse. Please try again later.'),
              ),
          );
        } 
        
        final v = snap.data!;
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  v.reference,
                  style:const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 8),
                Text(
                  v.text,
                  style: const TextStyle(fontSize: 16, height: 1.35),
                ),
                if ((v.translation ?? '').trim().isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    '- ${v.translation}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
                const SizedBox(height: 12),
                FilledButton.tonalIcon(
                  onPressed: () => context.pushNamed('Bible'),
                  icon: const Icon(Icons.menu_book),
                  label: const Text('Read Bible'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _QuickActionsSection extends StatelessWidget {
  const _QuickActionsSection();

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Quick Actions', style: t.titleMedium),
        const SizedBox(height: 8),
        const _QuickActionsSection(),
      ],
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  const _QuickActionCard();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Wrap(
          spacing: 10,
          runSpacing: 12,
          children: [
            FilledButton.tonalIcon(
              onPressed: () {},
              icon: const Icon(Icons.edit),
              label: const Text('Journal'),
            ),
            OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.checklist),
              label: const Text('Focus'),
            ),
            OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.volunteer_activism),
              label: const Text('Prayer'),
            ),
            OutlinedButton.icon(
              onPressed: () => context.pushNamed('bible'),
              icon: const Icon(Icons.menu_book),
              label: const Text('Bible'),
            ),
          ],
        ),
      ),
    );
  }
}