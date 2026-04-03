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
  String _translatedText = '';
  String _fileName = '';
  String _errorMessage = '';
  bool _isExtracting = false;
  bool _isTranslating = false;
  bool _isPdfMode = true;

  // Page-level data
  List<PdfPageText> _pages = [];
  int _currentPageIndex = 0;

  // Selection mode: 'full' = full page text, 'sentences' = pick sentences
  String _selectionMode = 'full';

  // Which sentences are selected on the current page
  final Map<int, Set<int>> _selectedSentences = {};

  // Edited text per page (for fine-tuning)
  final Map<int, String> _editedTexts = {};
  bool _isEditing = false;
  final _editController = TextEditingController();

  @override
  void dispose() {
    _manualTextController.dispose();
    _editController.dispose();
    super.dispose();
  }

  String get _selectedText {
    if (!_isPdfMode) return _manualTextController.text;
    if (_pages.isEmpty) return '';

    if (_selectionMode == 'full') {
      if (_editedTexts.containsKey(_currentPageIndex)) {
        return _editedTexts[_currentPageIndex]!;
      }
      return _pages[_currentPageIndex].text;
    } else {
      final selected = _selectedSentences[_currentPageIndex] ?? {};
      if (selected.isEmpty) return '';
      final sentences = _pages[_currentPageIndex].sentences;
      final indices = selected.toList()..sort();
      return indices.map((i) => sentences[i]).join(' ');
    }
  }

  String get _allSelectedText {
    if (!_isPdfMode) return _manualTextController.text;
    if (_pages.isEmpty) return '';

    final buffer = StringBuffer();
    for (int i = 0; i < _pages.length; i++) {
      String pageText;
      if (_selectionMode == 'full') {
        pageText = _editedTexts.containsKey(i)
            ? _editedTexts[i]!
            : _pages[i].text;
      } else {
        final selected = _selectedSentences[i] ?? {};
        if (selected.isEmpty) continue;
        final sentences = _pages[i].sentences;
        final indices = selected.toList()..sort();
        pageText = indices.map((idx) => sentences[idx]).join(' ');
      }
      if (pageText.trim().isNotEmpty) {
        if (buffer.isNotEmpty) buffer.write('\n\n');
        buffer.write(pageText);
      }
    }
    return buffer.toString();
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
      _pages = [];
      _translatedText = '';
      _currentPageIndex = 0;
      _selectedSentences.clear();
      _editedTexts.clear();
      _isEditing = false;
    });
    try {
      final pages = await _pdfService.extractPagesFromBytes(bytes);
      setState(() {
        _pages = pages;
        if (pages.isEmpty || pages.every((p) => p.text.trim().isEmpty)) {
          _errorMessage =
              'No text could be extracted. The PDF may contain scanned images.';
        } else {
          // Default: select all sentences on all pages
          for (int i = 0; i < pages.length; i++) {
            _selectedSentences[i] =
                Set.from(List.generate(pages[i].sentences.length, (j) => j));
          }
        }
      });
    } catch (e) {
      setState(() => _errorMessage = 'Failed to extract text from PDF.');
    } finally {
      setState(() => _isExtracting = false);
    }
  }

  Future<void> _translateCurrentPage() async {
    final text = _selectedText;
    if (text.trim().isEmpty) {
      setState(() => _errorMessage = 'No text selected to translate.');
      return;
    }
    await _doTranslate(text);
  }

  Future<void> _translateAllPages() async {
    final text = _allSelectedText;
    if (text.trim().isEmpty) {
      setState(() => _errorMessage = 'No text selected to translate.');
      return;
    }
    await _doTranslate(text);
  }

  Future<void> _doTranslate(String text) async {
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
      setState(() => _errorMessage = 'Translation failed. Please try again.');
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
      _pages = [];
      _translatedText = '';
      _manualTextController.clear();
      _fileName = '';
      _errorMessage = '';
      _currentPageIndex = 0;
      _selectedSentences.clear();
      _editedTexts.clear();
      _isEditing = false;
    });
  }

  void _copyTranslation() {
    if (_translatedText.isNotEmpty) {
      Clipboard.setData(ClipboardData(text: _translatedText));
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Copied to clipboard!')));
    }
  }

  void _toggleSentence(int pageIndex, int sentenceIndex) {
    setState(() {
      _selectedSentences.putIfAbsent(pageIndex, () => {});
      final set = _selectedSentences[pageIndex]!;
      if (set.contains(sentenceIndex)) {
        set.remove(sentenceIndex);
      } else {
        set.add(sentenceIndex);
      }
    });
  }

  void _selectAllSentences(int pageIndex) {
    setState(() {
      _selectedSentences[pageIndex] =
          Set.from(List.generate(_pages[pageIndex].sentences.length, (i) => i));
    });
  }

  void _deselectAllSentences(int pageIndex) {
    setState(() {
      _selectedSentences[pageIndex] = {};
    });
  }

  void _startEditing() {
    final text = _editedTexts.containsKey(_currentPageIndex)
        ? _editedTexts[_currentPageIndex]!
        : _pages[_currentPageIndex].text;
    _editController.text = text;
    setState(() => _isEditing = true);
  }

  void _saveEditing() {
    setState(() {
      _editedTexts[_currentPageIndex] = _editController.text;
      _isEditing = false;
    });
  }

  void _cancelEditing() {
    setState(() => _isEditing = false);
  }

  void _resetPageText() {
    setState(() {
      _editedTexts.remove(_currentPageIndex);
    });
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
              child: Center(
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
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: _sourceLang,
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
                              value: _targetLang,
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
                      ),
                      const SizedBox(height: 16),

                      // PDF upload area
                      if (_isPdfMode && _pages.isEmpty)
                        InkWell(
                          onTap: _isExtracting ? null : _pickPdf,
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(40),
                            decoration: BoxDecoration(
                              border: Border.all(
                                  color: Colors.grey.shade400, width: 2),
                              borderRadius: BorderRadius.circular(8),
                              color: Colors.grey.shade50,
                            ),
                            child: Column(
                              children: [
                                const Icon(Icons.cloud_upload,
                                    size: 48,
                                    color: AppTheme.primaryColor),
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
                            border:
                                Border.all(color: Colors.red.shade200),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(_errorMessage,
                              style:
                                  const TextStyle(color: Colors.red)),
                        ),

                      // Page-level controls when PDF is loaded
                      if (_isPdfMode && _pages.isNotEmpty) ...[
                        _buildFileInfoBar(),
                        const SizedBox(height: 12),
                        _buildSelectionModeToggle(),
                        const SizedBox(height: 12),
                        _buildPageNavigator(),
                        const SizedBox(height: 12),
                        _buildPageContent(),
                        const SizedBox(height: 12),
                      ],

                      // Actions
                      _buildActionButtons(),
                      const SizedBox(height: 16),

                      // Results side by side
                      if ((_isPdfMode && _pages.isNotEmpty &&
                              _selectedText.isNotEmpty) ||
                          (!_isPdfMode &&
                              _manualTextController.text.isNotEmpty) ||
                          _translatedText.isNotEmpty)
                        LayoutBuilder(builder: (context, constraints) {
                          final isWide = constraints.maxWidth > 700;
                          final panels = <Widget>[
                            if (_isPdfMode &&
                                _selectedText.isNotEmpty)
                              _resultCard(
                                'Selected Text (${TranslationService.getLanguageName(_sourceLang)})',
                                _selectedText,
                              ),
                            if (!_isPdfMode &&
                                _manualTextController.text.isNotEmpty)
                              _resultCard(
                                'Source Text (${TranslationService.getLanguageName(_sourceLang)})',
                                _manualTextController.text,
                              ),
                            if (_translatedText.isNotEmpty)
                              _resultCard(
                                'Translated Text (${TranslationService.getLanguageName(_targetLang)})',
                                _translatedText,
                              ),
                          ];
                          if (isWide && panels.length == 2) {
                            return Row(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: panels
                                  .map((p) => Expanded(
                                      child: Padding(
                                          padding:
                                              const EdgeInsets.all(4),
                                          child: p)))
                                  .toList(),
                            );
                          }
                          return Column(
                              children: panels
                                  .map((p) => Padding(
                                      padding: const EdgeInsets.only(
                                          bottom: 8),
                                      child: p))
                                  .toList());
                        }),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const FooterWidget(),
        ],
      ),
    );
  }

  Widget _buildFileInfoBar() {
    return Card(
      color: AppTheme.primaryColor.withAlpha(25),
      child: Padding(
        padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            const Icon(Icons.picture_as_pdf,
                color: Colors.red, size: 28),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_fileName,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold)),
                  Text(
                      '${_pages.length} page${_pages.length > 1 ? 's' : ''} extracted',
                      style: const TextStyle(
                          fontSize: 12, color: Colors.grey)),
                ],
              ),
            ),
            TextButton.icon(
              onPressed: _pickPdf,
              icon: const Icon(Icons.upload_file, size: 18),
              label: const Text('Upload Another'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectionModeToggle() {
    return Row(
      children: [
        const Text('Selection Mode: ',
            style: TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(width: 8),
        ChoiceChip(
          label: const Text('Full Text'),
          selected: _selectionMode == 'full',
          onSelected: (_) =>
              setState(() => _selectionMode = 'full'),
          avatar: _selectionMode == 'full'
              ? const Icon(Icons.check, size: 16)
              : null,
        ),
        const SizedBox(width: 8),
        ChoiceChip(
          label: const Text('Select Sentences'),
          selected: _selectionMode == 'sentences',
          onSelected: (_) =>
              setState(() => _selectionMode = 'sentences'),
          avatar: _selectionMode == 'sentences'
              ? const Icon(Icons.check, size: 16)
              : null,
        ),
      ],
    );
  }

  Widget _buildPageNavigator() {
    return Card(
      child: Padding(
        padding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          children: [
            IconButton(
              onPressed: _currentPageIndex > 0
                  ? () => setState(() {
                        _currentPageIndex--;
                        _isEditing = false;
                      })
                  : null,
              icon: const Icon(Icons.chevron_left),
              tooltip: 'Previous page',
            ),
            Expanded(
              child: _pages.length <= 10
                  ? SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children:
                            List.generate(_pages.length, (i) {
                          final isActive = i == _currentPageIndex;
                          final hasContent =
                              _selectionMode == 'sentences'
                                  ? (_selectedSentences[i]
                                          ?.isNotEmpty ??
                                      false)
                                  : true;
                          return Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 2),
                            child: InkWell(
                              onTap: () => setState(() {
                                _currentPageIndex = i;
                                _isEditing = false;
                              }),
                              borderRadius:
                                  BorderRadius.circular(6),
                              child: Container(
                                padding:
                                    const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 6),
                                decoration: BoxDecoration(
                                  color: isActive
                                      ? AppTheme.primaryColor
                                      : hasContent
                                          ? AppTheme.primaryColor
                                              .withAlpha(40)
                                          : Colors.grey.shade200,
                                  borderRadius:
                                      BorderRadius.circular(6),
                                ),
                                child: Text(
                                  '${i + 1}',
                                  style: TextStyle(
                                    color: isActive
                                        ? Colors.white
                                        : Colors.black87,
                                    fontWeight: isActive
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }),
                      ),
                    )
                  : Center(
                      child: DropdownButton<int>(
                        value: _currentPageIndex,
                        items: List.generate(
                            _pages.length,
                            (i) => DropdownMenuItem(
                                value: i,
                                child:
                                    Text('Page ${i + 1}'))),
                        onChanged: (v) => setState(() {
                          _currentPageIndex = v!;
                          _isEditing = false;
                        }),
                      ),
                    ),
            ),
            IconButton(
              onPressed:
                  _currentPageIndex < _pages.length - 1
                      ? () => setState(() {
                            _currentPageIndex++;
                            _isEditing = false;
                          })
                      : null,
              icon: const Icon(Icons.chevron_right),
              tooltip: 'Next page',
            ),
            const VerticalDivider(width: 16),
            Text(
              'Page ${_currentPageIndex + 1} of ${_pages.length}',
              style:
                  const TextStyle(fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPageContent() {
    if (_pages.isEmpty) return const SizedBox.shrink();
    final page = _pages[_currentPageIndex];
    if (_selectionMode == 'full') {
      return _buildFullTextView(page);
    } else {
      return _buildSentenceSelectionView(page);
    }
  }

  Widget _buildFullTextView(PdfPageText page) {
    final displayText =
        _editedTexts.containsKey(_currentPageIndex)
            ? _editedTexts[_currentPageIndex]!
            : page.text;

    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 16, vertical: 10),
            color: AppTheme.primaryColor,
            child: Row(
              children: [
                Text('Page ${page.pageNumber} - Full Text',
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold)),
                const Spacer(),
                if (_editedTexts
                    .containsKey(_currentPageIndex))
                  Tooltip(
                    message: 'Reset to original',
                    child: InkWell(
                      onTap: _resetPageText,
                      child: const Icon(Icons.restore,
                          color: Colors.white70, size: 20),
                    ),
                  ),
                const SizedBox(width: 8),
                if (!_isEditing)
                  Tooltip(
                    message: 'Edit text for fine-tuning',
                    child: InkWell(
                      onTap: _startEditing,
                      child: const Icon(Icons.edit,
                          color: Colors.white70, size: 20),
                    ),
                  ),
              ],
            ),
          ),
          if (_isEditing)
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  TextField(
                    controller: _editController,
                    maxLines: 10,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Edit the extracted text...',
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                          onPressed: _cancelEditing,
                          child: const Text('Cancel')),
                      const SizedBox(width: 8),
                      ElevatedButton.icon(
                        onPressed: _saveEditing,
                        icon: const Icon(Icons.save, size: 18),
                        label: const Text('Save Changes'),
                      ),
                    ],
                  ),
                ],
              ),
            )
          else
            ConstrainedBox(
              constraints:
                  const BoxConstraints(maxHeight: 350),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(12),
                child: SelectableText(
                  displayText.isEmpty
                      ? '(No text on this page)'
                      : displayText,
                  style: TextStyle(
                    color: displayText.isEmpty
                        ? Colors.grey
                        : Colors.black87,
                    height: 1.5,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSentenceSelectionView(PdfPageText page) {
    final selected =
        _selectedSentences[_currentPageIndex] ?? {};
    final sentences = page.sentences;

    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 16, vertical: 10),
            color: AppTheme.primaryColor,
            child: Row(
              children: [
                Text(
                    'Page ${page.pageNumber} - Select Sentences (${selected.length}/${sentences.length})',
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold)),
                const Spacer(),
                TextButton(
                  onPressed: () =>
                      _selectAllSentences(_currentPageIndex),
                  child: const Text('Select All',
                      style: TextStyle(
                          color: Colors.white70,
                          fontSize: 12)),
                ),
                TextButton(
                  onPressed: () =>
                      _deselectAllSentences(_currentPageIndex),
                  child: const Text('Deselect All',
                      style: TextStyle(
                          color: Colors.white70,
                          fontSize: 12)),
                ),
              ],
            ),
          ),
          if (sentences.isEmpty)
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text('(No text on this page)',
                  style: TextStyle(color: Colors.grey)),
            )
          else
            ConstrainedBox(
              constraints:
                  const BoxConstraints(maxHeight: 400),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(8),
                child: Column(
                  children: List.generate(
                      sentences.length, (i) {
                    final isSelected =
                        selected.contains(i);
                    return Padding(
                      padding:
                          const EdgeInsets.symmetric(
                              vertical: 2),
                      child: InkWell(
                        onTap: () => _toggleSentence(
                            _currentPageIndex, i),
                        borderRadius:
                            BorderRadius.circular(6),
                        child: Container(
                          width: double.infinity,
                          padding:
                              const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppTheme.primaryColor
                                    .withAlpha(30)
                                : Colors.transparent,
                            border: Border.all(
                              color: isSelected
                                  ? AppTheme
                                      .primaryColor
                                  : Colors
                                      .grey.shade300,
                            ),
                            borderRadius:
                                BorderRadius.circular(
                                    6),
                          ),
                          child: Row(
                            crossAxisAlignment:
                                CrossAxisAlignment
                                    .start,
                            children: [
                              Icon(
                                isSelected
                                    ? Icons.check_box
                                    : Icons
                                        .check_box_outline_blank,
                                size: 20,
                                color: isSelected
                                    ? AppTheme
                                        .primaryColor
                                    : Colors.grey,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  sentences[i],
                                  style: TextStyle(
                                    color: isSelected
                                        ? Colors
                                            .black87
                                        : Colors
                                            .black54,
                                    height: 1.4,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    final hasText = _isPdfMode
        ? _pages.isNotEmpty
        : _manualTextController.text.isNotEmpty;

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        if (_isPdfMode && _pages.isNotEmpty) ...[
          ElevatedButton.icon(
            onPressed: (_isTranslating || _isExtracting)
                ? null
                : _translateCurrentPage,
            icon: _isTranslating
                ? const SizedBox(
                    height: 16,
                    width: 16,
                    child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white))
                : const Icon(Icons.translate),
            label: Text(_isTranslating
                ? 'Translating...'
                : 'Translate Page ${_currentPageIndex + 1}'),
          ),
          ElevatedButton.icon(
            onPressed: (_isTranslating || _isExtracting)
                ? null
                : _translateAllPages,
            icon: const Icon(Icons.translate),
            label: const Text('Translate All Pages'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.teal.shade700,
            ),
          ),
        ] else if (!_isPdfMode) ...[
          ElevatedButton.icon(
            onPressed: (_isTranslating || !hasText)
                ? null
                : () => _doTranslate(
                    _manualTextController.text),
            icon: _isTranslating
                ? const SizedBox(
                    height: 16,
                    width: 16,
                    child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white))
                : const Icon(Icons.translate),
            label: Text(_isTranslating
                ? 'Translating...'
                : 'Translate'),
          ),
        ],
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
                    color: Colors.white,
                    fontWeight: FontWeight.bold)),
          ),
          ConstrainedBox(
            constraints:
                const BoxConstraints(maxHeight: 400),
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
