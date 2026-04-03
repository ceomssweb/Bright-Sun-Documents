import 'package:go_router/go_router.dart';
import '../services/auth_service.dart';
import '../screens/home_page/home_page_screen.dart';
import '../screens/document_request/document_request_screen.dart';
import '../screens/forgot_password/forgot_password_screen.dart';
import '../screens/verify_email/verify_email_screen.dart';
import '../screens/translate_document/translate_document_screen.dart';

GoRouter createRouter(AuthService authService) {
  return GoRouter(
    initialLocation: '/home-page',
    redirect: (context, state) {
      final isLoggedIn = authService.isLoggedIn;
      final isAuthRoute = state.matchedLocation == '/home-page' ||
          state.matchedLocation == '/register-user' ||
          state.matchedLocation == '/forgot-password' ||
          state.matchedLocation == '/verify-email-address';

      if (isLoggedIn && isAuthRoute) {
        return '/document-request';
      }
      if (!isLoggedIn && !isAuthRoute) {
        return '/home-page';
      }
      return null;
    },
    routes: [
      GoRoute(
        path: '/home-page',
        builder: (context, state) => const HomePageScreen(),
      ),
      GoRoute(
        path: '/',
        redirect: (context, state) => '/document-request',
      ),
      GoRoute(
        path: '/document-request',
        builder: (context, state) => const DocumentRequestScreen(),
      ),
      GoRoute(
        path: '/translate-document',
        builder: (context, state) => const TranslateDocumentScreen(),
      ),
      GoRoute(
        path: '/forgot-password',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: '/verify-email-address',
        builder: (context, state) => const VerifyEmailScreen(),
      ),
      GoRoute(
        path: '/register-user',
        builder: (context, state) => const HomePageScreen(),
      ),
    ],
  );
}
