import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, TargetPlatform;

class NotificationService {
  NotificationService._internal();
  static final NotificationService instance = NotificationService._internal();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  // Channel aligned with the provided guide
  static const AndroidNotificationChannel _defaultChannel =
      AndroidNotificationChannel(
    'driverlink_approval_default',
    'Driverlink Approval Notifications',
    description: 'General notifications for Driverlink Approval',
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

    await _plugin.initialize(initSettings);

    // Android channel creation
    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_defaultChannel);

    _initialized = true;
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
      'driverlink_approval_default',
      'Driverlink Approval Notifications',
      channelDescription: 'General notifications for Driverlink Approval',
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
}
