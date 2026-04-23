import 'package:cloud_firestore/cloud_firestore.dart';

class PrayerItem {
  final String id;
  final String uid;
  final String title;
  final String detail;
  final bool isPrivate;
  final bool answered;
  final Timestamp createdAt;
  final Timestamp? answeredAt;

  PrayerItem({
    required this.id,
    required this.uid,
    required this.title,
    required this.detail,
    required this.isPrivate,
    required this.answered,
    required this.createdAt,
    this.answeredAt,
  });

  Map<String, dynamic> toMap() => {
        'uid': uid,
        'title': title,
        'detail': detail,
        'isPrivate': isPrivate,
        'answered': answered,
        'createdAt': createdAt,
        'answeredAt': answeredAt,
      };

  factory PrayerItem.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data()!;
    return PrayerItem(
      id: doc.id,
      uid: d['uid'] ?? '',
      title: d['title'] ?? '',
      detail: d['detail'] ?? '',
      isPrivate: (d['isPrivate'] ?? true) as bool,
      answered: (d['answered'] ?? false) as bool,
      createdAt: (d['createdAt'] as Timestamp?) ?? Timestamp.now(),
      answeredAt: d['answeredAt'] as Timestamp?,
    );
  }
}