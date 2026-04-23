import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../state/app_state.dart';
import '../../models/post.dart';
import '../../widgets/post_tile.dart';

class GroupDetailScreen extends StatelessWidget {
  final String groupId;
  const GroupDetailScreen({super.key, required this.groupId});

  Future<void> _createGroupPost(BuildContext context) async {
    final caption = TextEditingController();
    await showModalBottomSheet(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 10,
          bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Post to group', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            const SizedBox(height: 10),
            TextField(controller: caption, maxLines: 5, decoration: const InputDecoration(labelText: 'Share...')),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: () async {
                final app = context.read<AppState>();
                final me = app.me!;
                final p = Post(
                  id: const Uuid().v4(),
                  authorId: me.uid,
                  authorName: me.displayName,
                  authorPhoto: me.photoUrl ?? '',
                  caption: caption.text.trim(),
                  imageUrl: '',
                  createdAt: Timestamp.now(),
                  likeCount: 0,
                  commentCount: 0,
                  groupId: groupId,
                );
                await app.db.createGroupPost(groupId, p);
                if (context.mounted) Navigator.pop(context);
              },
              child: const Text('Post'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final uid = app.auth.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Group'),
        actions: [
          IconButton(onPressed: () => _createGroupPost(context), icon: const Icon(Icons.add_box_outlined)),
        ],
      ),
      body: StreamBuilder(
        stream: app.db.watchGroupFeed(groupId),
        builder: (_, snap) {
          final posts = snap.data ?? [];
          if (posts.isEmpty) return const Center(child: Text('No posts yet. Start the conversation 🌿'));
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: posts.length,
            itemBuilder: (_, i) => PostTile(post: posts[i], uid: uid, groupScoped: true),
          );
        },
      ),
    );
  }
}