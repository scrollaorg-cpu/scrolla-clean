// ignore_for_file: library_prefixes, camel_case_types

import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/app_user.dart';
import '../models/post.dart';
import '../models/group.dart';
import '../models/journal_entry.dart';
import '../models/task_item.dart';
import '../models/prayer_item.dart';

class FirestoreService {
  final _db = FirebaseFirestore.instance;

  // USERS
  Future<AppUser> ensureUser(String uid, String name, String email) async {
    final ref = _db.collection('users').doc(uid);
    final snap = await ref.get();
    if (!snap.exists) {
      final user = AppUser(
        uid: uid,
        displayName: name,
        email: email,
        createdAt: Timestamp.now(),
        streak: 0,
        journalCount: 0,
        themeMode: 'system',
      );
      await ref.set(user.toMap());
      return user;
    }
    return AppUser.fromDoc(snap);
  }

  Future<void> updateUserSetup(
    String uid, {
      required String focus,
      required List<String> interests,
      required Map<String, String> reminders,
    }) async {
      await _db.collection('users').doc(uid).set(
        {
          'focus': focus,
          'interests': interests,
          'reminders': reminders,
        },
        SetOptions(merge: true),
      );
  }

  Future<void> updateUserTheme(String uid, String themeMode) {
    return _db.collection('users').doc(uid).update({'themeMode': themeMode});
  }

  Stream<AppUser> watchUser(String uid) {
    return _db.collection('users').doc(uid).snapshots().map((d) => AppUser.fromDoc(d));
  }

  // POSTS (global feed)
  Stream<List<Post>> watchFeed({int limit = 50}) {
    return _db
        .collection('posts')
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots()
        .map((s) => s.docs.map((d) => Post.fromDoc(d)).toList());
  }

  Future<void> createPost(Post post) async {
    await _db.collection('posts').doc(post.id).set(post.toMap());
  }

  Future<void> toggleLike({required String postId, required String uid}) async {
    final postRef = _db.collection('posts').doc(postId);
    final likeRef = postRef.collection('likes').doc(uid);

    await _db.runTransaction((tx) async {
      final likeSnap = await tx.get(likeRef);
      final postSnap = await tx.get(postRef);

      if (!postSnap.exists) return;
      final currentLikes = (postSnap.data()!['likeCount'] ?? 0) as int;

      if (likeSnap.exists) {
        tx.delete(likeRef);
        tx.update(postRef, {'likeCount': currentLikes > 0 ? currentLikes - 1 : 0});
      } else {
        tx.set(likeRef, {'createdAt': Timestamp.now()});
        tx.update(postRef, {'likeCount': currentLikes + 1});
      }
    });
  }

  Stream<bool> watchLiked(String postId, String uid) {
    return _db.collection('posts').doc(postId).collection('likes').doc(uid).snapshots().map((d) => d.exists);
  }

  // GROUPS
  Stream<List<Group>> watchGroups() {
    return _db.collection('groups').orderBy('createdAt', descending: true).snapshots().map(
          (s) => s.docs.map((d) => Group.fromDoc(d)).toList(),
        );
  }

  Future<String> createGroup(Group group, String ownerUid) async {
    final ref = _db.collection('groups').doc(group.id);
    await ref.set(group.toMap());
    await ref.collection('members').doc(ownerUid).set({'role': 'owner', 'joinedAt': Timestamp.now()});
    return group.id;
  }

  Future<void> joinGroup(String groupId, String uid) async {
    final ref = _db.collection('groups').doc(groupId);
    final memberRef = ref.collection('members').doc(uid);

    await _db.runTransaction((tx) async {
      final m = await tx.get(memberRef);
      final g = await tx.get(ref);
      final current = (g.data()?['memberCount'] ?? 0) as int;

      if (!m.exists) {
        tx.set(memberRef, {'role': 'member', 'joinedAt': Timestamp.now()});
        tx.update(ref, {'memberCount': current + 1});
      }
    });
  }

  Stream<List<Post>> watchGroupFeed(String groupId, {int limit = 50}) {
    return _db
        .collection('groups')
        .doc(groupId)
        .collection('posts')
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots()
        .map((s) => s.docs.map((d) => Post.fromDoc(d)).toList());
  }

  Future<void> createGroupPost(String groupId, Post post) async {
    await _db.collection('groups').doc(groupId).collection('posts').doc(post.id).set(post.toMap());
  }

  // JOURNAL
Stream<List<JournalEntry>> watchJournal(String uid, {int limit = 60}) {
  return _db
      .collection('journalEntries')
      .where('uid', isEqualTo: uid)
      .orderBy('createdAt', descending: true)
      .limit(limit)
      .snapshots()
      .map((s) => s.docs.map((d) => JournalEntry.fromDoc(d)).toList());
}
// JOURNAL (update / delete)
Future<void> updateJournalEntry(JournalEntry entry) {
  return _db.collection('journalEntries').doc(entry.id).update(entry.toMap());
}

Future<void> deleteJournalEntry(String entryId) {
  return _db.collection('journalEntries').doc(entryId).delete();
}

Future<void> addJournalEntry(JournalEntry entry) async {
  // ✅ Ensure uid is never empty (this is a common reason entries “disappear”)
  if (entry.uid.trim().isEmpty) {
    throw Exception('JournalEntry.uid is empty. Cannot save.');
  }

  await _db.collection('journalEntries').doc(entry.id).set(entry.toMap());

  await _db.collection('users').doc(entry.uid).update({
    'journalCount': FieldValue.increment(1),
  });
}
  // PRAYERS
  Stream<List<PrayerItem>> watchPrayers(String uid) {
    return _db
        .collection('prayers')
        .where('uid', isEqualTo: uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((s) => s.docs.map((d) => PrayerItem.fromDoc(d)).toList());
  }

  Future<void> addPrayer(PrayerItem p) async {
    await _db.collection('prayers').doc(p.id).set(p.toMap());
  }

  Future<void> markPrayerAnswered(String id) async {
    await _db.collection('prayers').doc(id).update({'answered': true, 'answeredAt': Timestamp.now()});
  }

  todayKey() {}

  Stream<List<TaskItem>>? watchTasksForDate(String uid, String dateKey) {
    return null;
  }

  void toggleTaskDone(String id, bool v) {}

  Future<void> addTask(TaskItem task) async {}
}

class fromDoc {
}