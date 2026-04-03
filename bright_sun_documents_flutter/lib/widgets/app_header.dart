import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../services/auth_service.dart';
import '../theme/app_theme.dart';

class AppHeader extends StatelessWidget implements PreferredSizeWidget {
  final AuthService authService;
  const AppHeader({super.key, required this.authService});

  @override
  Size get preferredSize => const Size.fromHeight(60);

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 768;
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: Colors.black.withAlpha(8), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              // Logo
              InkWell(
                onTap: () => context.go(authService.isLoggedIn ? '/dashboard' : '/'),
                borderRadius: BorderRadius.circular(8),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppTheme.primary, AppTheme.primaryLight],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.description_rounded, color: Colors.white, size: 20),
                    ),
                    if (isWide) ...[
                      const SizedBox(width: 10),
                      const Text(
                        'Bright Sun Documents',
                        style: TextStyle(
                          color: AppTheme.primary,
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.3,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const Spacer(),
              // Nav items
              if (authService.isLoggedIn) ...[
                _NavButton(label: 'Dashboard', icon: Icons.dashboard_outlined, onTap: () => context.go('/dashboard')),
                if (isWide) _NavButton(label: 'Translate', icon: Icons.translate, onTap: () => context.go('/translate')),
                const SizedBox(width: 8),
                // User avatar & info
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceDim,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircleAvatar(
                        radius: 14,
                        backgroundColor: AppTheme.primary.withAlpha(30),
                        backgroundImage:
                            authService.photoURL.isNotEmpty ? NetworkImage(authService.photoURL) : null,
                        child: authService.photoURL.isEmpty
                            ? Text(
                                authService.displayName.isNotEmpty ? authService.displayName[0].toUpperCase() : 'U',
                                style: const TextStyle(color: AppTheme.primary, fontSize: 12, fontWeight: FontWeight.w700),
                              )
                            : null,
                      ),
                      if (isWide) ...[
                        const SizedBox(width: 8),
                        Text(
                          authService.displayName,
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.tertiary),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 4),
                IconButton(
                  onPressed: () async {
                    await authService.signOut();
                    if (context.mounted) context.go('/');
                  },
                  icon: const Icon(Icons.logout_rounded, size: 20),
                  tooltip: 'Sign Out',
                  style: IconButton.styleFrom(foregroundColor: AppTheme.error),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _NavButton({required this.label, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 18),
      label: Text(label, style: const TextStyle(fontSize: 13)),
    );
  }
}
