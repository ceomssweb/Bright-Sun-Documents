import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../../services/pdf_extract_service.dart';
import '../../services/translation_service.dart';
import '../../widgets/header_widget.dart';
import '../../widgets/footer_widget.dart';
import '../../theme/app_theme.dart';

class TranslateDocumentScreen extends StatefulWidget {
  const TranslateDocumentScreen({super.key});

  @override
  State<TranslateDocumentScreen> createState() =>
      _TranslateDocumentScreenState();
}

class _TranslateDocumentScreenState extends State<TranslateDocumentScreen> {
  final _pdfService = PdfExtractService();
  final _translationService = TranslationService();
  final _manualTextController = TextEditingController();

  String _sourceLang = 'ta';
  String _targetLang = 'en';
  String _extractedText = '';
  String _translatedText = '';
  String _fileName = '';
  String _errorMessage = '';
  bool _isExtracting = false;
  bool _isTranslating = false;
  bool _isPdfMode = true; // true = PDF, false = manual

  @override
  void dispose() {
    _manualTextController.dispose();
    super.dispose();
  }

  Future<void> _pickPdf() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
      withData: true,
    );
    if (result != null && result.files.single.bytes != null) {
      setState(() {
        _fileName = result.files.single.name;
        _errorMessage = '';
      });
      await _extractText(result.files.single.bytes!);
    }
  }

  Future<void> _extractText(Uint8List bytes) async {
    setState(() {
      _isExtracting = true;
      _extractedText = '';
      _translatedText = '';
    });
    try {
      final text = await _pdfService.extractTextFromBytes(bytes);
      setState(() {
        _extractedText = text;
        if (text.trim().isEmpty) {
          _errorMessage =
              'No text could be extracted. The PDF may contain scanned images.';
        }
      });
    } catch (e) {
      setState(() =>
          _errorMessage = 'Failed to extract text from PDF.');
    } finally {
      setState(() => _isExtracting = false);
    }
  }

  Future<void> _translate() async {
    final text =
        _isPdfMode ? _extractedText : _manualTextController.text;
    if (text.trim().isEmpty) {
      setState(() => _errorMessage = 'No text available to translate.');
      return;
    }
    if (_sourceLang == _targetLang) {
      setState(() =>
          _errorMessage = 'Source and target languages must be different.');
      return;
    }

    setState(() {
      _errorMessage = '';
      _isTranslating = true;
      _translatedText = '';
    });

    try {
      final result = await _translationService.translateText(
          text, _sourceLang, _targetLang);
      setState(() => _translatedText = result.translatedText);
    } catch (e) {
      setState(
          () => _errorMessage = 'Translation failed. Please try again.');
    } finally {
      setState(() => _isTranslating = false);
    }
  }

  void _swapLanguages() {
    setState(() {
      final temp = _sourceLang;
      _sourceLang = _targetLang;
      _targetLang = temp;
    });
  }

  void _clearAll() {
    setState(() {
      _extractedText = '';
      _translatedText = '';
      _manualTextController.clear();
      _fileName = '';
      _errorMessage = '';
    });
  }

  void _copyTranslation() {
    if (_translatedText.isNotEmpty) {
      Clipboard.setData(ClipboardData(text: _translatedText));
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Copied to clipboard!')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthService>();
    final languages = TranslationService.supportedLanguages;

    return Scaffold(
      appBar: HeaderWidget(authService: auth),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1200),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Document Translator',
                        style:
                            Theme.of(context).textTheme.headlineMedium),
                    const SizedBox(height: 4),
                    const Text(
                        'Upload a PDF or type text to translate between languages',
                        style: TextStyle(color: Colors.grey)),
                    const SizedBox(height: 16),

                    // Mode toggle
                    Row(
                      children: [
                        ChoiceChip(
                          label: const Text('Upload PDF'),
                          selected: _isPdfMode,
                          onSelected: (_) {
                            _clearAll();
                            setState(() => _isPdfMode = true);
                          },
                        ),
                        const SizedBox(width: 8),
                        ChoiceChip(
                          label: const Text('Type Text'),
                          selected: !_isPdfMode,
                          onSelected: (_) {
                            _clearAll();
                            setState(() => _isPdfMode = false);
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Language selection
                    LayoutBuilder(builder: (context, constraints) {
                      return Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              initialValue: _sourceLang,
                              decoration: const InputDecoration(
                                  labelText: 'Source Language'),
                              items: languages
                                  .map((l) => DropdownMenuItem(
                                      value: l.code,
                                      child: Text(l.name)))
                                  .toList(),
                              onChanged: (v) =>
                                  setState(() => _sourceLang = v!),
                            ),
                          ),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 8),
                            child: IconButton(
                              onPressed: _swapLanguages,
                              icon: const Icon(Icons.swap_horiz),
                              tooltip: 'Swap languages',
                            ),
                          ),
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              initialValue: _targetLang,
                              decoration: const InputDecoration(
                                  labelText: 'Target Language'),
                              items: languages
                                  .map((l) => DropdownMenuItem(
                                      value: l.code,
                                      child: Text(l.name)))
                                  .toList(),
                              onChanged: (v) =>
                                  setState(() => _targetLang = v!),
                            ),
                          ),
                        ],
                      );
                    }),
                    const SizedBox(height: 16),

                    // PDF upload area
                    if (_isPdfMode)
                      InkWell(
                        onTap: _pickPdf,
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(40),
                          decoration: BoxDecoration(
                            border: Border.all(
                                color: Colors.grey.shade400,
                                style: BorderStyle.solid,
                                width: 2),
                            borderRadius: BorderRadius.circular(8),
                            color: Colors.grey.shade50,
                          ),
                          child: Column(
                            children: [
                              const Icon(Icons.cloud_upload,
                                  size: 48, color: AppTheme.primaryColor),
                              const SizedBox(height: 8),
                              Text(_fileName.isEmpty
                                  ? 'Click to upload a PDF file'
                                  : _fileName),
                            ],
                          ),
                        ),
                      ),

                    // Manual text input
                    if (!_isPdfMode)
                      TextField(
                        controller: _manualTextController,
                        maxLines: 6,
                        decoration: const InputDecoration(
                          hintText:
                              'Type or paste text here to translate...',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    const SizedBox(height: 12),

                    // Loading
                    if (_isExtracting)
                      const Center(
                        child: Column(
                          children: [
                            CircularProgressIndicator(),
                            SizedBox(height: 8),
                            Text('Extracting text from PDF...'),
                          ],
                        ),
                      ),

                    // Error
                    if (_errorMessage.isNotEmpty)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          border: Border.all(color: Colors.red.shade200),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(_errorMessage,
                            style: const TextStyle(color: Colors.red)),
                      ),

                    // Actions
                    Wrap(
                      spacing: 8,
                      children: [
                        ElevatedButton.icon(
                          onPressed: (_isTranslating ||
                                  _isExtracting ||
                                  (_extractedText.isEmpty &&
                                      _manualTextController.text.isEmpty))
                              ? null
                              : _translate,
                          icon: _isTranslating
                              ? const SizedBox(
                                  height: 16,
                                  width: 16,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2, color: Colors.white))
                              : const Icon(Icons.translate),
                          label: Text(
                              _isTranslating ? 'Translating...' : 'Translate'),
                        ),
                        OutlinedButton.icon(
                          onPressed: _clearAll,
                          icon: const Icon(Icons.refresh),
                          label: const Text('Clear'),
                        ),
                        if (_translatedText.isNotEmpty)
                          OutlinedButton.icon(
                            onPressed: _copyTranslation,
                            icon: const Icon(Icons.copy),
                            label: const Text('Copy Translation'),
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Results side by side
                    if (_extractedText.isNotEmpty ||
                        _translatedText.isNotEmpty)
                      LayoutBuilder(builder: (context, constraints) {
                        final isWide = constraints.maxWidth > 700;
                        final panels = <Widget>[
                          if (_isPdfMode && _extractedText.isNotEmpty)
                            _resultCard(
                              'Extracted Text (${TranslationService.getLanguageName(_sourceLang)})',
                              _extractedText,
                            ),
                          if (_translatedText.isNotEmpty)
                            _resultCard(
                              'Translated Text (${TranslationService.getLanguageName(_targetLang)})',
                              _translatedText,
                            ),
                        ];
                        if (isWide && panels.length == 2) {
                          return Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: panels
                                .map((p) => Expanded(
                                    child: Padding(
                                        padding: const EdgeInsets.all(4),
                                        child: p)))
                                .toList(),
                          );
                        }
                        return Column(
                            children: panels
                                .map((p) => Padding(
                                    padding:
                                        const EdgeInsets.only(bottom: 8),
                                    child: p))
                                .toList());
                      }),
                  ],
                ),
              ),
            ),
          ),
          const FooterWidget(),
        ],
      ),
    );
  }

  Widget _resultCard(String title, String text) {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            color: AppTheme.primaryColor,
            child: Text(title,
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold)),
          ),
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 400),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(12),
              child: SelectableText(text),
            ),
          ),
        ],
      ),
    );
  }
}
