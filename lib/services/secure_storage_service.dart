import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  static const _storage = FlutterSecureStorage();
  static const _tokenKey = 'auth_token';
  static const _currentOrderKey = 'current_order';

  /// Save the authentication token to secure storage
  static Future<void> saveToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
  }

  /// Get the stored authentication token
  static Future<String?> getToken() async {
    return await _storage.read(key: _tokenKey);
  }

  /// Delete the stored authentication token
  static Future<void> deleteToken() async {
    await _storage.delete(key: _tokenKey);
  }

  /// Check if there is a valid token
  static Future<bool> hasToken() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  /// Save the current accepted order as a JSON string
  static Future<void> saveCurrentOrderJson(String orderJson) async {
    await _storage.write(key: _currentOrderKey, value: orderJson);
  }

  /// Get the stored current order JSON string
  static Future<String?> getCurrentOrderJson() async {
    return await _storage.read(key: _currentOrderKey);
  }

  /// Delete the stored current order
  static Future<void> deleteCurrentOrder() async {
    await _storage.delete(key: _currentOrderKey);
  }
}
