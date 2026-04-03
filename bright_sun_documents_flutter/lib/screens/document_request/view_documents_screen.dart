import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import '../../models/client_user.dart';
import '../../services/users_documents_service.dart';
import '../../theme/app_theme.dart';

class ViewDocumentsScreen extends StatefulWidget {
  final UsersDocumentsService userService;
  const ViewDocumentsScreen({super.key, required this.userService});

  @override
  State<ViewDocumentsScreen> createState() => _ViewDocumentsScreenState();
}

class _ViewDocumentsScreenState extends State<ViewDocumentsScreen> {
  List<ClientUser> _users = [];
  bool _loading = true;
  String _searchQuery = '';
  ClientUser? _editingUser;
  final bool _showEditDialog = false;
  int _currentPage = 0;
  static const int _pageSize = 10;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  void _loadUsers() {
    widget.userService.getUsersListRef().onValue.listen((event) {
      final data = event.snapshot.value;
      final users = <ClientUser>[];
      if (data != null && data is Map) {
        data.forEach((key, value) {
          if (value is Map) {
            users.add(ClientUser.fromMap(value, key: key.toString()));
          }
        });
      }
      if (mounted) {
        setState(() {
          _users = users;
          _loading = false;
        });
      }
    });
  }

  List<ClientUser> get _filteredUsers {
    if (_searchQuery.isEmpty) return _users;
    final q = _searchQuery.toLowerCase();
    return _users
        .where((u) =>
            u.fullName.toLowerCase().contains(q) ||
            u.mobileNumber.contains(q) ||
            u.email.toLowerCase().contains(q))
        .toList();
  }

  List<ClientUser> get _paginatedUsers {
    final filtered = _filteredUsers;
    final start = _currentPage * _pageSize;
    if (start >= filtered.length) return [];
    return filtered.sublist(
        start, (start + _pageSize).clamp(0, filtered.length));
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredUsers;
    final totalPages = (filtered.length / _pageSize).ceil();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Search
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: TextField(
            decoration: const InputDecoration(
              hintText: 'Search by name, phone or email...',
              prefixIcon: Icon(Icons.search),
              isDense: true,
            ),
            onChanged: (v) => setState(() {
              _searchQuery = v;
              _currentPage = 0;
            }),
          ),
        ),
        if (_loading)
          const Center(child: CircularProgressIndicator())
        else if (_users.isEmpty)
          const Card(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Center(child: Text('No clients added yet!')),
            ),
          )
        else
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      columns: const [
                        DataColumn(label: Text('Sl')),
                        DataColumn(label: Text('Name')),
                        DataColumn(label: Text('Father')),
                        DataColumn(label: Text('Phone')),
                        DataColumn(label: Text('Document')),
                        DataColumn(label: Text('Payment')),
                        DataColumn(label: Text('Status')),
                        DataColumn(label: Text('Actions')),
                      ],
                      rows: _paginatedUsers.asMap().entries.map((entry) {
                        final i = entry.key + (_currentPage * _pageSize);
                        final user = entry.value;
                        return DataRow(cells: [
                          DataCell(Text('${i + 1}')),
                          DataCell(Text(user.fullName)),
                          DataCell(Text(user.fatherName)),
                          DataCell(Text(user.mobileNumber)),
                          DataCell(Text(user.selectedDoc)),
                          DataCell(Text(user.paymentStatus)),
                          DataCell(Text(user.finalDocStatus)),
                          DataCell(Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit,
                                    size: 18, color: AppTheme.primaryColor),
                                tooltip: 'Edit',
                                onPressed: () => _showEdit(user),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete,
                                    size: 18, color: Colors.red),
                                tooltip: 'Delete',
                                onPressed: () => _confirmDelete(user),
                              ),
                            ],
                          )),
                        ]);
                      }).toList(),
                    ),
                  ),
                  // Pagination
                  if (totalPages > 1)
                    Padding(
                      padding: const EdgeInsets.all(8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            onPressed: _currentPage > 0
                                ? () =>
                                    setState(() => _currentPage--)
                                : null,
                            icon: const Icon(Icons.chevron_left),
                          ),
                          Text('Page ${_currentPage + 1} of $totalPages'),
                          IconButton(
                            onPressed: _currentPage < totalPages - 1
                                ? () =>
                                    setState(() => _currentPage++)
                                : null,
                            icon: const Icon(Icons.chevron_right),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  void _showEdit(ClientUser user) {
    showDialog(
      context: context,
      builder: (ctx) => _EditDialog(
        user: user,
        onSave: (updated, fileNames) async {
          await widget.userService
              .updateUser(user.key!, updated, fileNames);
          Navigator.of(ctx).pop();
        },
      ),
    );
  }

  void _confirmDelete(ClientUser user) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Client'),
        content: Text('Are you sure you want to delete ${user.fullName}?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              await widget.userService.deleteUser(user.key!);
              Navigator.of(ctx).pop();
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

class _EditDialog extends StatefulWidget {
  final ClientUser user;
  final Future<void> Function(ClientUser, List<String>) onSave;

  const _EditDialog({required this.user, required this.onSave});

  @override
  State<_EditDialog> createState() => _EditDialogState();
}

class _EditDialogState extends State<_EditDialog> {
  late TextEditingController _fullName;
  late TextEditingController _fatherName;
  late TextEditingController _email;
  late String _paymentStatus;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _fullName = TextEditingController(text: widget.user.fullName);
    _fatherName = TextEditingController(text: widget.user.fatherName);
    _email = TextEditingController(text: widget.user.email);
    _paymentStatus = widget.user.paymentStatus;
  }

  @override
  void dispose() {
    _fullName.dispose();
    _fatherName.dispose();
    _email.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Edit: ${widget.user.fullName}'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
                controller: _fullName,
                decoration: const InputDecoration(labelText: 'Full Name')),
            const SizedBox(height: 8),
            TextField(
                controller: _fatherName,
                decoration: const InputDecoration(labelText: "Father's Name")),
            const SizedBox(height: 8),
            TextField(
                controller: _email,
                decoration: const InputDecoration(labelText: 'Email')),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              initialValue: _paymentStatus.isEmpty ? null : _paymentStatus,
              decoration:
                  const InputDecoration(labelText: 'Payment Status'),
              items: ['Paid', 'Pending', 'Partial', 'Not Paid']
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: (v) => setState(() => _paymentStatus = v ?? ''),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel')),
        ElevatedButton(
          onPressed: _saving
              ? null
              : () async {
                  setState(() => _saving = true);
                  final updated = ClientUser(
                    fullName: _fullName.text,
                    fatherName: _fatherName.text,
                    email: _email.text,
                    mobileNumber: widget.user.mobileNumber,
                    selectedDoc: widget.user.selectedDoc,
                    currentOwnerName: widget.user.currentOwnerName,
                    currentOwnerAddress: widget.user.currentOwnerAddress,
                    currentOwnerAge: widget.user.currentOwnerAge,
                    currentOwnergender: widget.user.currentOwnergender,
                    selectBuyerRelation: widget.user.selectBuyerRelation,
                    buyerName: widget.user.buyerName,
                    buyerAddress: widget.user.buyerAddress,
                    buyerAge: widget.user.buyerAge,
                    selectedBuyGender: widget.user.selectedBuyGender,
                    paymentStatus: _paymentStatus,
                  );
                  await widget.onSave(
                      updated, widget.user.originalNames.toList());
                },
          child: const Text('Save'),
        ),
      ],
    );
  }
}
