import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../../widgets/header_widget.dart';
import '../../widgets/footer_widget.dart';
import '../sign_in/sign_in_widget.dart';
import '../sign_up/sign_up_widget.dart';

class HomePageScreen extends StatefulWidget {
  const HomePageScreen({super.key});

  @override
  State<HomePageScreen> createState() => _HomePageScreenState();
}

class _HomePageScreenState extends State<HomePageScreen> {
  bool _showSignIn = true;

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthService>();
    return Scaffold(
      appBar: HeaderWidget(authService: auth),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Text('Welcome to Bright Sun Documents',
                      style: Theme.of(context).textTheme.headlineMedium),
                  const SizedBox(height: 24),
                  Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 400),
                      child: Card(
                        elevation: 2,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (_showSignIn) ...[
                              const SignInWidget(),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Text("Don't have an account? "),
                                  TextButton(
                                    onPressed: () =>
                                        setState(() => _showSignIn = false),
                                    child: const Text('Sign Up'),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                            ] else ...[
                              const SignUpWidget(),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Text('Already have an account? '),
                                  TextButton(
                                    onPressed: () =>
                                        setState(() => _showSignIn = true),
                                    child: const Text('Log In'),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const FooterWidget(),
        ],
      ),
    );
  }
}
