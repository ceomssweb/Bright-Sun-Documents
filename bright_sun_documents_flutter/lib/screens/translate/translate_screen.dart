import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:file_picker/file_picker.dart';
import '../../services/pdf_extract_service.dart';
import '../../services/translation_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';

class TranslateScreen extends StatefulWidget {
  const TranslateScreen({super.key});

  @override
  State<TranslateScreen> createState() => _TranslateScreenState();
}

class _TranslateScreenState extends State<TranslateScreen> with SingleTickerProviderStateMixin {
  // Services
  final _pdfService = PdfExtractService();
  final _translationService = TranslationService();

  // Mode
  bool _isManualMode = false;

  // PDF state
  String? _fileName;
  PdfExtractResult? _extractResult;
  bool _extracting = false;

  // Page navigation
  int _currentPage = 0;

  // Text selection
  final Set<int> _selectedSentenceIndices = {};
  bool _selectAll = false;
  final _manualTextCtrl = TextEditingController();
  final _editedTextCtrl = TextEditingController();

  // Translation
  String _sourceLang = 'ta';
  String _targetLang = 'en';
  bool _translating = false;
  String? _translatedText;
  String? _translationError;

  // Tab
  late TabController _tabCtrl;

  static const _languages = {
    'ta': 'Tamil',
    'en': 'English',
    'hi': 'Hindi',
    'te': 'Telugu',
    'kn': 'Kannada',
    'ml': 'Malayalam',
    'mr': 'Marathi',
    'bn': 'Bengali',
    'gu': 'Gujarati',
    'pa': 'Punjabi',
    'ur': 'Urdu',
    'fr': 'French',
    'de': 'German',
    'es': 'Spanish',
    'ar': 'Arabic',
  };

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);
    _tabCtrl.addListener(() {
      setState(() => _isManualMode = _tabCtrl.index == 1);
    });
  }

  @override
  void dispose() {
    _manualTextCtrl.dispose();
    _editedTextCtrl.dispose();
    _tabCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickAndExtractPdf() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
      withData: true,
    );
    if (result == null || result.files.isEmpty) return;

    final file = result.files.first;
    final Uint8List? bytes = file.bytes;
    if (bytes == null) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Could not read the file.'), backgroundColor: AppTheme.error));
      return;
    }

    setState(() { _extracting = true; _fileName = file.name; _extractResult = null; _currentPage = 0; _selectedSentenceIndices.clear(); _translatedText = null; _translationError = null; });

    try {
      final extractResult = await _pdfService.extractPagesFromBytes(bytes);
      setState(() { _extractResult = extractResult; _extracting = false; });

      if (extractResult.hasText && extractResult.pages.isNotEmpty) {
        _updateEditedText();
      }
    } catch (e) {
      setState(() { _extracting = false; });
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Extraction failed: $e'), backgroundColor: AppTheme.error));
    }
  }

  List<String> get _currentPageSentences {
    if (_extractResult == null || _extractResult!.pages.isEmpty) return [];
    if (_currentPage >= _extractResult!.pages.length) return [];
    return _extractResult!.pages[_currentPage].sentences;
  }

  void _updateEditedText() {
    final sentences = _currentPageSentences;
    if (_selectAll) {
      _editedTextCtrl.text = sentences.join(' ');
    } else if (_selectedSentenceIndices.isEmpty) {
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
      final temp = _sourceLang;
      _sourceLang = _targetLang;
      _targetLang = temp;
    });
  }

  Future<void> _translate() async {
    final text = _isManualMode ? _manualTextCtrl.text.trim() : _editedTextCtrl.text.trim();
    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No text to translate'), backgroundColor: AppTheme.warning));
      return;
    }

    setState(() { _translating = true; _translatedText = null; _translationError = null; });

    final result = await _translationService.translateText(text, _sourceLang, _targetLang);

    setState(() {
      _translating = false;
      if (result.success) {
        _translatedText = result.translatedText;
      } else {
        _translationError = result.error;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 900;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      body: Column(
        children: [
          // Top bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 6, offset: const Offset(0, 2))],
            ),
            child: Row(
              children: [
                const Icon(Icons.translate, color: AppTheme.primary),
                const SizedBox(width: 10),
                const Text('Translation Studio', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
                const Spacer(),
                // Language controls
                _LanguageDropdown(value: _sourceLang, languages: _languages, onChanged: (v) => setState(() => _sourceLang = v!)),
                IconButton(
                  onPressed: _swapLanguages,
                  icon: const Icon(Icons.swap_horiz, color: AppTheme.primary),
                  tooltip: 'Swap languages',
                ),
                _LanguageDropdown(value: _targetLang, languages: _languages, onChanged: (v) => setState(() => _targetLang = v!)),
                const SizedBox(width: 12),
                FilledButton.icon(
                  onPressed: _translating ? null : _translate,
                  icon: _translating
                      ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Icon(Icons.translate, size: 18),
                  label: Text(_translating ? 'Translating...' : 'Translate'),
                ),
              ],
            ),
          ),

          // Tab bar
          Container(
            color: Colors.white,
            child: TabBar(
              controller: _tabCtrl,
              labelColor: AppTheme.primary,
              unselectedLabelColor: Colors.grey.shade600,
              indicatorColor: AppTheme.primary,
              tabs: const [
                Tab(icon: Icon(Icons.picture_as_pdf, size: 18), text: 'PDF Extract'),
                Tab(icon: Icon(Icons.edit_note, size: 18), text: 'Type Text'),
              ],
            ),
          ),

          // Body
          Expanded(
            child: TabBarView(
              controller: _tabCtrl,
              children: [
                // PDF mode
                isWide
                    ? Row(children: [Expanded(child: _buildPdfPanel()), const VerticalDivider(width: 1), Expanded(child: _buildTranslationPanel())])
                    : SingleChildScrollView(child: Column(children: [_buildPdfPanel(), const Divider(), _buildTranslationPanel()])),

                // Manual mode
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

  Widget _buildPdfPanel() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Upload zone
          InkWell(
            onTap: _extracting ? null : _pickAndExtractPdf,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppTheme.primary.withValues(alpha: 0.03),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.primary.withValues(alpha: 0.2), style: BorderStyle.solid),
              ),
              child: Column(
                children: [
                  Icon(
                    _extracting ? Icons.hourglass_empty : Icons.upload_file,
                    size: 36,
                    color: AppTheme.primary.withValues(alpha: 0.6),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _extracting ? 'Extracting text...' : (_fileName ?? 'Click to upload PDF'),
                    style: TextStyle(fontWeight: FontWeight.w600, color: AppTheme.primary.withValues(alpha: 0.8)),
                  ),
                  if (!_extracting) Text('PDF files only', style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
                  if (_extracting) const Padding(padding: EdgeInsets.only(top: 8), child: LinearProgressIndicator()),
                ],
              ),
            ),
          ),

          // Error / no text
          if (_extractResult != null && _extractResult!.hasError) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: AppTheme.error.withValues(alpha: 0.07), borderRadius: BorderRadius.circular(8)),
              child: Row(
                children: [
                  const Icon(Icons.warning_amber_rounded, color: AppTheme.error, size: 20),
                  const SizedBox(width: 8),
                  Expanded(child: Text(_extractResult!.error!, style: const TextStyle(fontSize: 12, color: AppTheme.error))),
                ],
              ),
            ),
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: () { _tabCtrl.animateTo(1); },
              icon: const Icon(Icons.edit_note, size: 18),
              label: const Text('Switch to Type Text mode'),
            ),
          ],

          // Page navigation
          if (_extractResult != null && _extractResult!.hasText) ...[
            const SizedBox(height: 16),
            Row(
              children: [
                Text(
                  'Page ${_currentPage + 1} of ${_extractResult!.totalPages}',
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                ),
                const SizedBox(width: 4),
                Text('(${_extractResult!.pagesWithText} with text)', style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
                const Spacer(),
                IconButton(
                  onPressed: _currentPage > 0 ? () => _goToPage(_currentPage - 1) : null,
                  icon: const Icon(Icons.chevron_left, size: 22),
                  splashRadius: 18,
                  tooltip: 'Previous page',
                ),
                IconButton(
                  onPressed: _currentPage < (_extractResult!.totalPages - 1) ? () => _goToPage(_currentPage + 1) : null,
                  icon: const Icon(Icons.chevron_right, size: 22),
                  splashRadius: 18,
                  tooltip: 'Next page',
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Page indicator dots
            if (_extractResult!.totalPages > 1 && _extractResult!.totalPages <= 20)
              Wrap(
                spacing: 4,
                children: List.generate(_extractResult!.totalPages, (i) {
                  return GestureDetector(
                    onTap: () => _goToPage(i),
                    child: Container(
                      width: 22,
                      height: 22,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: i == _currentPage ? AppTheme.primary : Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        '${i + 1}',
                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: i == _currentPage ? Colors.white : Colors.grey.shade700),
                      ),
                    ),
                  );
                }),
              ),
            const SizedBox(height: 12),

            // Select all & sentence count
            Row(
              children: [
                Checkbox(
                  value: _selectAll,
                  onChanged: (_) => _toggleSelectAll(),
                  visualDensity: VisualDensity.compact,
                ),
                const Text('Select All', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                const Spacer(),
                Text(
                  '${_selectedSentenceIndices.length} / ${_currentPageSentences.length} selected',
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                ),
              ],
            ),
            const SizedBox(height: 4),

            // Sentence list
            if (_currentPageSentences.isEmpty)
              const Padding(
                padding: EdgeInsets.all(20),
                child: Text('No extractable text on this page.', style: TextStyle(color: Colors.grey)),
              )
            else
              Container(
                constraints: const BoxConstraints(maxHeight: 250),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade200),
                ),
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
                            Checkbox(
                              value: selected,
                              onChanged: (_) => _toggleSentence(i),
                              visualDensity: VisualDensity.compact,
                            ),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(top: 6),
                                child: Text(
                                  _currentPageSentences[i],
                                  style: TextStyle(
                                    fontSize: 12,
                                    height: 1.5,
                                    color: selected ? AppTheme.tertiary : Colors.grey.shade700,
                                    fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                                  ),
                                ),
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

            // Fine-tune editing
            Row(
              children: [
                const Icon(Icons.edit, size: 14, color: AppTheme.primary),
                const SizedBox(width: 4),
                const Text('Fine-tune selected text', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
              ],
            ),
            const SizedBox(height: 6),
            TextField(
              controller: _editedTextCtrl,
              maxLines: 4,
              style: const TextStyle(fontSize: 12, height: 1.6),
              decoration: InputDecoration(
                hintText: 'Selected text will appear here. You can edit before translating.',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
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
          const Row(
            children: [
              Icon(Icons.keyboard, size: 16, color: AppTheme.primary),
              SizedBox(width: 6),
              Text('Type or paste text to translate', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
            ],
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _manualTextCtrl,
            maxLines: 12,
            style: const TextStyle(fontSize: 13, height: 1.6),
            decoration: InputDecoration(
              hintText: 'Enter text here...',
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton.icon(
                onPressed: () {
                  _manualTextCtrl.clear();
                  setState(() { _translatedText = null; _translationError = null; });
                },
                icon: const Icon(Icons.clear, size: 16),
                label: const Text('Clear'),
              ),
              const SizedBox(width: 8),
              TextButton.icon(
                onPressed: () async {
                  final data = await Clipboard.getData(Clipboard.kTextPlain);
                  if (data?.text != null) {
                    _manualTextCtrl.text = data!.text!;
                  }
                },
                icon: const Icon(Icons.content_paste, size: 16),
                label: const Text('Paste'),
              ),
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
              const Spacer(),
              if (_translatedText != null)
                TextButton.icon(
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: _translatedText!));
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Copied to clipboard!'), duration: Duration(seconds: 1)));
                  },
                  icon: const Icon(Icons.copy, size: 14),
                  label: const Text('Copy', style: TextStyle(fontSize: 12)),
                ),
            ],
          ),
          const SizedBox(height: 10),

          if (_translating)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(40),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: const Column(
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 12),
                  Text('Translating...', style: TextStyle(color: Colors.grey)),
                ],
              ),
            )
          else if (_translationError != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.error.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppTheme.error.withValues(alpha: 0.3)),
              ),
              child: Column(
                children: [
                  const Icon(Icons.error_outline, color: AppTheme.error, size: 28),
                  const SizedBox(height: 8),
                  Text(_translationError!, style: const TextStyle(fontSize: 12, color: AppTheme.error)),
                ],
              ),
            )
          else if (_translatedText != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppTheme.success.withValues(alpha: 0.3)),
              ),
              child: SelectableText(
                _translatedText!,
                style: const TextStyle(fontSize: 13, height: 1.7),
              ),
            )
          else
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(40),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                children: [
                  Icon(Icons.translate, size: 36, color: Colors.grey.shade300),
                  const SizedBox(height: 8),
                  Text(
                    _isManualMode ? 'Type text and click Translate' : 'Upload a PDF and click Translate',
                    style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _LanguageDropdown extends StatelessWidget {
  final String value;
  final Map<String, String> languages;
  final ValueChanged<String?> onChanged;

  const _LanguageDropdown({required this.value, required this.languages, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButton<String>(
        value: value,
        underline: const SizedBox.shrink(),
        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.tertiary),
        items: languages.entries.map((e) => DropdownMenuItem(value: e.key, child: Text(e.value))).toList(),
        onChanged: onChanged,
      ),
    );
  }
}
