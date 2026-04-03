import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../services/auth_service.dart';
import '../theme/app_theme.dart';

class HeaderWidget extends StatelessWidget implements PreferredSizeWidget {
  final AuthService authService;

  const HeaderWidget({super.key, required this.authService});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 1,
      leading: Padding(
        padding: const EdgeInsets.all(4.0),
        child: Image.asset('assets/images/bsd_logo.png',
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) => const Icon(Icons.description,
                color: AppTheme.primaryColor, size: 32)),
      ),
      title: const Text(
        'Bright Sun Documents',
        style: TextStyle(color: AppTheme.primaryColor, fontSize: 16),
      ),
      actions: [
        TextButton(
          onPressed: () => context.go('/document-request'),
          child: const Text('Home'),
        ),
        TextButton(
          onPressed: () => context.go('/translate-document'),
          child: const Text('Translate'),
        ),
        if (authService.isLoggedIn) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Welcome: ${authService.displayName}',
                    style: const TextStyle(fontSize: 13, color: Colors.black87)),
                const SizedBox(width: 8),
                CircleAvatar(
                  radius: 14,
                  backgroundImage: authService.photoURL.isNotEmpty
                      ? NetworkImage(authService.photoURL)
                      : null,
                  child: authService.photoURL.isEmpty
                      ? const Icon(Icons.person, size: 16)
                      : null,
                ),
              ],
            ),
          ),
          TextButton.icon(
            onPressed: () async {
              await authService.signOut();
              if (context.mounted) context.go('/home-page');
            },
            icon: const Icon(Icons.logout, color: Colors.red, size: 16),
            label: const Text('Sign Out',
                style: TextStyle(color: Colors.red, fontSize: 13)),
          ),
        ],
      ],
    );
  }
}
