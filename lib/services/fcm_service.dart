import 'package:driverlink_approval/api/api.dart';
import 'package:driverlink_approval/services/notification_service.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:logger/logger.dart';

class FCMService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  late String _fcmToken;

  void initialize() async {

    final apiClient = AuthService();
    final authToken = await apiClient.getCurrentToken();

    _firebaseMessaging.requestPermission(alert: true, badge: true, sound: true);

    _firebaseMessaging.getToken().then((token) async {
      _fcmToken = token!;

      final apiClient = AuthService();
      final success = await apiClient.updateFCMToken(authToken!, token);
      if (!success) {
        // we need to refresh the token
        _firebaseMessaging.getToken().then((token) async {
          _fcmToken = token!;
          final success = await apiClient.updateFCMToken(authToken, token);
          if (!success) {
            Logger().e('Error suscribiendo a FCM: $token');
          }
        });
      }
    });

    _firebaseMessaging.onTokenRefresh.listen((token) async {
      _fcmToken = token;

      final apiClient = AuthService();
      final success = await apiClient.updateFCMToken(authToken!, token);
      if (!success) {
        // we need to refresh the token
        _firebaseMessaging.getToken().then((token) async {
          _fcmToken = token!;
          final success = await apiClient.updateFCMToken(authToken, token);
          if (!success) {
            Logger().e('Error suscribiendo a FCM: $token');
          }
        });
      }
    });

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      _handleForegroundMessage(message);
    });

    FirebaseMessaging.onBackgroundMessage(backgroundHandler);
  }

  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    try {
      NotificationService.instance.showSimple(
          title: message.notification!.title ?? 'Sin título',
          body: message.notification!.body ?? 'Sin mensaje',
          // payload: message.data,
        );
    } catch (e) {
      Logger().e('Error procesando notificación en primer plano: $e');
    }
  }

  static Future<void> backgroundHandler(RemoteMessage message) async {
    try {
      NotificationService.instance.showSimple(
          title: message.notification!.title ?? 'Sin título',
          body: message.notification!.body ?? 'Sin mensaje',
          // payload: message.data,
        );
    } catch (e) {
      Logger().e('Error procesando notificación en segundo plano: $e');
    }
  }

  String get fcmToken => _fcmToken;
}
