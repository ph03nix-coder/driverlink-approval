import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, TargetPlatform;
import 'dart:convert';

class NotificationService {
  NotificationService._internal();
  static final NotificationService instance = NotificationService._internal();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  // Channel aligned with the provided guide
  static const AndroidNotificationChannel _defaultChannel =
      AndroidNotificationChannel(
        'amacubastatistics_default',
        'AmaCuba Statistics Notifications',
        description: 'General notifications for AmaCuba Statistics',
        importance: Importance.high,
      );

  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    if (defaultTargetPlatform != TargetPlatform.android) {
      // Only Android is supported; no-op for other platforms
      _initialized = true; // Mark as initialized to avoid repeated calls
      return;
    }

    const AndroidInitializationSettings androidInit =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initSettings = InitializationSettings(
      android: androidInit,
    );

    // Configure notification tap callback
    await _plugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Android channel creation
    await _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(_defaultChannel);

    _initialized = true;
  }

  // Handle notification tap when app is opened from notification
  Future<void> _onNotificationTapped(NotificationResponse response) async {
    final payload = response.payload;

    if (payload != null && payload.isNotEmpty) {
      try {
        final notificationData = json.decode(payload);
        await _handleNotificationNavigation(notificationData);
      } catch (e) {
        print('Error processing notification payload: $e');
      }
    }
  }

  // Navigate to specific screen based on notification data
  Future<void> _handleNotificationNavigation(Map<String, dynamic> data) async {
    final String? screen = data['screen'];
    final Map<String, dynamic>? params = data['params'];

    if (screen == null) return;

    // For now, we'll handle navigation after the app is fully loaded
    // This will be processed by the main app when it receives the notification data
    print('Notification tapped - Screen: $screen, Params: $params');
  }

  Future<void> showSimple({
    required String title,
    required String body,
    String? payload,
  }) async {
    if (defaultTargetPlatform != TargetPlatform.android) {
      // Only show on Android as requested
      return;
    }
    if (!_initialized) {
      await init();
    }

    const AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
          'amacubastatistics_default',
          'AmaCuba Statistics Notifications',
          channelDescription: 'General notifications for AmaCuba Statistics',
          importance: Importance.max,
          priority: Priority.high,
          ticker: 'ticker',
        );
    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
    );
    await _plugin.show(
      DateTime.now().millisecondsSinceEpoch.remainder(1 << 31),
      title,
      body,
      notificationDetails,
      payload: payload,
    );
  }

  // New method to show notification with structured data for navigation
  Future<void> showNotificationWithNavigation({
    required String title,
    required String body,
    required String screen,
    Map<String, dynamic>? params,
  }) async {
    if (defaultTargetPlatform != TargetPlatform.android) {
      return;
    }
    if (!_initialized) {
      await init();
    }

    final notificationData = {
      'screen': screen,
      'params': params ?? {},
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    };

    const AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
          'amacubastatistics_default',
          'AmaCuba Statistics Notifications',
          channelDescription: 'General notifications for AmaCuba Statistics',
          importance: Importance.max,
          priority: Priority.high,
          ticker: 'ticker',
        );
    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
    );

    await _plugin.show(
      DateTime.now().millisecondsSinceEpoch.remainder(1 << 31),
      title,
      body,
      notificationDetails,
      payload: json.encode(notificationData),
    );
  }
}
