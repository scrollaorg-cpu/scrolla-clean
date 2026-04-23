import 'package:cloud_firestore/cloud_firestore.dart';

class TaskItem {
  final String id;
  final String uid;
  final String date; // yyyy-MM-dd
  final String title;
  final String priority; // low|med|high
  final bool done;
  final Timestamp createdAt;

  TaskItem({
    required this.id,
    required this.uid,
    required this.date,
    required this.title,
    required this.priority,
    required this.done,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() => {
        'uid': uid,
        'date': date,
        'title': title,
        'priority': priority,
        'done': done,
        'createdAt': createdAt,
      };

  factory TaskItem.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data();

    // If doc exists but data is null (rare), fall back safely
    if (d == null) {
      return TaskItem(
        id: doc.id,
        uid: '',
        date: '',
        title: 'Untitled Task',
        priority: 'med',
        done: false,
        createdAt: Timestamp.now(),
      );
    }

    // ✅ Never hard-cast user-generated fields
    final titleRaw = (d['title'] ?? '').toString().trim();
    final priorityRaw = (d['priority'] ?? 'med').toString().trim().toLowerCase();

    final priority = (priorityRaw == 'low' || priorityRaw == 'med' || priorityRaw == 'high')
        ? priorityRaw
        : 'med';

    // ✅ SAFE bool parsing (covers bool, null, 0/1, "true"/"false")
    final dynamic doneRaw = d['done'];
    final bool done = doneRaw is bool
        ? doneRaw
        : (doneRaw is num
            ? doneRaw != 0
            : (doneRaw is String ? doneRaw.toLowerCase() == 'true' : false));

    return TaskItem(
      id: doc.id,
      uid: (d['uid'] ?? '').toString(),
      date: (d['date'] ?? '').toString(),
      title: titleRaw.isEmpty ? 'Untitled Task' : titleRaw,
      priority: priority,
      done: done,
      createdAt: (d['createdAt'] as Timestamp?) ?? Timestamp.now(),
    );
  }
}