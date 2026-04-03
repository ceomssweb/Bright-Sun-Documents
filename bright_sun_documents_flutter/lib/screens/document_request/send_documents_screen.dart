import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:provider/provider.dart';
import '../../models/client_user.dart';
import '../../services/auth_service.dart';
import '../../services/users_documents_service.dart';
import '../../theme/app_theme.dart';

class SendDocumentsScreen extends StatefulWidget {
  final UsersDocumentsService userService;
  const SendDocumentsScreen({super.key, required this.userService});

  @override
  State<SendDocumentsScreen> createState() => _SendDocumentsScreenState();
}

class _SendDocumentsScreenState extends State<SendDocumentsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullName = TextEditingController();
  final _fatherName = TextEditingController();
  final _email = TextEditingController();
  final _mobileNumber = TextEditingController();
  final _currentOwnerName = TextEditingController();
  final _currentOwnerAddress = TextEditingController();
  final _currentOwnerAge = TextEditingController();
  final _buyerName = TextEditingController();
  final _buyerAddress = TextEditingController();
  final _buyerAge = TextEditingController();

  String _selectedDoc = '';
  String _currentOwnerGender = '';
  String _selectBuyerRelation = '';
  String _selectedBuyGender = '';
  String _paymentStatus = '';

  List<PlatformFile> _files = [];
  bool _uploading = false;
  double _progress = 0;

  final _docTypes = [
    'Sales Deed',
    'Gift Deed / Settlement',
    'Release Deed',
    'Exchange Deed',
    'Mortgage Deed',
    'Partition Deed',
    'Power of Attorney',
    'Rental/Lease Agreement',
    'Will Deed',
    'Trust Deed',
    'Others',
  ];

  final _genders = ['Male', 'Female', 'Other'];
  final _relations = ['Father', 'Mother', 'Son', 'Daughter', 'Spouse', 'Brother', 'Sister', 'Others'];
  final _paymentStatuses = ['Paid', 'Pending', 'Partial', 'Not Paid'];

  @override
  void dispose() {
    _fullName.dispose();
    _fatherName.dispose();
    _email.dispose();
    _mobileNumber.dispose();
    _currentOwnerName.dispose();
    _currentOwnerAddress.dispose();
    _currentOwnerAge.dispose();
    _buyerName.dispose();
    _buyerAddress.dispose();
    _buyerAge.dispose();
    super.dispose();
  }

  Future<void> _pickFiles() async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      withData: true,
    );
    if (result != null) {
      setState(() => _files = result.files);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_files.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please add files to upload')));
      return;
    }

    setState(() {
      _uploading = true;
      _progress = 0;
    });

    try {
      final fileNames = <String>[];
      for (var i = 0; i < _files.length; i++) {
        final file = _files[i];
        if (file.bytes != null) {
          await widget.userService
              .uploadFile(file.bytes!, file.name, _mobileNumber.text);
          fileNames.add(file.name);
          setState(() => _progress = (i + 1) / _files.length);
        }
      }

      final user = ClientUser(
        fullName: _fullName.text,
        fatherName: _fatherName.text,
        email: _email.text,
        mobileNumber: _mobileNumber.text,
        selectedDoc: _selectedDoc,
        currentOwnerName: _currentOwnerName.text,
        currentOwnerAddress: _currentOwnerAddress.text,
        currentOwnerAge: _currentOwnerAge.text,
        currentOwnergender: _currentOwnerGender,
        selectBuyerRelation: _selectBuyerRelation,
        buyerName: _buyerName.text,
        buyerAddress: _buyerAddress.text,
        buyerAge: _buyerAge.text,
        selectedBuyGender: _selectedBuyGender,
        paymentStatus: _paymentStatus,
      );

      await widget.userService
          .addUser(user, fileNames, 'Ready for Processing');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('${_fullName.text} successfully added!')));
        _resetForm();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

  void _resetForm() {
    _formKey.currentState?.reset();
    _fullName.clear();
    _fatherName.clear();
    _email.clear();
    _mobileNumber.clear();
    _currentOwnerName.clear();
    _currentOwnerAddress.clear();
    _currentOwnerAge.clear();
    _buyerName.clear();
    _buyerAddress.clear();
    _buyerAge.clear();
    setState(() {
      _files = [];
      _selectedDoc = '';
      _currentOwnerGender = '';
      _selectBuyerRelation = '';
      _selectedBuyGender = '';
      _paymentStatus = '';
      _progress = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(8),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Client Information',
                style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 12),
            _buildRow([
              _buildField('Full Name', _fullName),
              _buildField("Father's Name", _fatherName),
            ]),
            _buildRow([
              _buildField('Email', _email, type: TextInputType.emailAddress),
              _buildField('Mobile Number', _mobileNumber,
                  type: TextInputType.phone),
            ]),
            const SizedBox(height: 8),
            _buildDropdown('Document Type', _docTypes, _selectedDoc,
                (v) => setState(() => _selectedDoc = v ?? '')),
            const Divider(height: 24),
            Text('Current Owner / Seller Details',
                style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 12),
            _buildRow([
              _buildField('Owner Name', _currentOwnerName),
              _buildField('Owner Address', _currentOwnerAddress),
            ]),
            _buildRow([
              _buildField('Age', _currentOwnerAge, type: TextInputType.number),
              _buildDropdownInline('Gender', _genders, _currentOwnerGender,
                  (v) => setState(() => _currentOwnerGender = v ?? '')),
            ]),
            const Divider(height: 24),
            Text('Buyer Details',
                style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 12),
            _buildDropdown('Relation', _relations, _selectBuyerRelation,
                (v) => setState(() => _selectBuyerRelation = v ?? '')),
            _buildRow([
              _buildField('Buyer Name', _buyerName),
              _buildField('Buyer Address', _buyerAddress),
            ]),
            _buildRow([
              _buildField('Age', _buyerAge, type: TextInputType.number),
              _buildDropdownInline('Gender', _genders, _selectedBuyGender,
                  (v) => setState(() => _selectedBuyGender = v ?? '')),
            ]),
            const Divider(height: 24),
            _buildDropdown('Payment Status', _paymentStatuses, _paymentStatus,
                (v) => setState(() => _paymentStatus = v ?? '')),
            const SizedBox(height: 12),
            // File upload
            OutlinedButton.icon(
              onPressed: _pickFiles,
              icon: const Icon(Icons.upload_file),
              label: Text(_files.isEmpty
                  ? 'Choose Files'
                  : '${_files.length} file(s) selected'),
            ),
            if (_files.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Wrap(
                  spacing: 8,
                  children: _files
                      .map((f) => Chip(label: Text(f.name, style: const TextStyle(fontSize: 12))))
                      .toList(),
                ),
              ),
            if (_uploading)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: LinearProgressIndicator(value: _progress),
              ),
            const SizedBox(height: 16),
            Row(
              children: [
                ElevatedButton(
                    onPressed: _uploading ? null : _submit,
                    child: const Text('Submit')),
                const SizedBox(width: 12),
                OutlinedButton(
                    onPressed: _resetForm, child: const Text('Reset')),
              ],
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildRow(List<Widget> children) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth > 600) {
            return Row(
              children: children
                  .map((c) => Expanded(
                      child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: c)))
                  .toList(),
            );
          }
          return Column(children: children.map((c) => Padding(
            padding: const EdgeInsets.only(bottom: 8), child: c)).toList());
        },
      ),
    );
  }

  Widget _buildField(String label, TextEditingController controller,
      {TextInputType type = TextInputType.text}) {
    return TextFormField(
      controller: controller,
      keyboardType: type,
      decoration: InputDecoration(labelText: label, isDense: true),
      validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
    );
  }

  Widget _buildDropdown(String label, List<String> items, String value,
      ValueChanged<String?> onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: DropdownButtonFormField<String>(
        initialValue: value.isEmpty ? null : value,
        decoration: InputDecoration(labelText: label, isDense: true),
        items: items
            .map((e) => DropdownMenuItem(value: e, child: Text(e)))
            .toList(),
        onChanged: onChanged,
        validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
      ),
    );
  }

  Widget _buildDropdownInline(String label, List<String> items, String value,
      ValueChanged<String?> onChanged) {
    return DropdownButtonFormField<String>(
      initialValue: value.isEmpty ? null : value,
      decoration: InputDecoration(labelText: label, isDense: true),
      items:
          items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
      onChanged: onChanged,
      validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
    );
  }
}
