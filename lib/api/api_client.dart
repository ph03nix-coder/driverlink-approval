import 'package:dio/dio.dart';
import 'package:driverlink_approval/config/constants.dart';
import 'package:driverlink_approval/services/secure_storage_service.dart';

/// Base API client with common configuration
class ApiClient {
  /// Creates a Dio client with optional authentication token
  static Dio createDio({String? token}) {
    final dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // Add authentication interceptor
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Get the token from secure storage if not provided
          final authToken = token ?? await SecureStorageService.getToken();

          // Add the token to the request headers if available
          if (authToken != null && authToken.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $authToken';
          }

          return handler.next(options);
        },
        onError: (error, handler) async {
          // Handle 401 Unauthorized errors (token expired or invalid)
          if (error.response?.statusCode == 401) {
            // Clear the invalid token
            await SecureStorageService.deleteToken();

            // You might want to add logic to redirect to login screen here
            // or refresh the token if you have a refresh token mechanism
          }

          return handler.next(error);
        },
      ),
    );

    return dio;
  }

  /// Default Dio instance that automatically includes the auth token
  static final dio = createDio();
}
