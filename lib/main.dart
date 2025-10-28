import 'dart:io';

import 'package:driverlink_approval/api/auth/auth_service.dart';
import 'package:driverlink_approval/config/theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:driverlink_approval/config/router.dart';
import 'package:driverlink_approval/providers/requests_provider.dart';
import 'package:driverlink_approval/services/fcm_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Check the auth status before running the app
  await AuthService().checkAuthStatus();

  if (Platform.isAndroid || Platform.isIOS) {
    FCMService().initialize();
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ProviderWrapper(
      child: MaterialApp.router(
        title: 'DriverLink Approval Panel',
        theme: AppTheme.lightTheme,
        routerConfig: router,
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

// Provider wrapper para inicializar providers
class ProviderWrapper extends StatelessWidget {
  final Widget child;

  const ProviderWrapper({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => RequestsProvider()),
      ],
      child: child,
    );
  }
}
