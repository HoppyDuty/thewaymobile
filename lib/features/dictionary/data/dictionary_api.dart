import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'models/dictionary_entry.dart';

part 'dictionary_api.g.dart';

/// dictionaryapi.dev — a free, keyless public dictionary lookup. Deliberately
/// uses its own bare [Dio] instance rather than the shared [ApiClient]: this
/// is a different host entirely and needs none of our device-fingerprint/
/// auth headers.
class DictionaryApi {
  // Found on a real device with a poor connection: neither Dio instance had
  // a timeout configured (Dio's default is none), so a lookup with a slow/
  // stalled connection left the screen stuck on its loading shimmer forever
  // — _isLoading only ever cleared in the `finally` of a request that never
  // itself resolved or threw. Matches ApiClient's own timeouts for
  // consistency.
  DictionaryApi()
      : _dio = Dio(BaseOptions(
          baseUrl: 'https://api.dictionaryapi.dev/api/v2',
          connectTimeout: const Duration(seconds: 15),
          receiveTimeout: const Duration(seconds: 20),
        )),
        _suggestDio = Dio(BaseOptions(
          baseUrl: 'https://api.datamuse.com',
          connectTimeout: const Duration(seconds: 15),
          receiveTimeout: const Duration(seconds: 20),
        ));

  final Dio _dio;

  /// Datamuse — also free/keyless, purpose-built for spelling
  /// suggestions/autocomplete (dictionaryapi.dev has no such endpoint).
  final Dio _suggestDio;

  /// Returns `null` if the word has no entry (404) rather than throwing —
  /// "no results" is an expected, common outcome here, not an error.
  Future<List<DictionaryEntry>?> lookup(String word) async {
    try {
      final response = await _dio.get('/entries/en/${Uri.encodeComponent(word.trim())}');
      final body = response.data as List<dynamic>;
      return body.map((e) => DictionaryEntry.fromJson(e as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return null;
      rethrow;
    }
  }

  /// Spelling-based suggestions (autocomplete-as-you-type, and "did you
  /// mean" for a word with no dictionary entry).
  Future<List<String>> suggest(String partialWord, {int max = 8}) async {
    if (partialWord.trim().isEmpty) return [];
    try {
      final response = await _suggestDio.get('/words', queryParameters: {
        'sp': '${partialWord.trim()}*',
        'max': max,
      });
      final body = response.data as List<dynamic>;
      return body.map((e) => (e as Map<String, dynamic>)['word'] as String).toList();
    } on DioException {
      return [];
    }
  }
}

@Riverpod(keepAlive: true)
DictionaryApi dictionaryApi(DictionaryApiRef ref) => DictionaryApi();
