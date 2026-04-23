import 'dart:convert';
import 'package:dio/dio.dart';

class VerseResult {
  final String reference;
  final String text;
  final String? translation;

  const VerseResult({
    required this.reference,
    required this.text,
    this.translation,
  });
}

class BibleApiService {
  BibleApiService({Dio? dio}) : _dio = dio ?? Dio();

  final Dio _dio;

  Map<String, dynamic> _asMap(dynamic data) {
    // Dio can return either a decoded Map OR a raw JSON string.
    if (data is Map<String, dynamic>) return data;

    if (data is String) {
      final decoded = jsonDecode(data);
      if (decoded is Map<String, dynamic>) return decoded;
    }

    throw Exception('Unexpected response format from Bible API.');
  }

  /// ✅ Verse of the Day (OurManna)
  Future<VerseResult> getVerseOfDay() async {
  final res = await _dio.get(
    'https://beta.ourmanna.com/api/v1/get',
    queryParameters: const {'format': 'json'}, // ✅ force JSON
    options: Options(
      responseType: ResponseType.json, // ✅ Dio parses JSON automatically
      headers: {'Accept': 'application/json'},
    ),
  );

  // Dio should now give a Map, but we still guard
  final data = _asMap(res.data);

  final verse = (data['verse'] is Map) ? (data['verse'] as Map) : const {};
  final details = (verse['details'] is Map) ? (verse['details'] as Map) : const {};

  final ref = (details['reference'] ?? '').toString().trim();
  final text = (details['text'] ?? '').toString().trim();

  final version = (details['version'] ?? details['version_id'] ?? '').toString().trim();

  return VerseResult(
    reference: ref.isEmpty ? 'Verse of the Day' : ref,
    text: text.isEmpty ? 'Unable to load verse right now.' : text,
    translation: version.isEmpty ? null : version,
  );
}

  /// ✅ Read a passage like "John 3:16" or "Matthew 5:1-12"
  /// bible-api.com
  Future<VerseResult> getPassage(String query, {String translation = 'web'}) async {
    final q = query.trim();
    if (q.isEmpty) {
      throw Exception('Please enter a Bible reference (e.g. John 3:16).');
    }

    final url = 'https://bible-api.com/${Uri.encodeComponent(q)}';
    final res = await _dio.get(
      url,
      queryParameters: {'translation': translation},
      options: Options(headers: {'Accept': 'application/json'}),
    );

    final data = _asMap(res.data);

    final reference = (data['reference'] ?? q).toString().trim();
    final text = (data['text'] ?? '').toString().trim();

    return VerseResult(
      reference: reference.isEmpty ? q : reference,
      text: text.isEmpty ? 'No text returned.' : text,
      translation: translation.toUpperCase(),
    );
  }
}