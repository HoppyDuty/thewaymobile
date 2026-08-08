class DictionaryDefinition {
  const DictionaryDefinition({required this.definition, this.example});

  final String definition;
  final String? example;

  factory DictionaryDefinition.fromJson(Map<String, dynamic> json) {
    return DictionaryDefinition(
      definition: json['definition'] as String,
      example: json['example'] as String?,
    );
  }
}

class DictionaryMeaning {
  const DictionaryMeaning({required this.partOfSpeech, required this.definitions});

  final String partOfSpeech;
  final List<DictionaryDefinition> definitions;

  factory DictionaryMeaning.fromJson(Map<String, dynamic> json) {
    return DictionaryMeaning(
      partOfSpeech: json['partOfSpeech'] as String? ?? '',
      definitions: (json['definitions'] as List<dynamic>? ?? [])
          .map((e) => DictionaryDefinition.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class DictionaryEntry {
  const DictionaryEntry({required this.word, this.phonetic, this.audioUrl, required this.meanings});

  final String word;
  final String? phonetic;

  /// First non-empty pronunciation audio URL found across `phonetics[]`.
  final String? audioUrl;
  final List<DictionaryMeaning> meanings;

  factory DictionaryEntry.fromJson(Map<String, dynamic> json) {
    final phonetics = json['phonetics'] as List<dynamic>? ?? [];
    String? audioUrl;
    for (final p in phonetics) {
      final audio = (p as Map<String, dynamic>)['audio'] as String?;
      if (audio != null && audio.isNotEmpty) {
        audioUrl = audio;
        break;
      }
    }

    return DictionaryEntry(
      word: json['word'] as String,
      phonetic: json['phonetic'] as String?,
      audioUrl: audioUrl,
      meanings: (json['meanings'] as List<dynamic>? ?? [])
          .map((e) => DictionaryMeaning.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
