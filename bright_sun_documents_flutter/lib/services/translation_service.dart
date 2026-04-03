import 'dart:convert';
import 'package:http/http.dart' as http;

class Language {
  final String code;
  final String name;

  const Language({required this.code, required this.name});
}

class TranslationResult {
  final String translatedText;
  final String sourceLanguage;
  final String targetLanguage;

  TranslationResult({
    required this.translatedText,
    required this.sourceLanguage,
    required this.targetLanguage,
  });
}

class TranslationService {
  static const String _apiUrl = 'https://api.mymemory.translated.net/get';

  static const List<Language> supportedLanguages = [
    Language(code: 'ta', name: 'Tamil'),
    Language(code: 'en', name: 'English'),
    Language(code: 'hi', name: 'Hindi'),
    Language(code: 'fr', name: 'French'),
    Language(code: 'de', name: 'German'),
    Language(code: 'es', name: 'Spanish'),
    Language(code: 'ar', name: 'Arabic'),
    Language(code: 'zh', name: 'Chinese'),
    Language(code: 'ja', name: 'Japanese'),
    Language(code: 'ko', name: 'Korean'),
    Language(code: 'ml', name: 'Malayalam'),
    Language(code: 'te', name: 'Telugu'),
    Language(code: 'kn', name: 'Kannada'),
    Language(code: 'bn', name: 'Bengali'),
    Language(code: 'mr', name: 'Marathi'),
    Language(code: 'gu', name: 'Gujarati'),
    Language(code: 'ur', name: 'Urdu'),
    Language(code: 'pt', name: 'Portuguese'),
    Language(code: 'ru', name: 'Russian'),
    Language(code: 'it', name: 'Italian'),
  ];

  Future<TranslationResult> translateText(
      String text, String sourceLang, String targetLang) async {
    if (text.trim().isEmpty) {
      return TranslationResult(
        translatedText: '',
        sourceLanguage: sourceLang,
        targetLanguage: targetLang,
      );
    }

    final chunks = _splitTextIntoChunks(text, 450);
    final translatedChunks = <String>[];

    for (final chunk in chunks) {
      final translated = await _translateChunk(chunk, sourceLang, targetLang);
      translatedChunks.add(translated);
    }

    return TranslationResult(
      translatedText: translatedChunks.join(' '),
      sourceLanguage: sourceLang,
      targetLanguage: targetLang,
    );
  }

  Future<String> _translateChunk(
      String text, String sourceLang, String targetLang) async {
    try {
      final uri = Uri.parse(_apiUrl).replace(queryParameters: {
        'q': text,
        'langpair': '$sourceLang|$targetLang',
      });

      final response = await http.get(uri);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['responseStatus'] == 200 &&
            data['responseData']?['translatedText'] != null) {
          return data['responseData']['translatedText'];
        }
      }
      return '[Translation failed for chunk]';
    } catch (e) {
      return '[Translation error]';
    }
  }

  List<String> _splitTextIntoChunks(String text, int maxLength) {
    final chunks = <String>[];
    final sentences = text.split(RegExp(r'(?<=[.!?\n])\s+'));
    var currentChunk = '';

    for (final sentence in sentences) {
      if (('$currentChunk $sentence').length > maxLength &&
          currentChunk.isNotEmpty) {
        chunks.add(currentChunk.trim());
        currentChunk = sentence;
      } else {
        currentChunk += (currentChunk.isNotEmpty ? ' ' : '') + sentence;
      }
    }

    if (currentChunk.trim().isNotEmpty) {
      chunks.add(currentChunk.trim());
    }

    // Handle case where a single sentence exceeds maxLength
    final result = <String>[];
    for (final chunk in chunks) {
      if (chunk.length > maxLength) {
        for (var i = 0; i < chunk.length; i += maxLength) {
          result.add(chunk.substring(
              i, i + maxLength > chunk.length ? chunk.length : i + maxLength));
        }
      } else {
        result.add(chunk);
      }
    }
    return result;
  }

  static String getLanguageName(String code) {
    return supportedLanguages
            .where((l) => l.code == code)
            .firstOrNull
            ?.name ??
        code;
  }
}
