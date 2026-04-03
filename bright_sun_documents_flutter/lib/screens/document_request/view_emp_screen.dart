import 'package:flutter/material.dart';
import '../../models/client_user.dart';
import '../../services/users_documents_service.dart';

class ViewEmpScreen extends StatefulWidget {
  final Map<dynamic, dynamic> empData;
  final UsersDocumentsService userService;
  final VoidCallback onClose;

  const ViewEmpScreen({
    super.key,
    required this.empData,
    required this.userService,
    required this.onClose,
  });

  @override
  State<ViewEmpScreen> createState() => _ViewEmpScreenState();
}

class _ViewEmpScreenState extends State<ViewEmpScreen> {
  List<ClientUser> _clients = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadEmpClients();
  }

  void _loadEmpClients() {
    final empKey = widget.empData['key']?.toString() ?? '';
    if (empKey.isEmpty) {
      setState(() => _loading = false);
      return;
    }
    widget.userService.getEmpUsersRef(empKey).onValue.listen((event) {
      final data = event.snapshot.value;
      final clients = <ClientUser>[];
      if (data != null && data is Map) {
        data.forEach((key, value) {
          if (value is Map) {
            clients.add(ClientUser.fromMap(value, key: key.toString()));
          }
        });
      }
      if (mounted) setState(() { _clients = clients; _loading = false; });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.empData['name']?.toString() ?? 'Employee',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              IconButton(
                  onPressed: widget.onClose, icon: const Icon(Icons.close)),
            ],
          ),
          Text('Email: ${widget.empData['mail'] ?? ''}',
              style: const TextStyle(color: Colors.grey)),
          const Divider(),
          Text('Clients',
              style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 8),
          if (_loading)
            const Center(child: CircularProgressIndicator())
          else if (_clients.isEmpty)
            const Text('No clients found for this employee.')
          else
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columns: const [
                    DataColumn(label: Text('Sl')),
                    DataColumn(label: Text('Name')),
                    DataColumn(label: Text('Phone')),
                    DataColumn(label: Text('Document')),
                    DataColumn(label: Text('Payment')),
                    DataColumn(label: Text('Status')),
                  ],
                  rows: _clients.asMap().entries.map((entry) {
                    final i = entry.key;
                    final client = entry.value;
                    return DataRow(cells: [
                      DataCell(Text('${i + 1}')),
                      DataCell(Text(client.fullName)),
                      DataCell(Text(client.mobileNumber)),
                      DataCell(Text(client.selectedDoc)),
                      DataCell(Text(client.paymentStatus)),
                      DataCell(Text(client.finalDocStatus)),
                    ]);
                  }).toList(),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
