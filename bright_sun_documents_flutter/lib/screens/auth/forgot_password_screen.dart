import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_footer.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailCtrl = TextEditingController();
  bool _loading = false;
  bool _sent = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    super.dispose();
  }

  Future<void> _reset() async {
    if (_emailCtrl.text.trim().isEmpty) return;
    setState(() => _loading = true);
    final error = await context.read<AuthService>().forgotPassword(_emailCtrl.text);
    if (mounted) {
      setState(() {
        _loading = false;
        if (error == null) _sent = true;
      });
      if (error != null) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error), backgroundColor: AppTheme.error));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: Container(
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: _sent ? _buildSuccess() : _buildForm(),
                  ),
                ),
              ),
            ),
          ),
          const AppFooter(),
        ],
      ),
    );
  }

  Widget _buildForm() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: AppTheme.primary.withAlpha(15),
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Icon(Icons.lock_reset, color: AppTheme.primary, size: 28),
        ),
        const SizedBox(height: 20),
        const Text('Reset Password', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppTheme.tertiary)),
        const SizedBox(height: 8),
        Text('Enter your email to receive a reset link', style: TextStyle(fontSize: 13, color: Colors.grey.shade500)),
        const SizedBox(height: 28),
        TextField(
          controller: _emailCtrl,
          keyboardType: TextInputType.emailAddress,
          decoration: const InputDecoration(labelText: 'Email Address', prefixIcon: Icon(Icons.email_outlined, size: 20)),
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            onPressed: _loading ? null : _reset,
            child: _loading
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : const Text('Send Reset Link'),
          ),
        ),
        const SizedBox(height: 16),
        TextButton(onPressed: () => context.go('/'), child: const Text('Back to Sign In')),
      ],
    );
  }

  Widget _buildSuccess() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: AppTheme.success.withAlpha(15),
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Icon(Icons.mark_email_read_outlined, color: AppTheme.success, size: 28),
        ),
        const SizedBox(height: 20),
        const Text('Email Sent!', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppTheme.success)),
        const SizedBox(height: 8),
        Text(
          'Check your inbox at ${_emailCtrl.text} for the password reset link.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(onPressed: () => context.go('/'), child: const Text('Back to Sign In')),
        ),
      ],
    );
  }
}
