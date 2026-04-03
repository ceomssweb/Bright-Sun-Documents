import 'dart:typed_data';
import 'package:syncfusion_flutter_pdf/pdf.dart';

class PdfExtractService {
  Future<String> extractTextFromBytes(Uint8List bytes) async {
    final PdfDocument document = PdfDocument(inputBytes: bytes);
    String fullText = '';
    for (int i = 0; i < document.pages.count; i++) {
      final String pageText =
          PdfTextExtractor(document).extractText(startPageIndex: i, endPageIndex: i);
      fullText += '--- Page ${i + 1} ---\n$pageText\n\n';
    }
    document.dispose();
    return fullText;
  }
}
