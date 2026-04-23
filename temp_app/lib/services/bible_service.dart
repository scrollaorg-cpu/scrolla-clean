import 'package:dio/dio.dart';

class BibleVerse {
  final String reference;
  final String text;

  BibleVerse({required this.reference, required this.text});
}

class BibleService {
  BibleService._();
  static final BibleService instance = BibleService._();

  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: 'https://bible-api.com',
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ),
  );

  Future<BibleVerse> fetchVerse(String ref) async {
    final encoded = Uri.encodeComponent(ref);
    final res = await _dio.get('/$encoded');
    final data = res.data as Map<String, dynamic>;
    return BibleVerse(
      reference: (data['reference'] ?? ref).toString(),
      text: (data['text'] ?? '').toString().trim(),
    );
  }

  /// Simple “daily verse”: rotate a small set by day number.
  Future<BibleVerse> dailyVerse() async {
    final picks = <String>[
      'Proverbs 3:5-6',
      'Philippians 4:6-7',
      'Joshua 1:9',
      'Psalm 23:1',
      'Romans 8:28',
      'Matthew 6:33',
      'Isaiah 41:10',
    ];
    final day = DateTime.now().day;
    final ref = picks[day % picks.length];
    return fetchVerse(ref);
  }
}