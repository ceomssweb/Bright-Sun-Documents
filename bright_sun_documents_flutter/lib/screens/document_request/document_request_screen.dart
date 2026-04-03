import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../../services/users_documents_service.dart';
import '../../widgets/header_widget.dart';
import '../../widgets/footer_widget.dart';
import '../../theme/app_theme.dart';
import 'send_documents_screen.dart';
import 'view_documents_screen.dart';
import 'report_documents_screen.dart';
import 'settings_screen.dart';
import 'view_emp_screen.dart';

class DocumentRequestScreen extends StatefulWidget {
  const DocumentRequestScreen({super.key});

  @override
  State<DocumentRequestScreen> createState() => _DocumentRequestScreenState();
}

class _DocumentRequestScreenState extends State<DocumentRequestScreen> {
  String _title = 'Welcome to Bright Sun Documents';
  int _selectedIndex = 0;
  List<Map<dynamic, dynamic>> _employees = [];
  Map<dynamic, dynamic>? _selectedEmp;
  bool _showEmpDialog = false;

  late UsersDocumentsService _userService;

  @override
  void initState() {
    super.initState();
    final auth = context.read<AuthService>();
    _userService = UsersDocumentsService(auth);
    _loadEmployees(auth);
  }

  void _loadEmployees(AuthService auth) {
    if (auth.userEmail == UsersDocumentsService.adminUser) {
      auth.getEmpListRef().onValue.listen((event) {
        final data = event.snapshot.value;
        if (data != null && data is Map) {
          final emps = <Map<dynamic, dynamic>>[];
          data.forEach((key, value) {
            if (value is Map && value['mail'] != UsersDocumentsService.adminUser) {
              emps.add({...value, 'dbKey': key});
            }
          });
          if (mounted) setState(() => _employees = emps);
        }
      });
    }
  }

  void _selectMenu(int index, String title) {
    setState(() {
      _selectedIndex = index;
      _title = title;
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthService>();
    final isAdmin = auth.userEmail == UsersDocumentsService.adminUser;

    return Scaffold(
      appBar: HeaderWidget(authService: auth),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Text(_title,
                    style: Theme.of(context).textTheme.headlineMedium),
              ],
            ),
          ),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Sidebar menu
                SizedBox(
                  width: 220,
                  child: Card(
                    margin: const EdgeInsets.only(left: 8, bottom: 8),
                    child: ListView(
                      children: [
                        _menuTile(0, Icons.badge, 'My Profile',
                            'Welcome to Bright Sun Documents'),
                        _menuTile(1, Icons.person_add, 'Add Client',
                            'Enter Client Details to send Documents'),
                        _menuTile(2, Icons.visibility, 'View/Edit Client',
                            'View/Edit Client'),
                        _menuTile(3, Icons.bar_chart, 'Report',
                            'Overall Report of available Clients'),
                        _menuTile(4, Icons.settings, 'Settings', 'Settings'),
                        ListTile(
                          leading: const Icon(Icons.translate,
                              color: AppTheme.primaryColor),
                          title: const Text('Translate Document',
                              style: TextStyle(fontSize: 13)),
                          onTap: () => context.go('/translate-document'),
                        ),
                      ],
                    ),
                  ),
                ),
                // Content area
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: _buildContent(auth, isAdmin),
                  ),
                ),
              ],
            ),
          ),
          const FooterWidget(),
        ],
      ),
    );
  }

  ListTile _menuTile(int index, IconData icon, String label, String title) {
    return ListTile(
      leading: Icon(icon,
          color: _selectedIndex == index
              ? AppTheme.primaryColor
              : Colors.grey[600]),
      title: Text(label,
          style: TextStyle(
              fontSize: 13,
              fontWeight: _selectedIndex == index
                  ? FontWeight.bold
                  : FontWeight.normal)),
      selected: _selectedIndex == index,
      onTap: () => _selectMenu(index, title),
    );
  }

  Widget _buildContent(AuthService auth, bool isAdmin) {
    switch (_selectedIndex) {
      case 0:
        return _buildProfileSection(auth, isAdmin);
      case 1:
        return SendDocumentsScreen(userService: _userService);
      case 2:
        return ViewDocumentsScreen(userService: _userService);
      case 3:
        return ReportDocumentsScreen(userService: _userService);
      case 4:
        return SettingsScreen(authService: auth, userService: _userService);
      default:
        return _buildProfileSection(auth, isAdmin);
    }
  }

  Widget _buildProfileSection(AuthService auth, bool isAdmin) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // User profile
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundImage: auth.photoURL.isNotEmpty
                        ? NetworkImage(auth.photoURL)
                        : null,
                    child: auth.photoURL.isEmpty
                        ? const Icon(Icons.person, size: 30)
                        : null,
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(auth.displayName,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16)),
                      Text(auth.userEmail,
                          style: const TextStyle(color: Colors.grey)),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Employees table (admin only)
          if (isAdmin) ...[
            Text('Employees Details',
                style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 8),
            if (_employees.isEmpty)
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Center(child: Text('No users added yet!')),
                ),
              )
            else
              Card(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    columns: const [
                      DataColumn(label: Text('Sl/no.')),
                      DataColumn(label: Text('Name')),
                      DataColumn(label: Text('Email')),
                      DataColumn(label: Text('Actions')),
                    ],
                    rows: _employees.asMap().entries.map((entry) {
                      final i = entry.key;
                      final emp = entry.value;
                      return DataRow(cells: [
                        DataCell(Text('${i + 1}')),
                        DataCell(Text(emp['name']?.toString() ?? '')),
                        DataCell(Text(emp['mail']?.toString() ?? '')),
                        DataCell(
                          OutlinedButton(
                            onPressed: () {
                              setState(() {
                                _selectedEmp = emp;
                                _showEmpDialog = true;
                              });
                              _showEmployeeDialog(emp);
                            },
                            child: const Text('View Details',
                                style: TextStyle(fontSize: 12)),
                          ),
                        ),
                      ]);
                    }).toList(),
                  ),
                ),
              ),
          ],
        ],
      ),
    );
  }

  void _showEmployeeDialog(Map<dynamic, dynamic> emp) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        child: ConstrainedBox(
          constraints:
              const BoxConstraints(maxWidth: 800, maxHeight: 600),
          child: ViewEmpScreen(
            empData: emp,
            userService: _userService,
            onClose: () => Navigator.of(ctx).pop(),
          ),
        ),
      ),
    );
  }
}
