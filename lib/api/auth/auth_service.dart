import 'dart:developer';

import 'package:dio/dio.dart';
import '../../services/secure_storage_service.dart';
import '../api_client.dart';

/// Service for handling authentication related API calls
class AuthService {
  final Dio _dio;

  AuthService({Dio? dio}) : _dio = dio ?? ApiClient.dio;

  /// Get the current authentication token
  Future<String?> getCurrentToken() async {
    return await SecureStorageService.getToken();
  }

  /// Check if there's a valid token in secure storage
  Future<bool> hasValidToken() async {
    try {
      final token = await getCurrentToken();
      if (token == null) return false;

      // Try to get user info to validate the token
      await getCurrentUserInfo(token);
      return true;
    } on DioException catch (e) {
      // If token is invalid (401 Unauthorized), remove it from storage
      if (e.response?.statusCode == 401) {
        await SecureStorageService.deleteToken();
      }
      return false;
    } catch (e) {
      // For any other error, assume token is invalid
      log('Error validating token', error: e);
      return false;
    }
  }

  /// Login user with email and password
  /// Returns the access token on success and saves it to secure storage
  Future<String> login({
    required String email,
    required String password,
  }) async {
    try {
      // Use the default dio instance which will automatically handle the token
      final response = await _dio.post(
        '/auth/login',
        data: {'email': email, 'password': password},
      );

      if (response.statusCode == 200) {
        final token = response.data['access_token'];
        if (token == null || token.isEmpty) {
          throw Exception('No se recibió un token de acceso válido');
        }

        // Save token to secure storage
        await SecureStorageService.saveToken(token);
        return token;
      } else if (response.statusCode == 422) {
        throw InvalidCredentialsException(
          'Por favor, verifica tu correo electrónico y contraseña',
        );
      } else if (response.statusCode == 403) {
        throw AccountPendingException(
          'Su correo electrónico está pendiente a verificación. Active su cuenta usando el enlace enviado a su correo electrónico.',
        );
      } else {
        throw Exception(
          'Error al intentar iniciar sesión. Por favor, inténtalo de nuevo.',
        );
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw InvalidCredentialsException(
          'Correo electrónico o contraseña incorrectos',
        );
      } else if (e.response?.statusCode == 422) {
        throw InvalidCredentialsException(
          'Por favor, verifica tu correo electrónico y contraseña',
        );
      } else if (e.response?.statusCode == 403) {
        throw AccountPendingException(
          'Su correo electrónico está pendiente a verificación. Active su cuenta usando el enlace enviado a su correo electrónico.',
        );
      } else if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw NetworkException(
          'Tiempo de espera agotado. Por favor, verifica tu conexión a internet',
        );
      } else if (e.type == DioExceptionType.connectionError) {
        throw NetworkException(
          'No se pudo conectar al servidor. Por favor, verifica tu conexión',
        );
      } else {
        throw Exception('Error de conexión: ${e.message}');
      }
    } catch (e) {
      throw Exception('Error inesperado: $e');
    }
  }

  /// Logout the current user by removing the token
  Future<void> logout() async {
    await SecureStorageService.deleteToken();
  }

  /// Register a new user
  Future<Map<String, dynamic>> registerUser({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dio.post(
        '/auth/register',
        data: {
          'email': email,
          'user_type': 'driver',
          'password': password,
          'fcm_token': 'placeholder', // await FCMService().getFCMToken(),
        },
      );

      if (response.statusCode == 200) {
        return response.data;
      } else if (response.statusCode == 422) {
        throw Exception('Invalid registration data');
      } else {
        throw Exception('Failed to register user');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 400) {
        throw ExistingEmailException('Email already in use');
      }
      throw Exception('Connection error: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  /// Get current user information
  Future<Map<String, dynamic>> getCurrentUserInfo(String token) async {
    try {
      final dio = ApiClient.createDio(token: token);
      final response = await dio.get('/auth/me');

      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception('Failed to get user info');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw Exception('Session expired. Please login again');
      }
      throw Exception('Connection error: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  Future<Map<String, dynamic>> updateFCMToken(String token) async {
    try {
      final dio = ApiClient.createDio(token: token);
      final response = await dio.put('/fcm/token', data: {'fcm_token': token});

      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception('Failed to update FCM token');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw Exception('Session expired. Please login again');
      }
      throw Exception('Connection error: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }
}

class InvalidCredentialsException implements Exception {
  final String message;
  InvalidCredentialsException(this.message);
  @override
  String toString() => message;
}

class NetworkException implements Exception {
  final String message;
  NetworkException(this.message);
  @override
  String toString() => message;
}

class ExistingEmailException implements Exception {
  final String message;
  ExistingEmailException(this.message);
  @override
  String toString() => message;
}

class AccountPendingException implements Exception {
  final String message;
  AccountPendingException(this.message);
  @override
  String toString() => message;
}
