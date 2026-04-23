import 'package:cloud_firestore/cloud_firestore.dart';

class Post {
  final String id;
  final String authorId;
  final String authorName;
  final String authorPhoto;
  final String caption;
  final String imageUrl;
  final Timestamp createdAt;
  final int likeCount;
  final int commentCount;
  final String? groupId;

  Post({
    required this.id,
    required this.authorId,
    required this.authorName,
    required this.authorPhoto,
    required this.caption,
    required this.imageUrl,
    required this.createdAt,
    required this.likeCount,
    required this.commentCount,
    this.groupId,
  });

  Map<String, dynamic> toMap() => {
        'authorId': authorId,
        'authorName': authorName,
        'authorPhoto': authorPhoto,
        'caption': caption,
        'imageUrl': imageUrl,
        'createdAt': createdAt,
        'likeCount': likeCount,
        'commentCount': commentCount,
        'groupId': groupId,
      };

  factory Post.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data()!;
    return Post(
      id: doc.id,
      authorId: d['authorId'] ?? '',
      authorName: d['authorName'] ?? '',
      authorPhoto: d['authorPhoto'] ?? '',
      caption: d['caption'] ?? '',
      imageUrl: d['imageUrl'] ?? '',
      createdAt: (d['createdAt'] as Timestamp?) ?? Timestamp.now(),
      likeCount: (d['likeCount'] ?? 0) as int,
      commentCount: (d['commentCount'] ?? 0) as int,
      groupId: d['groupId']?.toString(),
    );
  }
}