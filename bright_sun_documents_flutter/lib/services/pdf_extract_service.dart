import 'dart:typed_data';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'gemini_service.dart';

class PdfPageText {
  final int pageNumber;
  final String text;
  final List<String> sentences;

  const PdfPageText({required this.pageNumber, required this.text, required this.sentences});

  bool get isEmpty => text.trim().isEmpty;
  bool get isNotEmpty => text.trim().isNotEmpty;
}

class PdfExtractResult {
  final List<PdfPageText> pages;
  final int totalPages;
  final int pagesWithText;
  final String? error;
  final bool usedAiOcr;

  const PdfExtractResult({
    required this.pages,
    required this.totalPages,
    required this.pagesWithText,
    this.error,
    this.usedAiOcr = false,
  });

  bool get hasText => pagesWithText > 0;
  bool get hasError => error != null;
  String get allText => pages.where((p) => p.isNotEmpty).map((p) => p.text).join('\n\n');
}

class PdfExtractService {
  final GeminiService _geminiService = GeminiService();

  /// Extract text from PDF. First tries syncfusion text extraction,
  /// then falls back to Gemini AI OCR for scanned documents.
  Future<PdfExtractResult> extractPagesFromBytes(Uint8List bytes, {bool forceAiOcr = false}) async {
    if (forceAiOcr) {
      return _extractWithAiOcr(bytes);
    }

    try {
      final PdfDocument document = PdfDocument(inputBytes: bytes);
      final pages = <PdfPageText>[];
      final totalPages = document.pages.count;

      for (int i = 0; i < totalPages; i++) {
        String pageText = '';
        try {
          pageText = PdfTextExtractor(document).extractText(startPageIndex: i, endPageIndex: i);
        } catch (_) {
          // Page may have no extractable text
        }
        pages.add(PdfPageText(
          pageNumber: i + 1,
          text: pageText.trim(),
          sentences: _splitSentences(pageText),
        ));
      }

      document.dispose();

      final pagesWithText = pages.where((p) => p.isNotEmpty).length;

      if (pagesWithText == 0) {
        // No text found — automatically try AI OCR
        if (_geminiService.isConfigured) {
          return _extractWithAiOcr(bytes);
        }
        return PdfExtractResult(
          pages: pages,
          totalPages: totalPages,
          pagesWithText: 0,
          error: 'This PDF contains scanned images. '
              'Configure your Gemini AI API key in Settings to enable AI-powered text extraction (OCR).',
        );
      }

      return PdfExtractResult(
        pages: pages,
        totalPages: totalPages,
        pagesWithText: pagesWithText,
      );
    } catch (e) {
      // If syncfusion fails, try AI OCR as last resort
      if (_geminiService.isConfigured) {
        return _extractWithAiOcr(bytes);
      }
      return PdfExtractResult(
        pages: [],
        totalPages: 0,
        pagesWithText: 0,
        error: 'Failed to read the PDF file. Configure Gemini AI in Settings for scanned document support.',
      );
    }
  }

  /// Extract text from image files
  Future<PdfExtractResult> extractTextFromImage(Uint8List imageBytes, String mimeType) async {
    if (!_geminiService.isConfigured) {
      return PdfExtractResult(
        pages: [],
        totalPages: 0,
        pagesWithText: 0,
        error: 'Configure your Gemini AI API key in Settings to extract text from images.',
      );
    }

    final result = await _geminiService.extractTextFromImage(imageBytes, mimeType);
    if (result.hasError) {
      return PdfExtractResult(
        pages: [],
        totalPages: 0,
        pagesWithText: 0,
        error: result.error,
      );
    }

    final pages = result.pages
        .map((p) => PdfPageText(pageNumber: p.pageNumber, text: p.text, sentences: p.sentences))
        .toList();

    return PdfExtractResult(
      pages: pages,
      totalPages: pages.length,
      pagesWithText: pages.where((p) => p.isNotEmpty).length,
      usedAiOcr: true,
    );
  }

  Future<PdfExtractResult> _extractWithAiOcr(Uint8List bytes) async {
    final result = await _geminiService.extractTextFromPdf(bytes);

    if (result.hasError) {
      return PdfExtractResult(
        pages: [],
        totalPages: 0,
        pagesWithText: 0,
        error: result.error,
      );
    }

    final pages = result.pages
        .map((p) => PdfPageText(pageNumber: p.pageNumber, text: p.text, sentences: p.sentences))
        .toList();

    return PdfExtractResult(
      pages: pages,
      totalPages: pages.length,
      pagesWithText: pages.where((p) => p.isNotEmpty).length,
      usedAiOcr: true,
    );
  }

  static List<String> _splitSentences(String text) {
    if (text.trim().isEmpty) return [];
    final raw = text
        .replaceAll(RegExp(r'\r\n|\r'), '\n')
        .split(RegExp(r'(?<=[.!?।])\s+'))
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();
    if (raw.length <= 1 && text.contains('\n')) {
      return text
          .split('\n')
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty)
          .toList();
    }
    return raw;
  }
}
