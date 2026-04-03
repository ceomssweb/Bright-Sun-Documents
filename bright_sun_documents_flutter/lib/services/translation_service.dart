import 'dart:convert';
import 'package:http/http.dart' as http;
import 'gemini_service.dart';

enum TranslationEngine { geminiAi, myMemory }

class Language {
  final String code;
  final String name;
  const Language({required this.code, required this.name});
}

class TranslationResult {
  final String translatedText;
  final String sourceLanguage;
  final String targetLanguage;
  final bool success;
  final String? error;
  final TranslationEngine? engine;

  const TranslationResult({
    required this.translatedText,
    required this.sourceLanguage,
    required this.targetLanguage,
    this.success = true,
    this.error,
    this.engine,
  });
}

class TranslationService {
  static const String _apiUrl = 'https://api.mymemory.translated.net/get';
  final GeminiService _geminiService = GeminiService();

  static const List<Language> supportedLanguages = [
    Language(code: 'auto', name: 'Auto-Detect'),
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
    Language(code: 'ms', name: 'Malay'),
    Language(code: 'th', name: 'Thai'),
    Language(code: 'vi', name: 'Vietnamese'),
    Language(code: 'id', name: 'Indonesian'),
    Language(code: 'nl', name: 'Dutch'),
    Language(code: 'pl', name: 'Polish'),
    Language(code: 'sv', name: 'Swedish'),
    Language(code: 'tr', name: 'Turkish'),
  ];

  /// Source languages include Auto-Detect. Target languages exclude it.
  static List<Language> get sourceLanguages => supportedLanguages;
  static List<Language> get targetLanguages =>
      supportedLanguages.where((l) => l.code != 'auto').toList();

  bool get isAiAvailable => _geminiService.isConfigured;

  /// Detect language using Gemini AI
  Future<LanguageDetectResult> detectLanguage(String text) async {
    return _geminiService.detectLanguage(text);
  }

  /// Translate text — uses Gemini AI as primary, MyMemory as fallback
  Future<TranslationResult> translateText(
    String text,
    String sourceLang,
    String targetLang, {
    TranslationEngine preferredEngine = TranslationEngine.geminiAi,
  }) async {
    if (text.trim().isEmpty) {
      return TranslationResult(
        translatedText: '',
        sourceLanguage: sourceLang,
        targetLanguage: targetLang,
      );
    }

    if (sourceLang == targetLang && sourceLang != 'auto') {
      return TranslationResult(
        translatedText: '',
        sourceLanguage: sourceLang,
        targetLanguage: targetLang,
        success: false,
        error: 'Source and target languages must be different.',
      );
    }

    // Resolve auto-detect if needed
    String resolvedSource = sourceLang;
    if (sourceLang == 'auto') {
      if (_geminiService.isConfigured) {
        final detect = await _geminiService.detectLanguage(text);
        if (detect.isDetected) {
          resolvedSource = detect.code;
          if (resolvedSource == targetLang) {
            return TranslationResult(
              translatedText: '',
              sourceLanguage: resolvedSource,
              targetLanguage: targetLang,
              success: false,
              error: 'Detected language ($resolvedSource) is same as target.',
            );
          }
        }
      }
    }

    // Get language names for Gemini
    final srcName = _langName(resolvedSource);
    final tgtName = _langName(targetLang);

    // Try Gemini AI first (if available and preferred)
    if (preferredEngine == TranslationEngine.geminiAi && _geminiService.isConfigured) {
      final aiResult = await _geminiService.translate(text, srcName, tgtName);
      if (aiResult.success) {
        return TranslationResult(
          translatedText: aiResult.translatedText,
          sourceLanguage: resolvedSource,
          targetLanguage: targetLang,
          engine: TranslationEngine.geminiAi,
        );
      }
      // AI failed — fall back to MyMemory
    }

    // Fallback to MyMemory
    return _translateWithMyMemory(text, resolvedSource, targetLang);
  }

  Future<TranslationResult> _translateWithMyMemory(String text, String sourceLang, String targetLang) async {
    try {
      final chunks = _splitTextIntoChunks(text, 450);
      final translatedChunks = <String>[];

      for (final chunk in chunks) {
        final translated = await _translateChunk(chunk, sourceLang, targetLang);
        if (translated == null) {
          return TranslationResult(
            translatedText: translatedChunks.join(' '),
            sourceLanguage: sourceLang,
            targetLanguage: targetLang,
            success: false,
            error: 'Translation partially failed. Some text may not be translated.',
            engine: TranslationEngine.myMemory,
          );
        }
        translatedChunks.add(translated);
      }

      return TranslationResult(
        translatedText: translatedChunks.join(' '),
        sourceLanguage: sourceLang,
        targetLanguage: targetLang,
        engine: TranslationEngine.myMemory,
      );
    } catch (e) {
      return TranslationResult(
        translatedText: '',
        sourceLanguage: sourceLang,
        targetLanguage: targetLang,
        success: false,
        error: 'Translation failed. Please check your internet connection.',
      );
    }
  }

  Future<String?> _translateChunk(String text, String sourceLang, String targetLang) async {
    try {
      final uri = Uri.parse(_apiUrl).replace(queryParameters: {
        'q': text,
        'langpair': '$sourceLang|$targetLang',
      });

      final response = await http.get(uri).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['responseStatus'] == 200 && data['responseData']?['translatedText'] != null) {
          return data['responseData']['translatedText'];
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  String _langName(String code) {
    final found = supportedLanguages.where((l) => l.code == code);
    return found.isNotEmpty ? found.first.name : code;
  }

  List<String> _splitTextIntoChunks(String text, int maxLength) {
    final chunks = <String>[];
    final sentences = text.split(RegExp(r'(?<=[.!?\n])\s+'));
    var currentChunk = '';

    for (final sentence in sentences) {
      if (('$currentChunk $sentence').length > maxLength && currentChunk.isNotEmpty) {
        chunks.add(currentChunk.trim());
        currentChunk = sentence;
      } else {
        currentChunk += (currentChunk.isNotEmpty ? ' ' : '') + sentence;
      }
    }
    if (currentChunk.trim().isNotEmpty) {
      chunks.add(currentChunk.trim());
    }

    final result = <String>[];
    for (final chunk in chunks) {
      if (chunk.length > maxLength) {
        for (var i = 0; i < chunk.length; i += maxLength) {
          result.add(chunk.substring(i, (i + maxLength).clamp(0, chunk.length)));
        }
      } else {
        result.add(chunk);
      }
    }
    return result;
  }

  static String getLanguageName(String code) {
    return supportedLanguages.where((l) => l.code == code).firstOrNull?.name ?? code;
  }
}
