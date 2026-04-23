import 'package:cloud_firestore/cloud_firestore.dart';

class AppUser {
  final String uid;
  final String displayName;
  final String email;
  final Timestamp createdAt;

  final int streak;
  final int journalCount;

  // Personalization
  final String? focus;
  final List<String> interests;
  final Map<String, String> reminders;

  // Settings
  final String themeMode; // system/light/dark

  AppUser({
    required this.uid,
    required this.displayName,
    required this.email,
    required this.createdAt,
    required this.streak,
    required this.journalCount,
    this.focus,
    this.interests = const [],
    this.reminders = const {},
    this.themeMode = 'system',
  });

  Map<String, dynamic> toMap() => {
        'uid': uid,
        'displayName': displayName,
        'email': email,
        'createdAt': createdAt,
        'streak': streak,
        'journalCount': journalCount,
        'focus': focus,
        'interests': interests,
        'reminders': reminders,
        'themeMode': themeMode,
      };

  factory AppUser.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data();

    if (d == null) {
      return AppUser(
        uid: doc.id,
        displayName: '',
        email: '',
        createdAt: Timestamp.now(),
        streak: 0,
        journalCount: 0,
        focus: null,
        interests: const [],
        reminders: const {},
        themeMode: 'system',
      );
    }

    // ✅ Safe conversions (no `as String`)
    final interestsRaw = (d['interests'] as List?) ?? const [];
    final remindersRaw = (d['reminders'] as Map?) ?? const {};

    int toInt(dynamic v) {
      if (v is int) return v;
      if (v is num) return v.toInt();
      return int.tryParse(v?.toString() ?? '') ?? 0;
    }

    return AppUser(
      uid: (d['uid'] ?? doc.id).toString(),
      displayName: (d['displayName'] ?? '').toString(),
      email: (d['email'] ?? '').toString(),
      createdAt: (d['createdAt'] as Timestamp?) ?? Timestamp.now(),
      streak: toInt(d['streak']),
      journalCount: toInt(d['journalCount']),
      focus: d['focus']?.toString(),
      interests: interestsRaw.map((e) => e.toString()).toList(),
      reminders: remindersRaw.map((k, v) => MapEntry(k.toString(), v.toString())),
      themeMode: (d['themeMode'] ?? 'system').toString(),
    );
  }

  get photoUrl => null;

  AppUser copyWith({
    String? displayName,
    String? email,
    int? streak,
    int? journalCount,
    String? focus,
    List<String>? interests,
    Map<String, String>? reminders,
    String? themeMode,
  }) {
    return AppUser(
      uid: uid,
      displayName: displayName ?? this.displayName,
      email: email ?? this.email,
      createdAt: createdAt,
      streak: streak ?? this.streak,
      journalCount: journalCount ?? this.journalCount,
      focus: focus ?? this.focus,
      interests: interests ?? this.interests,
      reminders: reminders ?? this.reminders,
      themeMode: themeMode ?? this.themeMode,
    );
  }
}