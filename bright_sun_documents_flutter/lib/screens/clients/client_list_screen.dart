import 'package:flutter/material.dart';
import '../../constants/app_constants.dart';
import '../../models/client_user.dart';
import '../../services/document_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';

class ClientListScreen extends StatefulWidget {
  final DocumentService docService;
  const ClientListScreen({super.key, required this.docService});

  @override
  State<ClientListScreen> createState() => _ClientListScreenState();
}

class _ClientListScreenState extends State<ClientListScreen> {
  List<ClientUser> _users = [];
  bool _loading = true;
  String _search = '';
  String _filterDoc = '';
  String _filterPayment = '';
  int _page = 0;
  static const int _pageSize = 10;
  dynamic _subscription;

  @override
  void initState() {
    super.initState();
    _subscription = widget.docService.getUsersListRef().onValue.listen((event) {
      final data = event.snapshot.value;
      final users = <ClientUser>[];
      if (data != null && data is Map) {
        data.forEach((key, value) {
          if (value is Map) users.add(ClientUser.fromMap(value, key: key.toString()));
        });
      }
      if (mounted) setState(() { _users = users; _loading = false; });
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  List<ClientUser> get _filtered {
    var list = _users;
    if (_search.isNotEmpty) {
      final q = _search.toLowerCase();
      list = list.where((u) =>
          u.fullName.toLowerCase().contains(q) ||
          u.mobileNumber.contains(q) ||
          u.email.toLowerCase().contains(q)).toList();
    }
    if (_filterDoc.isNotEmpty) {
      list = list.where((u) => u.selectedDoc == _filterDoc).toList();
    }
    if (_filterPayment.isNotEmpty) {
      list = list.where((u) => u.paymentStatus == _filterPayment).toList();
    }
    return list;
  }

  List<ClientUser> get _paginated {
    final f = _filtered;
    final start = _page * _pageSize;
    if (start >= f.length) return [];
    return f.sublist(start, (start + _pageSize).clamp(0, f.length));
  }

  @override
  Widget build(BuildContext context) {
    final totalPages = (_filtered.length / _pageSize).ceil();
    final isWide = MediaQuery.of(context).size.width > 800;

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(title: 'Client Management'),

          // Search & Filters
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Wrap(
              spacing: 12,
              runSpacing: 12,
              crossAxisAlignment: WrapCrossAlignment.end,
              children: [
                SizedBox(
                  width: isWide ? 280 : double.infinity,
                  child: TextField(
                    decoration: const InputDecoration(
                      hintText: 'Search by name, phone, or email...',
                      prefixIcon: Icon(Icons.search, size: 20),
                      isDense: true,
                    ),
                    onChanged: (v) => setState(() { _search = v; _page = 0; }),
                  ),
                ),
                SizedBox(
                  width: 180,
                  child: DropdownButtonFormField<String>(
                    value: _filterDoc.isEmpty ? null : _filterDoc,
                    decoration: const InputDecoration(labelText: 'Doc Type', isDense: true),
                    items: [
                      const DropdownMenuItem(value: '', child: Text('All Types')),
                      ...AppConstants.documentTypes.map((e) => DropdownMenuItem(value: e, child: Text(e, overflow: TextOverflow.ellipsis))),
                    ],
                    onChanged: (v) => setState(() { _filterDoc = v ?? ''; _page = 0; }),
                  ),
                ),
                SizedBox(
                  width: 160,
                  child: DropdownButtonFormField<String>(
                    value: _filterPayment.isEmpty ? null : _filterPayment,
                    decoration: const InputDecoration(labelText: 'Payment', isDense: true),
                    items: [
                      const DropdownMenuItem(value: '', child: Text('All')),
                      ...AppConstants.paymentStatuses.map((e) => DropdownMenuItem(value: e, child: Text(e))),
                    ],
                    onChanged: (v) => setState(() { _filterPayment = v ?? ''; _page = 0; }),
                  ),
                ),
                Text('${_filtered.length} results', style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Table
          if (_loading)
            const Expanded(child: Center(child: CircularProgressIndicator()))
          else if (_users.isEmpty)
            Expanded(
              child: EmptyState(
                icon: Icons.people_outline,
                title: 'No clients yet',
                subtitle: 'Add your first client to get started.',
              ),
            )
          else
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: DataTable(
                            columns: const [
                              DataColumn(label: Text('#')),
                              DataColumn(label: Text('Name')),
                              DataColumn(label: Text('Father')),
                              DataColumn(label: Text('Phone')),
                              DataColumn(label: Text('Document')),
                              DataColumn(label: Text('Payment')),
                              DataColumn(label: Text('Status')),
                              DataColumn(label: Text('Actions')),
                            ],
                            rows: _paginated.asMap().entries.map((entry) {
                              final i = entry.key + (_page * _pageSize);
                              final u = entry.value;
                              return DataRow(cells: [
                                DataCell(Text('${i + 1}')),
                                DataCell(Text(u.fullName, style: const TextStyle(fontWeight: FontWeight.w600))),
                                DataCell(Text(u.fatherName)),
                                DataCell(Text(u.mobileNumber)),
                                DataCell(ConstrainedBox(
                                  constraints: const BoxConstraints(maxWidth: 120),
                                  child: Text(u.selectedDoc, overflow: TextOverflow.ellipsis),
                                )),
                                DataCell(StatusBadge(label: u.paymentStatus, color: AppTheme.getPaymentColor(u.paymentStatus))),
                                DataCell(StatusBadge(label: u.finalDocStatus, color: AppTheme.getDocStatusColor(u.finalDocStatus))),
                                DataCell(Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    _IconBtn(icon: Icons.visibility_outlined, tooltip: 'View', color: AppTheme.info, onTap: () => _viewClient(u)),
                                    _IconBtn(icon: Icons.edit_outlined, tooltip: 'Edit', color: AppTheme.primary, onTap: () => _editClient(u)),
                                    _IconBtn(icon: Icons.delete_outline, tooltip: 'Delete', color: AppTheme.error, onTap: () => _confirmDelete(u)),
                                  ],
                                )),
                              ]);
                            }).toList(),
                          ),
                        ),
                      ),
                    ),
                    // Pagination
                    if (totalPages > 1)
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(border: Border(top: BorderSide(color: Colors.grey.shade200))),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            IconButton(
                              onPressed: _page > 0 ? () => setState(() => _page--) : null,
                              icon: const Icon(Icons.chevron_left, size: 20),
                            ),
                            ...List.generate(totalPages.clamp(0, 7), (i) {
                              final isActive = i == _page;
                              return Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 2),
                                child: InkWell(
                                  onTap: () => setState(() => _page = i),
                                  borderRadius: BorderRadius.circular(6),
                                  child: Container(
                                    width: 32,
                                    height: 32,
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      color: isActive ? AppTheme.primary : Colors.transparent,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text('${i + 1}', style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                                      color: isActive ? Colors.white : Colors.grey.shade600,
                                    )),
                                  ),
                                ),
                              );
                            }),
                            IconButton(
                              onPressed: _page < totalPages - 1 ? () => setState(() => _page++) : null,
                              icon: const Icon(Icons.chevron_right, size: 20),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _viewClient(ClientUser u) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600, maxHeight: 700),
          child: _ClientDetailView(user: u),
        ),
      ),
    );
  }

  void _editClient(ClientUser u) {
    showDialog(
      context: context,
      builder: (ctx) => _EditClientDialog(
        user: u,
        onSave: (updates) async {
          await widget.docService.updateClient(u.key!, updates);
          if (ctx.mounted) Navigator.of(ctx).pop();
        },
      ),
    );
  }

  void _confirmDelete(ClientUser u) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.warning_amber_rounded, color: AppTheme.error, size: 24),
            const SizedBox(width: 8),
            const Text('Delete Client'),
          ],
        ),
        content: Text('Are you sure you want to delete ${u.fullName}? This action cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.error),
            onPressed: () async {
              await widget.docService.deleteClient(u.key!);
              if (ctx.mounted) Navigator.of(ctx).pop();
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

class _IconBtn extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final Color color;
  final VoidCallback onTap;

  const _IconBtn({required this.icon, required this.tooltip, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6),
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: Icon(icon, size: 16, color: color),
        ),
      ),
    );
  }
}

class _ClientDetailView extends StatelessWidget {
  final ClientUser user;
  const _ClientDetailView({required this.user});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: AppTheme.primary.withAlpha(20),
                  child: Text(user.fullName.isNotEmpty ? user.fullName[0].toUpperCase() : '?',
                      style: const TextStyle(color: AppTheme.primary, fontWeight: FontWeight.w700, fontSize: 18)),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(user.fullName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                      Text(user.email, style: TextStyle(fontSize: 13, color: Colors.grey.shade500)),
                    ],
                  ),
                ),
                IconButton(onPressed: () => Navigator.of(context).pop(), icon: const Icon(Icons.close)),
              ],
            ),
            const SizedBox(height: 20),
            _DetailRow('Father\'s Name', user.fatherName),
            _DetailRow('Mobile', user.mobileNumber),
            _DetailRow('Document Type', user.selectedDoc),
            const Divider(height: 24),
            const Text('Owner Details', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
            const SizedBox(height: 8),
            _DetailRow('Name', user.currentOwnerName),
            _DetailRow('Address', user.currentOwnerAddress),
            _DetailRow('Age / Gender', '${user.currentOwnerAge} / ${user.currentOwnerGender}'),
            const Divider(height: 24),
            const Text('Buyer Details', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
            const SizedBox(height: 8),
            _DetailRow('Relation', user.selectBuyerRelation),
            _DetailRow('Name', user.buyerName),
            _DetailRow('Address', user.buyerAddress),
            _DetailRow('Age / Gender', '${user.buyerAge} / ${user.selectedBuyGender}'),
            const Divider(height: 24),
            Row(
              children: [
                StatusBadge(label: user.paymentStatus, color: AppTheme.getPaymentColor(user.paymentStatus)),
                const SizedBox(width: 8),
                StatusBadge(label: user.finalDocStatus, color: AppTheme.getDocStatusColor(user.finalDocStatus)),
              ],
            ),
            if (user.notes.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text('Notes:', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12, color: Colors.grey.shade600)),
              Text(user.notes, style: const TextStyle(fontSize: 13)),
            ],
            if (user.originalNames.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text('Uploaded Files:', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12, color: Colors.grey.shade600)),
              const SizedBox(height: 4),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: user.originalNames.map((f) => Chip(
                  avatar: const Icon(Icons.insert_drive_file, size: 14),
                  label: Text(f, style: const TextStyle(fontSize: 11)),
                )).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  const _DetailRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text('$label:', style: TextStyle(fontSize: 12, color: Colors.grey.shade500, fontWeight: FontWeight.w500)),
          ),
          Expanded(child: Text(value.isEmpty ? '-' : value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500))),
        ],
      ),
    );
  }
}

class _EditClientDialog extends StatefulWidget {
  final ClientUser user;
  final Future<void> Function(Map<String, dynamic>) onSave;

  const _EditClientDialog({required this.user, required this.onSave});

  @override
  State<_EditClientDialog> createState() => _EditClientDialogState();
}

class _EditClientDialogState extends State<_EditClientDialog> {
  late final TextEditingController _fullName;
  late final TextEditingController _fatherName;
  late final TextEditingController _email;
  late final TextEditingController _notes;
  late String _paymentStatus;
  late String _docStatus;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _fullName = TextEditingController(text: widget.user.fullName);
    _fatherName = TextEditingController(text: widget.user.fatherName);
    _email = TextEditingController(text: widget.user.email);
    _notes = TextEditingController(text: widget.user.notes);
    _paymentStatus = widget.user.paymentStatus;
    _docStatus = widget.user.finalDocStatus;
  }

  @override
  void dispose() {
    _fullName.dispose();
    _fatherName.dispose();
    _email.dispose();
    _notes.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 500),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.edit_outlined, color: AppTheme.primary, size: 20),
                    const SizedBox(width: 8),
                    Text('Edit: ${widget.user.fullName}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                    const Spacer(),
                    IconButton(onPressed: () => Navigator.of(context).pop(), icon: const Icon(Icons.close, size: 20)),
                  ],
                ),
                const SizedBox(height: 20),
                TextField(controller: _fullName, decoration: const InputDecoration(labelText: 'Full Name')),
                const SizedBox(height: 12),
                TextField(controller: _fatherName, decoration: const InputDecoration(labelText: "Father's Name")),
                const SizedBox(height: 12),
                TextField(controller: _email, decoration: const InputDecoration(labelText: 'Email')),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: _paymentStatus.isEmpty ? null : _paymentStatus,
                  decoration: const InputDecoration(labelText: 'Payment Status'),
                  items: AppConstants.paymentStatuses.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                  onChanged: (v) => setState(() => _paymentStatus = v ?? ''),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: _docStatus.isEmpty ? null : _docStatus,
                  decoration: const InputDecoration(labelText: 'Document Status'),
                  items: AppConstants.documentStatuses.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                  onChanged: (v) => setState(() => _docStatus = v ?? ''),
                ),
                const SizedBox(height: 12),
                TextField(controller: _notes, maxLines: 2, decoration: const InputDecoration(labelText: 'Notes')),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: _saving
                          ? null
                          : () async {
                              setState(() => _saving = true);
                              await widget.onSave({
                                'fullName': _fullName.text.trim(),
                                'fatherName': _fatherName.text.trim(),
                                'email': _email.text.trim(),
                                'paymentStatus': _paymentStatus,
                                'finalDocStatus': _docStatus,
                                'notes': _notes.text.trim(),
                              });
                            },
                      child: _saving
                          ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : const Text('Save Changes'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
