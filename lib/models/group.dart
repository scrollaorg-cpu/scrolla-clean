import 'package:cloud_firestore/cloud_firestore.dart';

class Group {
  final String id;
  final String name;
  final String description;
  final String ownerId;
  final Timestamp createdAt;
  final int memberCount;
  final bool isPrivate;

  Group({
    required this.id,
    required this.name,
    required this.description,
    required this.ownerId,
    required this.createdAt,
    required this.memberCount,
    required this.isPrivate,
  });

  Map<String, dynamic> toMap() => {
        'name': name,
        'description': description,
        'ownerId': ownerId,
        'createdAt': createdAt,
        'memberCount': memberCount,
        'isPrivate': isPrivate,
      };

  factory Group.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data()!;
    return Group(
      id: doc.id,
      name: d['name'] ?? '',
      description: d['description'] ?? '',
      ownerId: d['ownerId'] ?? '',
      createdAt: (d['createdAt'] as Timestamp?) ?? Timestamp.now(),
      memberCount: (d['memberCount'] ?? 0) as int,
      isPrivate: (d['isPrivate'] ?? false) as bool,
    );
  }
}