import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../models/client_user.dart';
import '../../services/users_documents_service.dart';

class ReportDocumentsScreen extends StatefulWidget {
  final UsersDocumentsService userService;
  const ReportDocumentsScreen({super.key, required this.userService});

  @override
  State<ReportDocumentsScreen> createState() => _ReportDocumentsScreenState();
}

class _ReportDocumentsScreenState extends State<ReportDocumentsScreen> {
  List<ClientUser> _users = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
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
      if (mounted) setState(() { _users = users; _loading = false; });
    });
  }

  Map<String, int> get _paymentCounts {
    final counts = <String, int>{};
    for (final u in _users) {
      final status = u.paymentStatus.isEmpty ? 'Unknown' : u.paymentStatus;
      counts[status] = (counts[status] ?? 0) + 1;
    }
    return counts;
  }

  static const _colors = [
    Color(0xFF42A5F5),
    Color(0xFF66BB6A),
    Color(0xFFFFA726),
    Color(0xFF808080),
    Color(0xFF696969),
    Color(0xFFEF5350),
    Color(0xFFAB47BC),
  ];

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_users.isEmpty) {
      return const Center(child: Text('No data available'));
    }

    final counts = _paymentCounts;
    final entries = counts.entries.toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Payment Status Report',
              style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 16),
          // Pie chart
          SizedBox(
            height: 250,
            child: PieChart(
              PieChartData(
                sections: entries.asMap().entries.map((e) {
                  final i = e.key;
                  final entry = e.value;
                  return PieChartSectionData(
                    value: entry.value.toDouble(),
                    title: '${entry.key}\n(${entry.value})',
                    color: _colors[i % _colors.length],
                    radius: 80,
                    titleStyle: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  );
                }).toList(),
                sectionsSpace: 2,
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text('Payment Details',
              style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columns: const [
                DataColumn(label: Text('Sl')),
                DataColumn(label: Text('Name')),
                DataColumn(label: Text('Document')),
                DataColumn(label: Text('Payment Status')),
              ],
              rows: _users.asMap().entries.map((entry) {
                final i = entry.key;
                final user = entry.value;
                return DataRow(cells: [
                  DataCell(Text('${i + 1}')),
                  DataCell(Text(user.fullName)),
                  DataCell(Text(user.selectedDoc)),
                  DataCell(Text(user.paymentStatus)),
                ]);
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
