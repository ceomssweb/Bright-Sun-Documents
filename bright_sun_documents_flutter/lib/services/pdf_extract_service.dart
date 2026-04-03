import 'dart:typed_data';
import 'package:syncfusion_flutter_pdf/pdf.dart';

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

  const PdfExtractResult({
    required this.pages,
    required this.totalPages,
    required this.pagesWithText,
    this.error,
  });

  bool get hasText => pagesWithText > 0;
  bool get hasError => error != null;
  String get allText => pages.where((p) => p.isNotEmpty).map((p) => p.text).join('\n\n');
}

class PdfExtractService {
  Future<PdfExtractResult> extractPagesFromBytes(Uint8List bytes) async {
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
        return PdfExtractResult(
          pages: pages,
          totalPages: totalPages,
          pagesWithText: 0,
          error: 'No text could be extracted from this PDF. '
              'The document may contain scanned images instead of selectable text. '
              'Try using the "Type Text" mode to manually enter the content.',
        );
      }

      return PdfExtractResult(
        pages: pages,
        totalPages: totalPages,
        pagesWithText: pagesWithText,
      );
    } catch (e) {
      return PdfExtractResult(
        pages: [],
        totalPages: 0,
        pagesWithText: 0,
        error: 'Failed to read the PDF file. The file may be corrupted or password-protected.',
      );
    }
  }

  static List<String> _splitSentences(String text) {
    if (text.trim().isEmpty) return [];
    final raw = text
        .replaceAll(RegExp(r'\r\n|\r'), '\n')
        .split(RegExp(r'(?<=[.!?।])\s+'))
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();
    // If no sentence boundaries found, split by newlines
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
