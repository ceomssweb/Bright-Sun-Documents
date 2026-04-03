import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../../services/document_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_header.dart';
import '../../widgets/app_footer.dart';
import '../clients/add_client_screen.dart';
import '../clients/client_list_screen.dart';
import '../reports/reports_screen.dart';
import '../employees/employee_list_screen.dart';
import '../settings/settings_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;
  late DocumentService _docService;

  final _menuItems = <_MenuItem>[
    _MenuItem(Icons.dashboard_rounded, 'Overview'),
    _MenuItem(Icons.person_add_rounded, 'Add Client'),
    _MenuItem(Icons.people_rounded, 'Clients'),
    _MenuItem(Icons.bar_chart_rounded, 'Reports'),
    _MenuItem(Icons.settings_rounded, 'Settings'),
  ];

  @override
  void initState() {
    super.initState();
    _docService = DocumentService(context.read<AuthService>());
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthService>();
    final isWide = MediaQuery.of(context).size.width > 900;
    final isMedium = MediaQuery.of(context).size.width > 600;

    return Scaffold(
      appBar: AppHeader(authService: auth),
      body: Column(
        children: [
          Expanded(
            child: Row(
              children: [
                // Sidebar
                if (isMedium)
                  Container(
                    width: isWide ? 220 : 72,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border(right: BorderSide(color: Colors.grey.shade200)),
                    ),
                    child: Column(
                      children: [
                        const SizedBox(height: 8),
                        ...List.generate(_menuItems.length, (i) {
                          final item = _menuItems[i];
                          final isActive = _selectedIndex == i;
                          return _SidebarItem(
                            icon: item.icon,
                            label: item.label,
                            isActive: isActive,
                            isExpanded: isWide,
                            onTap: () => setState(() => _selectedIndex = i),
                          );
                        }),
                        if (auth.isAdmin) ...[
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            child: Divider(),
                          ),
                          _SidebarItem(
                            icon: Icons.supervisor_account_rounded,
                            label: 'Employees',
                            isActive: _selectedIndex == 5,
                            isExpanded: isWide,
                            onTap: () => setState(() => _selectedIndex = 5),
                          ),
                        ],
                        const Spacer(),
                        _SidebarItem(
                          icon: Icons.translate,
                          label: 'Translate',
                          isActive: false,
                          isExpanded: isWide,
                          onTap: () => context.go('/translate'),
                        ),
                        const SizedBox(height: 12),
                      ],
                    ),
                  ),
                // Content
                Expanded(
                  child: Container(
                    color: AppTheme.surface,
                    child: _buildContent(auth),
                  ),
                ),
              ],
            ),
          ),
          const AppFooter(),
        ],
      ),
      // Bottom nav on narrow screens
      bottomNavigationBar: !isMedium
          ? NavigationBar(
              selectedIndex: _selectedIndex.clamp(0, 4),
              onDestinationSelected: (i) => setState(() => _selectedIndex = i),
              destinations: _menuItems
                  .map((m) => NavigationDestination(icon: Icon(m.icon), label: m.label))
                  .toList(),
            )
          : null,
    );
  }

  Widget _buildContent(AuthService auth) {
    switch (_selectedIndex) {
      case 0:
        return _OverviewTab(auth: auth, docService: _docService);
      case 1:
        return AddClientScreen(docService: _docService);
      case 2:
        return ClientListScreen(docService: _docService);
      case 3:
        return ReportsScreen(docService: _docService);
      case 4:
        return SettingsScreen(authService: auth);
      case 5:
        return const EmployeeListScreen();
      default:
        return _OverviewTab(auth: auth, docService: _docService);
    }
  }
}

class _MenuItem {
  final IconData icon;
  final String label;
  const _MenuItem(this.icon, this.label);
}

class _SidebarItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final bool isExpanded;
  final VoidCallback onTap;

  const _SidebarItem({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.isExpanded,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      child: Material(
        color: isActive ? AppTheme.primary.withAlpha(15) : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: isExpanded ? 14 : 0, vertical: 12),
            child: Row(
              mainAxisAlignment: isExpanded ? MainAxisAlignment.start : MainAxisAlignment.center,
              children: [
                Icon(icon, size: 20, color: isActive ? AppTheme.primary : Colors.grey.shade600),
                if (isExpanded) ...[
                  const SizedBox(width: 12),
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                      color: isActive ? AppTheme.primary : Colors.grey.shade700,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Overview Tab ───

class _OverviewTab extends StatefulWidget {
  final AuthService auth;
  final DocumentService docService;
  const _OverviewTab({required this.auth, required this.docService});

  @override
  State<_OverviewTab> createState() => _OverviewTabState();
}

class _OverviewTabState extends State<_OverviewTab> {
  int _totalClients = 0;
  int _paidCount = 0;
  int _pendingCount = 0;
  int _completedCount = 0;
  bool _loading = true;
  final List<Map<String, String>> _recentClients = [];
  dynamic _subscription;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  void _loadStats() {
    _subscription = widget.docService.getUsersListRef().onValue.listen((event) {
      final data = event.snapshot.value;
      int total = 0, paid = 0, pending = 0, completed = 0;
      final recent = <Map<String, String>>[];

      if (data != null && data is Map) {
        data.forEach((key, value) {
          if (value is Map) {
            total++;
            final ps = value['paymentStatus']?.toString().toLowerCase() ?? '';
            if (ps == 'paid') paid++;
            if (ps == 'pending' || ps == 'partial' || ps == 'not paid') pending++;
            final ds = value['finalDocStatus']?.toString().toLowerCase() ?? '';
            if (ds == 'completed' || ds == 'delivered') completed++;
            if (recent.length < 5) {
              recent.add({
                'name': value['fullName']?.toString() ?? '',
                'doc': value['selectedDoc']?.toString() ?? '',
                'status': value['finalDocStatus']?.toString() ?? '',
                'payment': value['paymentStatus']?.toString() ?? '',
              });
            }
          }
        });
      }

      if (mounted) {
        setState(() {
          _totalClients = total;
          _paidCount = paid;
          _pendingCount = pending;
          _completedCount = completed;
          _recentClients.clear();
          _recentClients.addAll(recent);
          _loading = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 800;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Greeting
          Text(
            'Good ${_getGreeting()}, ${widget.auth.displayName}!',
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppTheme.tertiary),
          ),
          const SizedBox(height: 4),
          Text(
            'Here\'s an overview of your document management.',
            style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
          ),
          const SizedBox(height: 24),

          // Stats
          if (_loading)
            const Center(child: Padding(padding: EdgeInsets.all(40), child: CircularProgressIndicator()))
          else ...[
            GridView.count(
              crossAxisCount: isWide ? 4 : 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 14,
              mainAxisSpacing: 14,
              childAspectRatio: isWide ? 2.2 : 1.8,
              children: [
                _StatTile(
                  title: 'Total Clients',
                  value: '$_totalClients',
                  icon: Icons.people_rounded,
                  color: AppTheme.primary,
                ),
                _StatTile(
                  title: 'Paid',
                  value: '$_paidCount',
                  icon: Icons.check_circle_rounded,
                  color: AppTheme.success,
                ),
                _StatTile(
                  title: 'Pending Payments',
                  value: '$_pendingCount',
                  icon: Icons.pending_rounded,
                  color: AppTheme.warning,
                ),
                _StatTile(
                  title: 'Completed',
                  value: '$_completedCount',
                  icon: Icons.task_alt_rounded,
                  color: AppTheme.info,
                ),
              ],
            ),

            const SizedBox(height: 28),

            // Recent clients
            _buildRecentClients(),

            const SizedBox(height: 20),

            // Quick actions
            _buildQuickActions(context),
          ],
        ],
      ),
    );
  }

  Widget _buildRecentClients() {
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
          const Row(
            children: [
              Icon(Icons.history, size: 18, color: AppTheme.primary),
              SizedBox(width: 8),
              Text('Recent Clients', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppTheme.tertiary)),
            ],
          ),
          const SizedBox(height: 16),
          if (_recentClients.isEmpty)
            Padding(
              padding: const EdgeInsets.all(20),
              child: Center(
                child: Text('No clients added yet.', style: TextStyle(color: Colors.grey.shade400, fontSize: 13)),
              ),
            )
          else
            ...List.generate(_recentClients.length, (i) {
              final c = _recentClients[i];
              return Container(
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
                decoration: BoxDecoration(
                  border: i < _recentClients.length - 1 ? Border(bottom: BorderSide(color: Colors.grey.shade100)) : null,
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 18,
                      backgroundColor: AppTheme.primary.withAlpha(15),
                      child: Text(
                        c['name']!.isNotEmpty ? c['name']![0].toUpperCase() : '?',
                        style: const TextStyle(color: AppTheme.primary, fontWeight: FontWeight.w700, fontSize: 14),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(c['name']!, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                          Text(c['doc']!, style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
                        ],
                      ),
                    ),
                    _MiniStatusBadge(label: c['status']!, color: AppTheme.getDocStatusColor(c['status']!)),
                    const SizedBox(width: 8),
                    _MiniStatusBadge(label: c['payment']!, color: AppTheme.getPaymentColor(c['payment']!)),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
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
          const Row(
            children: [
              Icon(Icons.flash_on_rounded, size: 18, color: AppTheme.secondary),
              SizedBox(width: 8),
              Text('Quick Actions', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppTheme.tertiary)),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _ActionChip(icon: Icons.person_add, label: 'New Client', color: AppTheme.primary, onTap: () {}),
              _ActionChip(icon: Icons.translate, label: 'Translate Doc', color: AppTheme.info, onTap: () => context.go('/translate')),
              _ActionChip(icon: Icons.bar_chart, label: 'View Reports', color: AppTheme.success, onTap: () {}),
            ],
          ),
        ],
      ),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'morning';
    if (hour < 17) return 'afternoon';
    return 'evening';
  }
}

class _StatTile extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatTile({required this.title, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(color: color.withAlpha(20), borderRadius: BorderRadius.circular(10)),
                child: Icon(icon, color: color, size: 18),
              ),
              const Spacer(),
            ],
          ),
          const SizedBox(height: 12),
          Text(value, style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: color, height: 1)),
          const SizedBox(height: 4),
          Text(title, style: TextStyle(fontSize: 12, color: Colors.grey.shade500, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}

class _MiniStatusBadge extends StatelessWidget {
  final String label;
  final Color color;
  const _MiniStatusBadge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    if (label.isEmpty) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withAlpha(15),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: color)),
    );
  }
}

class _ActionChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionChip({required this.icon, required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color.withAlpha(12),
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 8),
              Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: color)),
            ],
          ),
        ),
      ),
    );
  }
}
