import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../../constants/app_constants.dart';
import '../../models/client_user.dart';
import '../../services/document_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';

class AddClientScreen extends StatefulWidget {
  final DocumentService docService;
  const AddClientScreen({super.key, required this.docService});

  @override
  State<AddClientScreen> createState() => _AddClientScreenState();
}

class _AddClientScreenState extends State<AddClientScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullName = TextEditingController();
  final _fatherName = TextEditingController();
  final _email = TextEditingController();
  final _mobileNumber = TextEditingController();
  final _ownerName = TextEditingController();
  final _ownerAddress = TextEditingController();
  final _ownerAge = TextEditingController();
  final _buyerName = TextEditingController();
  final _buyerAddress = TextEditingController();
  final _buyerAge = TextEditingController();
  final _notes = TextEditingController();

  String _selectedDoc = '';
  String _ownerGender = '';
  String _buyerRelation = '';
  String _buyerGender = '';
  String _paymentStatus = '';

  List<PlatformFile> _files = [];
  bool _uploading = false;
  double _progress = 0;
  int _currentStep = 0;

  @override
  void dispose() {
    for (final c in [_fullName, _fatherName, _email, _mobileNumber, _ownerName, _ownerAddress, _ownerAge, _buyerName, _buyerAddress, _buyerAge, _notes]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _pickFiles() async {
    final result = await FilePicker.platform.pickFiles(allowMultiple: true, withData: true);
    if (result != null) setState(() => _files = result.files);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      _showMsg('Please fill in all required fields.', isError: true);
      return;
    }

    setState(() { _uploading = true; _progress = 0; });

    try {
      final fileNames = <String>[];
      if (_files.isNotEmpty) {
        for (var i = 0; i < _files.length; i++) {
          final file = _files[i];
          if (file.bytes != null) {
            await widget.docService.uploadFile(file.bytes!, file.name, _mobileNumber.text);
            fileNames.add(file.name);
            setState(() => _progress = (i + 1) / _files.length);
          }
        }
      }

      final user = ClientUser(
        fullName: _fullName.text.trim(),
        fatherName: _fatherName.text.trim(),
        email: _email.text.trim(),
        mobileNumber: _mobileNumber.text.trim(),
        selectedDoc: _selectedDoc,
        currentOwnerName: _ownerName.text.trim(),
        currentOwnerAddress: _ownerAddress.text.trim(),
        currentOwnerAge: _ownerAge.text.trim(),
        currentOwnerGender: _ownerGender,
        selectBuyerRelation: _buyerRelation,
        buyerName: _buyerName.text.trim(),
        buyerAddress: _buyerAddress.text.trim(),
        buyerAge: _buyerAge.text.trim(),
        selectedBuyGender: _buyerGender,
        paymentStatus: _paymentStatus,
        notes: _notes.text.trim(),
      );

      await widget.docService.addClient(user, fileNames);

      if (mounted) {
        _showMsg('${_fullName.text} added successfully!');
        _resetForm();
      }
    } catch (e) {
      if (mounted) _showMsg('Error: $e', isError: true);
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

  void _resetForm() {
    _formKey.currentState?.reset();
    for (final c in [_fullName, _fatherName, _email, _mobileNumber, _ownerName, _ownerAddress, _ownerAge, _buyerName, _buyerAddress, _buyerAge, _notes]) {
      c.clear();
    }
    setState(() {
      _files = [];
      _selectedDoc = '';
      _ownerGender = '';
      _buyerRelation = '';
      _buyerGender = '';
      _paymentStatus = '';
      _progress = 0;
      _currentStep = 0;
    });
  }

  void _showMsg(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: isError ? AppTheme.error : AppTheme.success),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SectionHeader(title: 'Add New Client'),
            const SizedBox(height: 4),
            Text('Fill in client and document details', style: TextStyle(fontSize: 13, color: Colors.grey.shade500)),
            const SizedBox(height: 20),

            // Stepper-like progress
            _StepIndicator(
              steps: const ['Client Info', 'Owner', 'Buyer', 'Documents'],
              currentStep: _currentStep,
              onStepTap: (i) => setState(() => _currentStep = i),
            ),
            const SizedBox(height: 24),

            // Step content
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: _buildStepContent(),
            ),

            if (_uploading)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Column(
                  children: [
                    LinearProgressIndicator(value: _progress, borderRadius: BorderRadius.circular(4)),
                    const SizedBox(height: 8),
                    Text('Uploading files... ${(_progress * 100).toInt()}%',
                        style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
                  ],
                ),
              ),

            const SizedBox(height: 20),

            // Navigation buttons
            Row(
              children: [
                if (_currentStep > 0)
                  OutlinedButton.icon(
                    onPressed: () => setState(() => _currentStep--),
                    icon: const Icon(Icons.arrow_back, size: 16),
                    label: const Text('Previous'),
                  ),
                const Spacer(),
                if (_currentStep < 3)
                  ElevatedButton.icon(
                    onPressed: () => setState(() => _currentStep++),
                    icon: const Icon(Icons.arrow_forward, size: 16),
                    label: const Text('Next'),
                  ),
                if (_currentStep == 3) ...[
                  OutlinedButton(onPressed: _resetForm, child: const Text('Reset')),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    onPressed: _uploading ? null : _submit,
                    icon: _uploading
                        ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const Icon(Icons.check, size: 16),
                    label: const Text('Submit Client'),
                  ),
                ],
              ],
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildStepContent() {
    switch (_currentStep) {
      case 0:
        return _buildClientInfo();
      case 1:
        return _buildOwnerSection();
      case 2:
        return _buildBuyerSection();
      case 3:
        return _buildDocumentsSection();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildClientInfo() {
    return _CardSection(
      key: const ValueKey('client'),
      title: 'Client Information',
      icon: Icons.person_outline,
      children: [
        _FormRow(children: [
          _field('Full Name *', _fullName, Icons.person_outline),
          _field("Father's Name *", _fatherName, Icons.family_restroom),
        ]),
        _FormRow(children: [
          _field('Email *', _email, Icons.email_outlined, type: TextInputType.emailAddress),
          _field('Mobile Number *', _mobileNumber, Icons.phone_outlined, type: TextInputType.phone),
        ]),
        _dropdown('Document Type *', AppConstants.documentTypes, _selectedDoc, (v) => setState(() => _selectedDoc = v ?? '')),
      ],
    );
  }

  Widget _buildOwnerSection() {
    return _CardSection(
      key: const ValueKey('owner'),
      title: 'Current Owner / Seller Details',
      icon: Icons.real_estate_agent_outlined,
      children: [
        _FormRow(children: [
          _field('Owner Name *', _ownerName, Icons.person_outline),
          _field('Address *', _ownerAddress, Icons.location_on_outlined),
        ]),
        _FormRow(children: [
          _field('Age *', _ownerAge, Icons.calendar_today_outlined, type: TextInputType.number),
          _dropdown('Gender *', AppConstants.genders, _ownerGender, (v) => setState(() => _ownerGender = v ?? '')),
        ]),
      ],
    );
  }

  Widget _buildBuyerSection() {
    return _CardSection(
      key: const ValueKey('buyer'),
      title: 'Buyer Details',
      icon: Icons.shopping_bag_outlined,
      children: [
        _dropdown('Relation *', AppConstants.relations, _buyerRelation, (v) => setState(() => _buyerRelation = v ?? '')),
        _FormRow(children: [
          _field('Buyer Name *', _buyerName, Icons.person_outline),
          _field('Address *', _buyerAddress, Icons.location_on_outlined),
        ]),
        _FormRow(children: [
          _field('Age *', _buyerAge, Icons.calendar_today_outlined, type: TextInputType.number),
          _dropdown('Gender *', AppConstants.genders, _buyerGender, (v) => setState(() => _buyerGender = v ?? '')),
        ]),
      ],
    );
  }

  Widget _buildDocumentsSection() {
    return _CardSection(
      key: const ValueKey('docs'),
      title: 'Payment & Documents',
      icon: Icons.upload_file_rounded,
      children: [
        _dropdown('Payment Status *', AppConstants.paymentStatuses, _paymentStatus, (v) => setState(() => _paymentStatus = v ?? '')),
        const SizedBox(height: 12),
        TextFormField(
          controller: _notes,
          maxLines: 3,
          decoration: const InputDecoration(
            labelText: 'Notes (optional)',
            prefixIcon: Icon(Icons.note_outlined, size: 20),
            alignLabelWithHint: true,
          ),
        ),
        const SizedBox(height: 16),
        // File upload
        InkWell(
          onTap: _pickFiles,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              border: Border.all(color: AppTheme.primary.withAlpha(60), width: 1.5),
              borderRadius: BorderRadius.circular(12),
              color: AppTheme.primary.withAlpha(5),
            ),
            child: Column(
              children: [
                Icon(Icons.cloud_upload_rounded, size: 36, color: AppTheme.primary.withAlpha(150)),
                const SizedBox(height: 8),
                Text(
                  _files.isEmpty ? 'Click to upload documents' : '${_files.length} file(s) selected',
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade600, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 4),
                Text('PDF, Images, Word documents', style: TextStyle(fontSize: 11, color: Colors.grey.shade400)),
              ],
            ),
          ),
        ),
        if (_files.isNotEmpty) ...[
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _files
                .map((f) => Chip(
                      avatar: const Icon(Icons.insert_drive_file, size: 14),
                      label: Text(f.name, style: const TextStyle(fontSize: 12)),
                      onDeleted: () => setState(() => _files.remove(f)),
                      deleteIconColor: Colors.grey,
                    ))
                .toList(),
          ),
        ],
      ],
    );
  }

  Widget _field(String label, TextEditingController ctrl, IconData icon, {TextInputType type = TextInputType.text}) {
    return TextFormField(
      controller: ctrl,
      keyboardType: type,
      decoration: InputDecoration(labelText: label, prefixIcon: Icon(icon, size: 18)),
      validator: label.endsWith('*') ? (v) => (v == null || v.trim().isEmpty) ? 'Required' : null : null,
    );
  }

  Widget _dropdown(String label, List<String> items, String value, ValueChanged<String?> onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: DropdownButtonFormField<String>(
        value: value.isEmpty ? null : value,
        decoration: InputDecoration(labelText: label),
        items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
        onChanged: onChanged,
        validator: label.endsWith('*') ? (v) => (v == null || v.isEmpty) ? 'Required' : null : null,
      ),
    );
  }
}

class _CardSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;

  const _CardSection({super.key, required this.title, required this.icon, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppTheme.primary, size: 20),
              const SizedBox(width: 10),
              Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppTheme.tertiary)),
            ],
          ),
          const SizedBox(height: 20),
          ...children,
        ],
      ),
    );
  }
}

class _FormRow extends StatelessWidget {
  final List<Widget> children;
  const _FormRow({required this.children});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth > 500) {
            return Row(
              children: children
                  .map((c) => Expanded(child: Padding(padding: const EdgeInsets.symmetric(horizontal: 4), child: c)))
                  .toList(),
            );
          }
          return Column(children: children.map((c) => Padding(padding: const EdgeInsets.only(bottom: 8), child: c)).toList());
        },
      ),
    );
  }
}

class _StepIndicator extends StatelessWidget {
  final List<String> steps;
  final int currentStep;
  final ValueChanged<int> onStepTap;

  const _StepIndicator({required this.steps, required this.currentStep, required this.onStepTap});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(steps.length * 2 - 1, (i) {
        if (i.isOdd) {
          return Expanded(
            child: Container(
              height: 2,
              color: i ~/ 2 < currentStep ? AppTheme.primary : Colors.grey.shade300,
            ),
          );
        }
        final stepIndex = i ~/ 2;
        final isActive = stepIndex == currentStep;
        final isDone = stepIndex < currentStep;
        return GestureDetector(
          onTap: () => onStepTap(stepIndex),
          child: Column(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: isDone ? AppTheme.primary : isActive ? AppTheme.primary : Colors.grey.shade200,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: isDone
                      ? const Icon(Icons.check, color: Colors.white, size: 16)
                      : Text(
                          '${stepIndex + 1}',
                          style: TextStyle(
                            color: isActive ? Colors.white : Colors.grey.shade500,
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                steps[stepIndex],
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                  color: isActive ? AppTheme.primary : Colors.grey.shade500,
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}
