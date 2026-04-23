import 'package:cloud_firestore/cloud_firestore.dart';

class JournalEntry {
  final String id;
  final String uid;

  final String date; // yyyy-MM-dd
  final String mood;
  final String title;
  final String content;

  final String scriptureRef;
  final String scriptureText;

  final Timestamp createdAt;

  JournalEntry({
    required this.id,
    required this.uid,
    required this.date,
    required this.mood,
    required this.title,
    required this.content,
    required this.scriptureRef,
    required this.scriptureText,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() => {
        'uid': uid,
        'date': date,
        'mood': mood,
        'title': title,
        'content': content,
        'scriptureRef': scriptureRef,
        'scriptureText': scriptureText,
        'createdAt': createdAt,
      };

  factory JournalEntry.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data();
    if (d == null) {
      return JournalEntry(
        id: doc.id,
        uid: '',
        date: '',
        mood: '',
        title: '',
        content: '',
        scriptureRef: '',
        scriptureText: '',
        createdAt: Timestamp.now(),
      );
    }

    return JournalEntry(
      id: doc.id,
      uid: (d['uid'] ?? '').toString(),
      date: (d['date'] ?? '').toString(),
      mood: (d['mood'] ?? '').toString(),
      title: (d['title'] ?? '').toString(),
      content: (d['content'] ?? '').toString(),
      scriptureRef: (d['scriptureRef'] ?? '').toString(),
      scriptureText: (d['scriptureText'] ?? '').toString(),
      createdAt: (d['createdAt'] as Timestamp?) ?? Timestamp.now(),
    );
  }
}