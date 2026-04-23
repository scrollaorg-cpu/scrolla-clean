import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';

import '../../state/app_state.dart';
import '../../models/post.dart';

class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({super.key});

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final caption = TextEditingController();
  bool loading = false;

  @override
  void dispose() {
    caption.dispose();
    super.dispose();
  }

  Future<void> post() async {
    setState(() => loading = true);
    try {
      final app = context.read<AppState>();
      final me = app.me!;
      final p = Post(
        id: const Uuid().v4(),
        authorId: me.uid,
        authorName: me.displayName,
        authorPhoto: me.photoUrl ?? '',
        caption: caption.text.trim(),
        imageUrl: '', // optional later
        createdAt: Timestamp.now(),
        likeCount: 0,
        commentCount: 0,
        groupId: null,
      );
      await app.db.createPost(p);
      if (mounted) context.pop();
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create post')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              TextField(
                controller: caption,
                maxLines: 6,
                decoration: const InputDecoration(labelText: 'Share something uplifting...'),
              ),
              const Spacer(),
              FilledButton(onPressed: loading ? null : post, child: Text(loading ? 'Posting...' : 'Post')),
            ],
          ),
        ),
      ),
    );
  }
}