import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:file_picker/file_picker.dart';
import '../../services/pdf_extract_service.dart';
import '../../services/translation_service.dart';
import '../../services/gemini_service.dart';
import '../../theme/app_theme.dart';

class TranslateScreen extends StatefulWidget {
  const TranslateScreen({super.key});

  @override
  State<TranslateScreen> createState() => _TranslateScreenState();
}

class _TranslateScreenState extends State<TranslateScreen> with SingleTickerProviderStateMixin {
  final _pdfService = PdfExtractService();
  final _translationService = TranslationService();
  final _geminiService = GeminiService();

  bool _isManualMode = false;

  String? _fileName;
  Uint8List? _fileBytes;
  PdfExtractResult? _extractResult;
  bool _extracting = false;
  bool _usedAiOcr = false;

  int _currentPage = 0;

  final Set<int> _selectedSentenceIndices = {};
  bool _selectAll = false;
  final _manualTextCtrl = TextEditingController();
  final _editedTextCtrl = TextEditingController();

  String _sourceLang = 'auto';
  String _targetLang = 'en';
  bool _translating = false;
  String? _translatedText;
  String? _translationError;
  String? _detectedLangName;
  TranslationEngine? _lastEngine;

  late TabController _tabCtrl;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);
    _tabCtrl.addListener(() {
      setState(() => _isManualMode = _tabCtrl.index == 1);
    });
    _geminiService.initialize();
  }

  @override
  void dispose() {
    _manualTextCtrl.dispose();
    _editedTextCtrl.dispose();
    _tabCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png', 'gif', 'bmp', 'webp', 'tiff'],
      withData: true,
    );
    if (result == null || result.files.isEmpty) return;

    final file = result.files.first;
    final Uint8List? bytes = file.bytes;
    if (bytes == null) {
      _showSnack('Could not read the file.', isError: true);
      return;
    }

    setState(() {
      _extracting = true;
      _fileName = file.name;
      _fileBytes = bytes;
      _extractResult = null;
      _currentPage = 0;
      _selectedSentenceIndices.clear();
      _translatedText = null;
      _translationError = null;
      _usedAiOcr = false;
      _detectedLangName = null;
    });

    try {
      final ext = file.extension?.toLowerCase() ?? '';
      PdfExtractResult extractResult;

      if (ext == 'pdf') {
        extractResult = await _pdfService.extractPagesFromBytes(bytes);
      } else {
        final mimeMap = {
          'jpg': 'image/jpeg', 'jpeg': 'image/jpeg', 'png': 'image/png',
          'gif': 'image/gif', 'bmp': 'image/bmp', 'webp': 'image/webp', 'tiff': 'image/tiff',
        };
        extractResult = await _pdfService.extractTextFromImage(bytes, mimeMap[ext] ?? 'image/jpeg');
      }

      setState(() {
        _extractResult = extractResult;
        _extracting = false;
        _usedAiOcr = extractResult.usedAiOcr;
      });

      if (extractResult.hasText && extractResult.pages.isNotEmpty) {
        _updateEditedText();
        _autoDetectLanguage(extractResult.pages.first.text);
      }
    } catch (e) {
      setState(() => _extracting = false);
      _showSnack('Extraction failed: $e', isError: true);
    }
  }

  Future<void> _retryWithAiOcr() async {
    if (_fileBytes == null) return;
    if (!_geminiService.isConfigured) {
      _showSnack('Configure Gemini API key in Settings first.', isError: true);
      return;
    }

    setState(() {
      _extracting = true;
      _extractResult = null;
      _translatedText = null;
      _translationError = null;
    });

    try {
      final extractResult = await _pdfService.extractPagesFromBytes(_fileBytes!, forceAiOcr: true);
      setState(() {
        _extractResult = extractResult;
        _extracting = false;
        _usedAiOcr = true;
      });

      if (extractResult.hasText && extractResult.pages.isNotEmpty) {
        _updateEditedText();
        _autoDetectLanguage(extractResult.pages.first.text);
      }
    } catch (e) {
      setState(() => _extracting = false);
      _showSnack('AI OCR failed: $e', isError: true);
    }
  }

  Future<void> _autoDetectLanguage(String text) async {
    if (!_geminiService.isConfigured || text.trim().isEmpty) return;
    final result = await _geminiService.detectLanguage(text.substring(0, text.length.clamp(0, 500)));
    if (result.isDetected && mounted) {
      setState(() => _detectedLangName = result.name);
    }
  }

  List<String> get _currentPageSentences {
    if (_extractResult == null || _extractResult!.pages.isEmpty) return [];
    if (_currentPage >= _extractResult!.pages.length) return [];
    return _extractResult!.pages[_currentPage].sentences;
  }

  void _updateEditedText() {
    final sentences = _currentPageSentences;
    if (_selectAll || _selectedSentenceIndices.isEmpty) {
      _editedTextCtrl.text = sentences.join(' ');
    } else {
      final sorted = _selectedSentenceIndices.toList()..sort();
      _editedTextCtrl.text = sorted.map((i) => sentences[i]).join(' ');
    }
  }

  void _toggleSentence(int index) {
    setState(() {
      if (_selectedSentenceIndices.contains(index)) {
        _selectedSentenceIndices.remove(index);
      } else {
        _selectedSentenceIndices.add(index);
      }
      _selectAll = _selectedSentenceIndices.length == _currentPageSentences.length;
      _updateEditedText();
    });
  }

  void _toggleSelectAll() {
    setState(() {
      _selectAll = !_selectAll;
      _selectedSentenceIndices.clear();
      if (_selectAll) {
        _selectedSentenceIndices.addAll(List.generate(_currentPageSentences.length, (i) => i));
      }
      _updateEditedText();
    });
  }

  void _goToPage(int page) {
    if (page < 0 || _extractResult == null || page >= _extractResult!.pages.length) return;
    setState(() {
      _currentPage = page;
      _selectedSentenceIndices.clear();
      _selectAll = false;
      _translatedText = null;
      _translationError = null;
      _updateEditedText();
    });
  }

  void _swapLanguages() {
    setState(() {
      if (_sourceLang == 'auto') return;
      final temp = _sourceLang;
      _sourceLang = _targetLang;
      _targetLang = temp;
    });
  }

  Future<void> _translate() async {
    final text = _isManualMode ? _manualTextCtrl.text.trim() : _editedTextCtrl.text.trim();
    if (text.isEmpty) {
      _showSnack('No text to translate', isError: true);
      return;
    }

    setState(() {
      _translating = true;
      _translatedText = null;
      _translationError = null;
      _lastEngine = null;
    });

    final result = await _translationService.translateText(text, _sourceLang, _targetLang);

    if (!mounted) return;
    setState(() {
      _translating = false;
      if (result.success) {
        _translatedText = result.translatedText;
        _lastEngine = result.engine;
        if (_sourceLang == 'auto' && result.sourceLanguage != 'auto') {
          final detected = TranslationService.supportedLanguages.where((l) => l.code == result.sourceLanguage);
          if (detected.isNotEmpty) {
            _detectedLangName = detected.first.name;
          }
        }
      } else {
        _translationError = result.error;
      }
    });
  }

  void _showSnack(String msg, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: isError ? AppTheme.error : null, duration: const Duration(seconds: 2)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 900;
    final aiReady = _geminiService.isConfigured;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 6, offset: const Offset(0, 2))],
            ),
            child: LayoutBuilder(
              builder: (context, constraints) {
                return Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.translate, color: AppTheme.primary, size: 22),
                        const SizedBox(width: 8),
                        const Text('Translation Studio', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                        if (aiReady) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppTheme.success.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.auto_awesome, size: 12, color: AppTheme.success),
                                SizedBox(width: 3),
                                Text('AI', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppTheme.success)),
                              ],
                            ),
                          ),
                        ],
                        if (!aiReady) ...[
                          const SizedBox(width: 8),
                          Tooltip(
                            message: 'Add Gemini API key in Settings for AI OCR & translation',
                            child: Icon(Icons.info_outline, size: 16, color: Colors.orange.shade400),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(width: 16),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _LanguageDropdown(
                          value: _sourceLang,
                          languages: TranslationService.sourceLanguages,
                          onChanged: (v) => setState(() => _sourceLang = v!),
                          label: _detectedLangName != null && _sourceLang == 'auto' ? 'Auto ($_detectedLangName)' : null,
                        ),
                        IconButton(
                          onPressed: _swapLanguages,
                          icon: const Icon(Icons.swap_horiz, color: AppTheme.primary),
                          tooltip: 'Swap languages',
                          visualDensity: VisualDensity.compact,
                        ),
                        _LanguageDropdown(
                          value: _targetLang,
                          languages: TranslationService.targetLanguages,
                          onChanged: (v) => setState(() => _targetLang = v!),
                        ),
                      ],
                    ),
                    const SizedBox(width: 8),
                    FilledButton.icon(
                      onPressed: _translating ? null : _translate,
                      icon: _translating
                          ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : const Icon(Icons.translate, size: 18),
                      label: Text(_translating ? 'Translating...' : 'Translate'),
                    ),
                  ],
                );
              },
            ),
          ),
          Container(
            color: Colors.white,
            child: TabBar(
              controller: _tabCtrl,
              labelColor: AppTheme.primary,
              unselectedLabelColor: Colors.grey.shade600,
              indicatorColor: AppTheme.primary,
              tabs: const [
                Tab(icon: Icon(Icons.document_scanner, size: 18), text: 'File Extract'),
                Tab(icon: Icon(Icons.edit_note, size: 18), text: 'Type Text'),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabCtrl,
              children: [
                isWide
                    ? Row(children: [Expanded(child: _buildFilePanel()), const VerticalDivider(width: 1), Expanded(child: _buildTranslationPanel())])
                    : SingleChildScrollView(child: Column(children: [_buildFilePanel(), const Divider(), _buildTranslationPanel()])),
                isWide
                    ? Row(children: [Expanded(child: _buildManualPanel()), const VerticalDivider(width: 1), Expanded(child: _buildTranslationPanel())])
                    : SingleChildScrollView(child: Column(children: [_buildManualPanel(), const Divider(), _buildTranslationPanel()])),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilePanel() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: _extracting ? null : _pickFile,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppTheme.primary.withValues(alpha: 0.03),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.primary.withValues(alpha: 0.2)),
              ),
              child: Column(
                children: [
                  Icon(_extracting ? Icons.hourglass_empty : Icons.upload_file, size: 36, color: AppTheme.primary.withValues(alpha: 0.6)),
                  const SizedBox(height: 8),
                  Text(
                    _extracting ? 'Extracting text...' : (_fileName ?? 'Click to upload file'),
                    style: TextStyle(fontWeight: FontWeight.w600, color: AppTheme.primary.withValues(alpha: 0.8)),
                  ),
                  if (!_extracting) Text('PDF, JPG, PNG, GIF, BMP, WEBP, TIFF', style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
                  if (_extracting) const Padding(padding: EdgeInsets.only(top: 8), child: LinearProgressIndicator()),
                  if (_usedAiOcr && !_extracting)
                    Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(color: Colors.deepPurple.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(4)),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.auto_awesome, size: 12, color: Colors.deepPurple),
                            SizedBox(width: 4),
                            Text('Extracted with AI OCR', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Colors.deepPurple)),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          if (_extractResult != null && _extractResult!.hasError) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: AppTheme.error.withValues(alpha: 0.07), borderRadius: BorderRadius.circular(8)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.warning_amber_rounded, color: AppTheme.error, size: 20),
                      const SizedBox(width: 8),
                      Expanded(child: Text(_extractResult!.error!, style: const TextStyle(fontSize: 12, color: AppTheme.error))),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      if (_geminiService.isConfigured)
                        FilledButton.icon(
                          onPressed: _retryWithAiOcr,
                          icon: const Icon(Icons.auto_awesome, size: 16),
                          label: const Text('Try AI OCR', style: TextStyle(fontSize: 12)),
                          style: FilledButton.styleFrom(backgroundColor: Colors.deepPurple, padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8)),
                        ),
                      OutlinedButton.icon(
                        onPressed: () => _tabCtrl.animateTo(1),
                        icon: const Icon(Icons.edit_note, size: 16),
                        label: const Text('Type Text', style: TextStyle(fontSize: 12)),
                        style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
          if (_extractResult != null && _extractResult!.hasText) ...[
            const SizedBox(height: 16),
            Row(
              children: [
                Text('Page ${_currentPage + 1} of ${_extractResult!.totalPages}', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                const SizedBox(width: 4),
                Text('(${_extractResult!.pagesWithText} with text)', style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
                if (_detectedLangName != null) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(color: Colors.blue.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(4)),
                    child: Text('Detected: $_detectedLangName', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Colors.blue)),
                  ),
                ],
                const Spacer(),
                IconButton(onPressed: _currentPage > 0 ? () => _goToPage(_currentPage - 1) : null, icon: const Icon(Icons.chevron_left, size: 22), visualDensity: VisualDensity.compact, tooltip: 'Previous page'),
                IconButton(onPressed: _currentPage < (_extractResult!.totalPages - 1) ? () => _goToPage(_currentPage + 1) : null, icon: const Icon(Icons.chevron_right, size: 22), visualDensity: VisualDensity.compact, tooltip: 'Next page'),
              ],
            ),
            if (_extractResult!.totalPages > 1 && _extractResult!.totalPages <= 20) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 4,
                children: List.generate(_extractResult!.totalPages, (i) {
                  return GestureDetector(
                    onTap: () => _goToPage(i),
                    child: Container(
                      width: 22, height: 22, alignment: Alignment.center,
                      decoration: BoxDecoration(color: i == _currentPage ? AppTheme.primary : Colors.grey.shade200, borderRadius: BorderRadius.circular(4)),
                      child: Text('${i + 1}', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: i == _currentPage ? Colors.white : Colors.grey.shade700)),
                    ),
                  );
                }),
              ),
            ],
            const SizedBox(height: 12),
            Row(
              children: [
                Checkbox(value: _selectAll, onChanged: (_) => _toggleSelectAll(), visualDensity: VisualDensity.compact),
                const Text('Select All', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                const Spacer(),
                Text('${_selectedSentenceIndices.length} / ${_currentPageSentences.length} selected', style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
              ],
            ),
            const SizedBox(height: 4),
            if (_currentPageSentences.isEmpty)
              const Padding(padding: EdgeInsets.all(20), child: Text('No text on this page.', style: TextStyle(color: Colors.grey)))
            else
              Container(
                constraints: const BoxConstraints(maxHeight: 250),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey.shade200)),
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: _currentPageSentences.length,
                  separatorBuilder: (_, __) => Divider(height: 1, color: Colors.grey.shade100),
                  itemBuilder: (context, i) {
                    final selected = _selectedSentenceIndices.contains(i);
                    return InkWell(
                      onTap: () => _toggleSentence(i),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        color: selected ? AppTheme.primary.withValues(alpha: 0.05) : null,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Checkbox(value: selected, onChanged: (_) => _toggleSentence(i), visualDensity: VisualDensity.compact),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(top: 6),
                                child: Text(_currentPageSentences[i], style: TextStyle(fontSize: 12, height: 1.5, color: selected ? AppTheme.tertiary : Colors.grey.shade700, fontWeight: selected ? FontWeight.w600 : FontWeight.normal)),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            const SizedBox(height: 12),
            const Row(children: [Icon(Icons.edit, size: 14, color: AppTheme.primary), SizedBox(width: 4), Text('Fine-tune selected text', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600))]),
            const SizedBox(height: 6),
            TextField(
              controller: _editedTextCtrl, maxLines: 4,
              style: const TextStyle(fontSize: 12, height: 1.6),
              decoration: InputDecoration(hintText: 'Selected text appears here. Edit before translating.', filled: true, fillColor: Colors.white, border: OutlineInputBorder(borderRadius: BorderRadius.circular(8))),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildManualPanel() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(children: [Icon(Icons.keyboard, size: 16, color: AppTheme.primary), SizedBox(width: 6), Text('Type or paste text to translate', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13))]),
          const SizedBox(height: 10),
          TextField(
            controller: _manualTextCtrl, maxLines: 12,
            style: const TextStyle(fontSize: 13, height: 1.6),
            decoration: InputDecoration(hintText: 'Enter text here...', filled: true, fillColor: Colors.white, border: OutlineInputBorder(borderRadius: BorderRadius.circular(8))),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton.icon(onPressed: () { _manualTextCtrl.clear(); setState(() { _translatedText = null; _translationError = null; }); }, icon: const Icon(Icons.clear, size: 16), label: const Text('Clear')),
              const SizedBox(width: 8),
              TextButton.icon(
                onPressed: () async { final data = await Clipboard.getData(Clipboard.kTextPlain); if (data?.text != null) _manualTextCtrl.text = data!.text!; },
                icon: const Icon(Icons.content_paste, size: 16), label: const Text('Paste'),
              ),
              if (_geminiService.isConfigured) ...[
                const SizedBox(width: 8),
                TextButton.icon(
                  onPressed: () { final text = _manualTextCtrl.text.trim(); if (text.isEmpty) return; _autoDetectLanguage(text); _showSnack('Detecting language...'); },
                  icon: const Icon(Icons.language, size: 16), label: const Text('Detect'),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTranslationPanel() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.g_translate, size: 16, color: AppTheme.secondary),
              const SizedBox(width: 6),
              const Text('Translation Result', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
              if (_lastEngine != null) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: _lastEngine == TranslationEngine.geminiAi ? Colors.deepPurple.withValues(alpha: 0.08) : Colors.orange.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    _lastEngine == TranslationEngine.geminiAi ? 'Gemini AI' : 'MyMemory',
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: _lastEngine == TranslationEngine.geminiAi ? Colors.deepPurple : Colors.orange.shade800),
                  ),
                ),
              ],
              const Spacer(),
              if (_translatedText != null)
                TextButton.icon(
                  onPressed: () { Clipboard.setData(ClipboardData(text: _translatedText!)); _showSnack('Copied to clipboard!'); },
                  icon: const Icon(Icons.copy, size: 14), label: const Text('Copy', style: TextStyle(fontSize: 12)),
                ),
            ],
          ),
          const SizedBox(height: 10),
          if (_translating)
            Container(
              width: double.infinity, padding: const EdgeInsets.all(40),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey.shade200)),
              child: Column(children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 12),
                Text(_geminiService.isConfigured ? 'AI is translating...' : 'Translating...', style: const TextStyle(color: Colors.grey)),
              ]),
            )
          else if (_translationError != null)
            Container(
              width: double.infinity, padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: AppTheme.error.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(8), border: Border.all(color: AppTheme.error.withValues(alpha: 0.3))),
              child: Column(children: [
                const Icon(Icons.error_outline, color: AppTheme.error, size: 28),
                const SizedBox(height: 8),
                Text(_translationError!, style: const TextStyle(fontSize: 12, color: AppTheme.error)),
              ]),
            )
          else if (_translatedText != null)
            Container(
              width: double.infinity, padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: AppTheme.success.withValues(alpha: 0.3))),
              child: SelectableText(_translatedText!, style: const TextStyle(fontSize: 13, height: 1.7)),
            )
          else
            Container(
              width: double.infinity, padding: const EdgeInsets.all(40),
              decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey.shade200)),
              child: Column(children: [
                Icon(Icons.translate, size: 36, color: Colors.grey.shade300),
                const SizedBox(height: 8),
                Text(_isManualMode ? 'Type text and click Translate' : 'Upload a file and click Translate', style: TextStyle(color: Colors.grey.shade500, fontSize: 13)),
                if (_geminiService.isConfigured) ...[
                  const SizedBox(height: 4),
                  Text('Powered by Gemini AI', style: TextStyle(color: Colors.deepPurple.withValues(alpha: 0.4), fontSize: 11)),
                ],
              ]),
            ),
        ],
      ),
    );
  }
}

class _LanguageDropdown extends StatelessWidget {
  final String value;
  final List<Language> languages;
  final ValueChanged<String?> onChanged;
  final String? label;

  const _LanguageDropdown({required this.value, required this.languages, required this.onChanged, this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(8)),
      child: DropdownButton<String>(
        value: value,
        underline: const SizedBox.shrink(),
        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.tertiary),
        items: languages.map((l) {
          return DropdownMenuItem(
            value: l.code,
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              if (l.code == 'auto') const Icon(Icons.auto_awesome, size: 14, color: Colors.deepPurple),
              if (l.code == 'auto') const SizedBox(width: 4),
              Text(l.name),
            ]),
          );
        }).toList(),
        onChanged: onChanged,
      ),
    );
  }
}
