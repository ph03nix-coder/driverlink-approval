import 'package:driverlink_approval/api/api_service.dart';
import 'package:driverlink_approval/config/theme.dart';
import 'package:driverlink_approval/models/request.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:driverlink_approval/config/router.dart';
import 'package:driverlink_approval/providers/requests_provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
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
