import 'package:driverlink_approval/screens/auth/login_screen.dart';
import 'package:driverlink_approval/screens/requests/requests_screen.dart';
import 'package:go_router/go_router.dart';
import 'package:driverlink_approval/services/secure_storage_service.dart';

final router = GoRouter(
  routes: [
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/requests',
      builder: (context, state) => const RequestsScreen(),
    ),
  ],
  redirect: (context, state) async {
    final token = await SecureStorageService.getToken();
    if (token != null) {
      return '/requests';
    }
    return '/login';
  },
  initialLocation: '/login',
);
