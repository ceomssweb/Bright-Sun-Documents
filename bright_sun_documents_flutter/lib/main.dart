import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'services/auth_service.dart';
import 'router/app_router.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const BrightSunDocumentsApp());
}

class BrightSunDocumentsApp extends StatelessWidget {
  const BrightSunDocumentsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AuthService(),
      child: Consumer<AuthService>(
        builder: (context, authService, _) {
          final router = createRouter(authService);
          return MaterialApp.router(
            title: 'Bright Sun Documents',
            theme: AppTheme.theme,
            routerConfig: router,
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }
}
