import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import '../../models/client_user.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';

class EmployeeListScreen extends StatefulWidget {
  const EmployeeListScreen({super.key});

  @override
  State<EmployeeListScreen> createState() => _EmployeeListScreenState();
}

class _EmployeeListScreenState extends State<EmployeeListScreen> {
  bool _loading = true;
  List<Map<String, dynamic>> _employees = [];
  String _search = '';

  @override
  void initState() {
    super.initState();
    _loadEmployees();
  }

  Future<void> _loadEmployees() async {
    setState(() => _loading = true);
    try {
      final snap = await FirebaseDatabase.instance.ref('Emp-list').get();
      final empList = <Map<String, dynamic>>[];
      if (snap.exists && snap.value is Map) {
        (snap.value as Map).forEach((key, value) {
          if (value is Map) {
            empList.add({
              'key': key.toString(),
              'email': value['email']?.toString() ?? '',
              'displayName': value['displayName']?.toString() ?? key.toString(),
              'uid': value['uid']?.toString() ?? '',
            });
          }
        });
      }
      if (mounted) setState(() { _employees = empList; _loading = false; });
    } catch (e) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _viewClientsForEmployee(Map<String, dynamic> emp) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final uid = emp['uid'] ?? emp['key'];
      final snap = await FirebaseDatabase.instance.ref('users-list/$uid').get();
      final clients = <ClientUser>[];
      if (snap.exists && snap.value is Map) {
        (snap.value as Map).forEach((key, value) {
          if (value is Map) clients.add(ClientUser.fromMap(value, key: key.toString()));
        });
      }
      if (mounted) Navigator.of(context).pop(); // close loading
      if (mounted) {
        showDialog(
          context: context,
          builder: (_) => _EmployeeClientsDialog(
            employeeName: emp['displayName'] ?? emp['email'],
            clients: clients,
          ),
        );
      }
    } catch (e) {
      if (mounted) Navigator.of(context).pop();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error loading clients: $e'), backgroundColor: AppTheme.error));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());

    final filtered = _employees.where((e) {
      final q = _search.toLowerCase();
      return e['email'].toString().toLowerCase().contains(q) ||
          e['displayName'].toString().toLowerCase().contains(q);
    }).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(title: 'Employee Management'),
          const SizedBox(height: 12),

          TextField(
            decoration: InputDecoration(
              hintText: 'Search employees...',
              prefixIcon: const Icon(Icons.search, size: 20),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade300)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade300)),
            ),
            onChanged: (v) => setState(() => _search = v),
          ),
          const SizedBox(height: 16),

          if (filtered.isEmpty)
            const EmptyState(icon: Icons.people_outline, title: 'No employees found', subtitle: 'Register employees to see them here.')
          else
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: filtered.length,
                separatorBuilder: (_, __) => Divider(height: 1, color: Colors.grey.shade200),
                itemBuilder: (context, i) {
                  final emp = filtered[i];
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: AppTheme.primary.withValues(alpha: 0.1),
                      child: Text(
                        (emp['displayName'] as String?)?.isNotEmpty == true
                            ? emp['displayName'][0].toUpperCase()
                            : '?',
                        style: const TextStyle(fontWeight: FontWeight.w700, color: AppTheme.primary),
                      ),
                    ),
                    title: Text(emp['displayName'] ?? 'Unknown', style: const TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: Text(emp['email'] ?? '', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                    trailing: FilledButton.icon(
                      onPressed: () => _viewClientsForEmployee(emp),
                      icon: const Icon(Icons.visibility, size: 16),
                      label: const Text('Clients'),
                      style: FilledButton.styleFrom(
                        backgroundColor: AppTheme.primary,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        textStyle: const TextStyle(fontSize: 12),
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}

class _EmployeeClientsDialog extends StatelessWidget {
  final String employeeName;
  final List<ClientUser> clients;

  const _EmployeeClientsDialog({required this.employeeName, required this.clients});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 700, maxHeight: 500),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.primary.withValues(alpha: 0.05),
                borderRadius: const BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.people, color: AppTheme.primary),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(employeeName, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                        Text('${clients.length} client(s)', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                      ],
                    ),
                  ),
                  IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.of(context).pop()),
                ],
              ),
            ),
            if (clients.isEmpty)
              const Padding(
                padding: EdgeInsets.all(40),
                child: Text('No clients found for this employee.', style: TextStyle(color: Colors.grey)),
              )
            else
              Flexible(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: SingleChildScrollView(
                    child: DataTable(
                      columns: const [
                        DataColumn(label: Text('#')),
                        DataColumn(label: Text('Name')),
                        DataColumn(label: Text('Document')),
                        DataColumn(label: Text('Payment')),
                        DataColumn(label: Text('Status')),
                      ],
                      rows: clients.asMap().entries.map((e) {
                        final c = e.value;
                        return DataRow(cells: [
                          DataCell(Text('${e.key + 1}')),
                          DataCell(Text(c.fullName, style: const TextStyle(fontWeight: FontWeight.w600))),
                          DataCell(Text(c.selectedDoc)),
                          DataCell(StatusBadge(label: c.paymentStatus, color: AppTheme.getPaymentColor(c.paymentStatus))),
                          DataCell(StatusBadge(label: c.finalDocStatus, color: AppTheme.getDocStatusColor(c.finalDocStatus))),
                        ]);
                      }).toList(),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
