import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../services/auth_service.dart';
import '../../services/users_documents_service.dart';

class SettingsScreen extends StatelessWidget {
  final AuthService authService;
  final UsersDocumentsService userService;

  const SettingsScreen({
    super.key,
    required this.authService,
    required this.userService,
  });

  @override
  Widget build(BuildContext context) {
    final isAdmin =
        authService.userEmail == UsersDocumentsService.adminUser;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('User Setting',
                      style: Theme.of(context).textTheme.headlineSmall),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Text('1. To Change/Reset your Password: '),
                      TextButton(
                        onPressed: () => context.go('/forgot-password'),
                        child: const Text('Change Password'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          if (isAdmin) ...[
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Admin Setting',
                        style: Theme.of(context).textTheme.headlineSmall),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Text('1. Remove/Terminate Employee: '),
                        TextButton(
                          onPressed: () {},
                          child: const Text('Click here'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
