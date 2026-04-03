import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../models/client_user.dart';
import '../../services/document_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';

class ReportsScreen extends StatefulWidget {
  final DocumentService docService;
  const ReportsScreen({super.key, required this.docService});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  List<ClientUser> _users = [];
  bool _loading = true;
  String? _error;
  dynamic _subscription;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    try {
      _subscription?.cancel();
      _subscription = widget.docService.getUsersListRef().onValue.listen(
        (event) {
          final data = event.snapshot.value;
          final users = <ClientUser>[];
          if (data != null && data is Map) {
            data.forEach((key, value) {
              if (value is Map) users.add(ClientUser.fromMap(value, key: key.toString()));
            });
          }
          if (mounted) setState(() { _users = users; _loading = false; _error = null; });
        },
        onError: (error) {
          if (mounted) setState(() { _error = 'Failed to load data: $error'; _loading = false; });
        },
      );
    } catch (e) {
      if (mounted) setState(() { _error = 'Database connection error: $e'; _loading = false; });
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  Map<String, int> _countBy(String Function(ClientUser) selector) {
    final counts = <String, int>{};
    for (final u in _users) {
      final key = selector(u).isEmpty ? 'Unknown' : selector(u);
      counts[key] = (counts[key] ?? 0) + 1;
    }
    return counts;
  }

  static final _chartColors = [
    AppTheme.primary,
    AppTheme.secondary,
    AppTheme.success,
    AppTheme.info,
    AppTheme.warning,
    AppTheme.error,
    const Color(0xFF7B1FA2),
    const Color(0xFF00695C),
    Colors.indigo,
    Colors.pink,
  ];

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: AppTheme.error, size: 48),
            const SizedBox(height: 12),
            Text(_error!, style: const TextStyle(color: AppTheme.error), textAlign: TextAlign.center),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: () { setState(() { _loading = true; _error = null; }); _loadData(); },
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    final paymentCounts = _countBy((u) => u.paymentStatus);
    final docTypeCounts = _countBy((u) => u.selectedDoc);
    final statusCounts = _countBy((u) => u.finalDocStatus);
    final isWide = MediaQuery.of(context).size.width > 800;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(title: 'Reports & Analytics'),
          Text('${_users.length} total clients', style: TextStyle(fontSize: 13, color: Colors.grey.shade500)),
          const SizedBox(height: 20),

          if (_users.isEmpty)
            const EmptyState(icon: Icons.bar_chart, title: 'No data available', subtitle: 'Add clients to see reports.')
          else ...[
            // Charts row
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                _ChartCard(
                  title: 'Payment Status',
                  width: isWide ? 380 : double.infinity,
                  child: _buildPieChart(paymentCounts, (k) => AppTheme.getPaymentColor(k)),
                ),
                _ChartCard(
                  title: 'Document Status',
                  width: isWide ? 380 : double.infinity,
                  child: _buildPieChart(statusCounts, (k) => AppTheme.getDocStatusColor(k)),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Document type distribution
            _ChartCard(
              title: 'Document Types',
              width: double.infinity,
              child: _buildBarChart(docTypeCounts),
            ),
            const SizedBox(height: 20),

            // Data table
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.all(16),
                    child: Text('Client Summary', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                  ),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      columns: const [
                        DataColumn(label: Text('#')),
                        DataColumn(label: Text('Name')),
                        DataColumn(label: Text('Document')),
                        DataColumn(label: Text('Payment')),
                        DataColumn(label: Text('Status')),
                      ],
                      rows: _users.asMap().entries.map((e) {
                        final u = e.value;
                        return DataRow(cells: [
                          DataCell(Text('${e.key + 1}')),
                          DataCell(Text(u.fullName, style: const TextStyle(fontWeight: FontWeight.w600))),
                          DataCell(Text(u.selectedDoc)),
                          DataCell(StatusBadge(label: u.paymentStatus, color: AppTheme.getPaymentColor(u.paymentStatus))),
                          DataCell(StatusBadge(label: u.finalDocStatus, color: AppTheme.getDocStatusColor(u.finalDocStatus))),
                        ]);
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPieChart(Map<String, int> data, Color Function(String) colorFn) {
    final entries = data.entries.toList();
    return SizedBox(
      height: 200,
      child: Row(
        children: [
          Expanded(
            child: PieChart(
              PieChartData(
                sections: entries.asMap().entries.map((e) {
                  final color = colorFn(e.value.key);
                  return PieChartSectionData(
                    value: e.value.value.toDouble(),
                    title: '${e.value.value}',
                    color: color,
                    radius: 60,
                    titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white),
                  );
                }).toList(),
                sectionsSpace: 3,
                centerSpaceRadius: 30,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: entries.map((e) {
              final color = colorFn(e.key);
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 3),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(width: 10, height: 10, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2))),
                    const SizedBox(width: 6),
                    Text('${e.key} (${e.value})', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500)),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildBarChart(Map<String, int> data) {
    final entries = data.entries.toList();
    return SizedBox(
      height: 200,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: (entries.isEmpty ? 10 : entries.map((e) => e.value).reduce((a, b) => a > b ? a : b) + 2).toDouble(),
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (v, meta) {
                  final i = v.toInt();
                  if (i >= 0 && i < entries.length) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        entries[i].key.length > 10 ? '${entries[i].key.substring(0, 10)}...' : entries[i].key,
                        style: const TextStyle(fontSize: 9),
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
                reservedSize: 36,
              ),
            ),
            leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 28, getTitlesWidget: (v, _) => Text('${v.toInt()}', style: const TextStyle(fontSize: 10)))),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          gridData: FlGridData(show: true, drawVerticalLine: false, horizontalInterval: 2, getDrawingHorizontalLine: (_) => FlLine(color: Colors.grey.shade200, strokeWidth: 1)),
          borderData: FlBorderData(show: false),
          barGroups: entries.asMap().entries.map((e) {
            return BarChartGroupData(x: e.key, barRods: [
              BarChartRodData(
                toY: e.value.value.toDouble(),
                color: _chartColors[e.key % _chartColors.length],
                width: 20,
                borderRadius: const BorderRadius.only(topLeft: Radius.circular(4), topRight: Radius.circular(4)),
              ),
            ]);
          }).toList(),
        ),
      ),
    );
  }
}

class _ChartCard extends StatelessWidget {
  final String title;
  final double width;
  final Widget child;

  const _ChartCard({required this.title, required this.width, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width == double.infinity ? width : width,
      constraints: BoxConstraints(maxWidth: width == double.infinity ? double.infinity : width),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppTheme.tertiary)),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}
