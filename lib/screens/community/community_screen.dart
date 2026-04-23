import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../../state/app_state.dart';
import '../../widgets/post_tile.dart';
import 'groups_screen.dart';

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> {
  int tab = 0;

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final uid = app.auth.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Community'),
        actions: [
          IconButton(onPressed: () => context.push('/create-post'), icon: const Icon(Icons.add_box_outlined)),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 6),
          SegmentedButton<int>(
            segments: const [
              ButtonSegment(value: 0, label: Text('Feed')),
              ButtonSegment(value: 1, label: Text('Groups')),
            ],
            selected: {tab},
            onSelectionChanged: (s) => setState(() => tab = s.first),
          ),
          const SizedBox(height: 6),
          Expanded(
            child: tab == 0
                ? StreamBuilder(
                    stream: app.db.watchFeed(),
                    builder: (_, snap) {
                      final posts = snap.data ?? [];
                      if (posts.isEmpty) return const Center(child: Text('No posts yet. Be the first 🌿'));
                      return ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: posts.length,
                        itemBuilder: (_, i) => PostTile(post: posts[i], uid: uid),
                      );
                    },
                  )
                : const GroupsScreen(),
          ),
        ],
      ),
    );
  }
}