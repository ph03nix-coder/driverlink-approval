import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../services/secure_storage_service.dart';
import '../api_client.dart';

/// Service for handling authentication related API calls
class AuthService {
  // Singleton instance
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final Dio _dio = ApiClient.dio;

  // ValueNotifier to notify listeners about authentication changes
  final ValueNotifier<bool> isAuthenticated = ValueNotifier<bool>(false);

  /// Get the current authentication token
  Future<String?> getCurrentToken() async {
    return await SecureStorageService.getToken();
  }

  /// Check if there's a valid token in secure storage and update the auth state
  Future<void> checkAuthStatus() async {
    try {
      final token = await getCurrentToken();
      if (token == null) {
        isAuthenticated.value = false;
        return;
      }

      // Try to get user info to validate the token
      await getCurrentUserInfo(token);
      isAuthenticated.value = true;
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        await SecureStorageService.deleteToken();
      }
      isAuthenticated.value = false;
    } catch (e) {
      log('Error validating token', error: e);
      isAuthenticated.value = false;
    }
  }

  /// Login user with email and password
  /// Returns the access token on success and saves it to secure storage
  Future<String> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dio.post(
        '/auth/login',
        data: {'email': email, 'password': password},
      );

      if (response.statusCode == 200) {
        final token = response.data['access_token'];
        if (token == null || token.isEmpty) {
          throw Exception('No se recibió un token de acceso válido');
        }

        await SecureStorageService.saveToken(token);
        isAuthenticated.value = true; // Notify listeners
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
        isAuthenticated.value = false;
        throw Exception('Error de conexión: ${e.message}');
      }
    } catch (e) {
      isAuthenticated.value = false;
      throw Exception('Error inesperado: $e');
    }
  }

  /// Logout the current user by removing the token
  Future<void> logout() async {
    await SecureStorageService.deleteToken();
    isAuthenticated.value = false; // Notify listeners
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

  Future<bool> updateFCMToken(String token) async {
    try {
      final dio = ApiClient.createDio(token: token);
      final response = await dio.post('/fcm/token', data: {'fcm_token': token});

      if (response.statusCode == 200) {
        return true;
      } else {
        return false;
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
