import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/post.dart';
import '../state/app_state.dart';

class PostTile extends StatelessWidget {
  final Post post;
  final String uid;
  final bool groupScoped;

  const PostTile({super.key, required this.post, required this.uid, this.groupScoped = false});

  @override
  Widget build(BuildContext context) {
    final app = context.read<AppState>();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(child: Text(post.authorName.isEmpty ? 'U' : post.authorName.characters.first)),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    post.authorName,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            if (post.caption.isNotEmpty) Text(post.caption),
            const SizedBox(height: 10),
            Row(
              children: [
                StreamBuilder<bool>(
                  stream: groupScoped ? const Stream<bool>.empty() : app.db.watchLiked(post.id, uid),
                  builder: (_, snap) {
                    final liked = snap.data ?? false;
                    return IconButton(
                      icon: Icon(liked ? Icons.favorite : Icons.favorite_border),
                      onPressed: groupScoped ? null : () => app.db.toggleLike(postId: post.id, uid: uid),
                    );
                  },
                ),
                Text('${post.likeCount}'),
                const SizedBox(width: 10),
                const Icon(Icons.mode_comment_outlined, size: 20),
                const SizedBox(width: 6),
                Text('${post.commentCount}'),
                const Spacer(),
                Text(
                  _prettyTime(post.createdAt.toDate()),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  static String _prettyTime(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 1) return 'now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m';
    if (diff.inHours < 24) return '${diff.inHours}h';
    return '${diff.inDays}d';
  }
}