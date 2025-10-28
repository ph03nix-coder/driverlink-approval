import 'package:driverlink_approval/api/auth/auth_service.dart';
import 'package:driverlink_approval/screens/auth/login_screen.dart';
import 'package:driverlink_approval/screens/requests/requests_screen.dart';
import 'package:go_router/go_router.dart';

final router = GoRouter(
  refreshListenable: AuthService().isAuthenticated,
  routes: [
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/requests',
      builder: (context, state) => const RequestsScreen(),
    ),
    GoRoute(
      path: '/',
      builder: (context, state) => const RequestsScreen(),
    )
  ],
  redirect: (context, state) {
    final isAuthenticated = AuthService().isAuthenticated.value;
    final isLoggingIn = state.matchedLocation == '/login';

    if (!isAuthenticated) {
      return isLoggingIn ? null : '/login';
    }

    if (isLoggingIn) {
      return '/requests';
    }

    return null;
  },
  initialLocation: '/',
);
