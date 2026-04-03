import 'dart:typed_data';
import 'package:syncfusion_flutter_pdf/pdf.dart';

class PdfPageText {
  final int pageNumber;
  final String text;
  final List<String> sentences;

  PdfPageText({
    required this.pageNumber,
    required this.text,
    required this.sentences,
  });
}

class PdfExtractService {
  /// Extract text from each page, returning a list of [PdfPageText].
  Future<List<PdfPageText>> extractPagesFromBytes(Uint8List bytes) async {
    final PdfDocument document = PdfDocument(inputBytes: bytes);
    final pages = <PdfPageText>[];
    for (int i = 0; i < document.pages.count; i++) {
      final String pageText = PdfTextExtractor(document)
          .extractText(startPageIndex: i, endPageIndex: i);
      final sentences = _splitSentences(pageText);
      pages.add(PdfPageText(
        pageNumber: i + 1,
        text: pageText,
        sentences: sentences,
      ));
    }
    document.dispose();
    return pages;
  }

  /// Legacy method - returns all text concatenated.
  Future<String> extractTextFromBytes(Uint8List bytes) async {
    final pages = await extractPagesFromBytes(bytes);
    return pages
        .map((p) => '--- Page ${p.pageNumber} ---\n${p.text}')
        .join('\n\n');
  }

  /// Split text into sentences for granular selection.
  static List<String> _splitSentences(String text) {
    if (text.trim().isEmpty) return [];
    // Split on sentence-ending punctuation followed by space/newline
    final raw = text
        .replaceAll(RegExp(r'\r\n|\r'), '\n')
        .split(RegExp(r'(?<=[.!?।])\s+'))
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();
    return raw;
  }
}
