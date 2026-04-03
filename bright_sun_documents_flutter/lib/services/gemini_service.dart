import 'dart:convert';
import 'dart:typed_data';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GeminiService {
  static const String _apiKeyPref = 'gemini_api_key';
  GenerativeModel? _model;
  GenerativeModel? _visionModel;
  String? _apiKey;

  static final GeminiService _instance = GeminiService._internal();
  factory GeminiService() => _instance;
  GeminiService._internal();

  bool get isConfigured => _apiKey != null && _apiKey!.isNotEmpty;

  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    _apiKey = prefs.getString(_apiKeyPref);
    if (_apiKey != null && _apiKey!.isNotEmpty) {
      _initModels();
    }
  }

  void _initModels() {
    _model = GenerativeModel(
      model: 'gemini-2.0-flash',
      apiKey: _apiKey!,
      generationConfig: GenerationConfig(
        temperature: 0.1,
        maxOutputTokens: 8192,
      ),
    );
    _visionModel = GenerativeModel(
      model: 'gemini-2.0-flash',
      apiKey: _apiKey!,
      generationConfig: GenerationConfig(
        temperature: 0.1,
        maxOutputTokens: 8192,
      ),
    );
  }

  Future<bool> setApiKey(String key) async {
    try {
      // Validate the key by making a simple test request
      final testModel = GenerativeModel(
        model: 'gemini-2.0-flash',
        apiKey: key,
      );
      await testModel.generateContent([Content.text('Hello')]);

      _apiKey = key;
      _initModels();
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_apiKeyPref, key);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<String?> getApiKey() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_apiKeyPref);
  }

  Future<void> clearApiKey() async {
    _apiKey = null;
    _model = null;
    _visionModel = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_apiKeyPref);
  }

  // ─── OCR: Extract text from PDF bytes ───
  Future<OcrResult> extractTextFromPdf(Uint8List pdfBytes) async {
    if (!isConfigured || _visionModel == null) {
      return OcrResult(text: '', pages: [], error: 'Gemini AI is not configured. Please add your API key in Settings.');
    }

    try {
      final content = Content.multi([
        DataPart('application/pdf', pdfBytes),
        TextPart(
          'Extract ALL text from this PDF document. '
          'Return the text organized by page. '
          'Format: Start each page with "--- PAGE X ---" on its own line, '
          'then the full text of that page. '
          'Preserve the original language. Do not translate. '
          'If a page has no text (only images or blank), write "--- PAGE X --- [NO TEXT]". '
          'Extract text from images, handwriting, and scanned content using OCR.',
        ),
      ]);

      final response = await _visionModel!.generateContent([content]);
      final resultText = response.text ?? '';

      if (resultText.isEmpty) {
        return OcrResult(text: '', pages: [], error: 'No text could be extracted from this PDF.');
      }

      // Parse pages
      final pages = <OcrPage>[];
      final pagePattern = RegExp(r'---\s*PAGE\s*(\d+)\s*---\s*(?:\[NO TEXT\])?\s*', caseSensitive: false);
      final matches = pagePattern.allMatches(resultText).toList();

      if (matches.isEmpty) {
        // No page markers found - treat entire text as page 1
        pages.add(OcrPage(pageNumber: 1, text: resultText.trim(), sentences: _splitSentences(resultText)));
      } else {
        for (int i = 0; i < matches.length; i++) {
          final pageNum = int.tryParse(matches[i].group(1) ?? '0') ?? (i + 1);
          final start = matches[i].end;
          final end = (i + 1 < matches.length) ? matches[i + 1].start : resultText.length;
          final pageText = resultText.substring(start, end).trim();

          pages.add(OcrPage(
            pageNumber: pageNum,
            text: pageText,
            sentences: _splitSentences(pageText),
          ));
        }
      }

      final allText = pages.where((p) => p.text.isNotEmpty).map((p) => p.text).join('\n\n');
      return OcrResult(text: allText, pages: pages);
    } catch (e) {
      return OcrResult(text: '', pages: [], error: 'AI OCR failed: ${_friendlyError(e)}');
    }
  }

  // ─── OCR: Extract text from image bytes ───
  Future<OcrResult> extractTextFromImage(Uint8List imageBytes, String mimeType) async {
    if (!isConfigured || _visionModel == null) {
      return OcrResult(text: '', pages: [], error: 'Gemini AI is not configured. Please add your API key in Settings.');
    }

    try {
      final content = Content.multi([
        DataPart(mimeType, imageBytes),
        TextPart(
          'Extract ALL text from this image using OCR. '
          'Preserve the original language and formatting. '
          'Include text from handwriting, printed text, stamps, and watermarks. '
          'Return only the extracted text, nothing else.',
        ),
      ]);

      final response = await _visionModel!.generateContent([content]);
      final resultText = response.text?.trim() ?? '';

      if (resultText.isEmpty) {
        return OcrResult(text: '', pages: [], error: 'No text could be extracted from this image.');
      }

      final pages = [OcrPage(pageNumber: 1, text: resultText, sentences: _splitSentences(resultText))];
      return OcrResult(text: resultText, pages: pages);
    } catch (e) {
      return OcrResult(text: '', pages: [], error: 'AI OCR failed: ${_friendlyError(e)}');
    }
  }

  // ─── Language Detection ───
  Future<LanguageDetectResult> detectLanguage(String text) async {
    if (!isConfigured || _model == null) {
      return LanguageDetectResult(code: '', name: '', error: 'Gemini AI not configured.');
    }

    try {
      final response = await _model!.generateContent([
        Content.text(
          'Detect the language of this text and respond with ONLY a JSON object: '
          '{"code": "ISO 639-1 code", "name": "Language name"}. '
          'Examples: {"code": "ta", "name": "Tamil"}, {"code": "en", "name": "English"}. '
          'Text: "$text"',
        ),
      ]);

      final raw = response.text?.trim() ?? '';
      // Extract JSON from response
      final jsonMatch = RegExp(r'\{[^}]+\}').firstMatch(raw);
      if (jsonMatch != null) {
        final parsed = json.decode(jsonMatch.group(0)!) as Map<String, dynamic>;
        return LanguageDetectResult(
          code: parsed['code']?.toString() ?? '',
          name: parsed['name']?.toString() ?? '',
        );
      }
      return LanguageDetectResult(code: '', name: '', error: 'Could not detect language.');
    } catch (e) {
      return LanguageDetectResult(code: '', name: '', error: 'Detection failed: ${_friendlyError(e)}');
    }
  }

  // ─── AI Translation ───
  Future<AiTranslationResult> translate(String text, String sourceLang, String targetLang) async {
    if (!isConfigured || _model == null) {
      return AiTranslationResult(translatedText: '', error: 'Gemini AI not configured.');
    }

    if (text.trim().isEmpty) {
      return AiTranslationResult(translatedText: '', error: 'No text to translate.');
    }

    try {
      final response = await _model!.generateContent([
        Content.text(
          'Translate the following text from $sourceLang to $targetLang. '
          'Rules:\n'
          '1. Provide ONLY the translated text, no explanations.\n'
          '2. Maintain the original formatting and paragraph structure.\n'
          '3. For legal/official documents, use formal language.\n'
          '4. Keep proper nouns, names, addresses, and numbers as-is.\n'
          '5. If any part is unclear, provide the best translation.\n\n'
          'Text to translate:\n$text',
        ),
      ]);

      final translated = response.text?.trim() ?? '';
      if (translated.isEmpty) {
        return AiTranslationResult(translatedText: '', error: 'Translation returned empty result.');
      }
      return AiTranslationResult(translatedText: translated);
    } catch (e) {
      return AiTranslationResult(translatedText: '', error: 'Translation failed: ${_friendlyError(e)}');
    }
  }

  // ─── Helpers ───
  static List<String> _splitSentences(String text) {
    if (text.trim().isEmpty) return [];
    final raw = text
        .replaceAll(RegExp(r'\r\n|\r'), '\n')
        .split(RegExp(r'(?<=[.!?।])\s+'))
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();
    if (raw.length <= 1 && text.contains('\n')) {
      return text.split('\n').map((s) => s.trim()).where((s) => s.isNotEmpty).toList();
    }
    return raw;
  }

  String _friendlyError(dynamic e) {
    final msg = e.toString();
    if (msg.contains('API_KEY_INVALID') || msg.contains('PERMISSION_DENIED')) {
      return 'Invalid API key. Please update it in Settings.';
    }
    if (msg.contains('RESOURCE_EXHAUSTED') || msg.contains('quota')) {
      return 'API quota exhausted. Please try again later or upgrade your plan.';
    }
    if (msg.contains('SAFETY')) {
      return 'Content was blocked by safety filters. Try different text.';
    }
    if (msg.contains('timeout') || msg.contains('SocketException')) {
      return 'Network error. Please check your internet connection.';
    }
    return msg.length > 100 ? '${msg.substring(0, 100)}...' : msg;
  }
}

// ─── Result Models ───

class OcrPage {
  final int pageNumber;
  final String text;
  final List<String> sentences;

  const OcrPage({required this.pageNumber, required this.text, required this.sentences});

  bool get isEmpty => text.trim().isEmpty;
  bool get isNotEmpty => text.trim().isNotEmpty;
}

class OcrResult {
  final String text;
  final List<OcrPage> pages;
  final String? error;

  const OcrResult({required this.text, required this.pages, this.error});

  bool get hasText => pages.any((p) => p.isNotEmpty);
  bool get hasError => error != null;
  int get totalPages => pages.length;
  int get pagesWithText => pages.where((p) => p.isNotEmpty).length;
}

class LanguageDetectResult {
  final String code;
  final String name;
  final String? error;

  const LanguageDetectResult({required this.code, required this.name, this.error});

  bool get hasError => error != null;
  bool get isDetected => code.isNotEmpty;
}

class AiTranslationResult {
  final String translatedText;
  final String? error;

  const AiTranslationResult({required this.translatedText, this.error});

  bool get success => error == null && translatedText.isNotEmpty;
  bool get hasError => error != null;
}
