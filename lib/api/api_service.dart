import 'package:dio/dio.dart';
import 'package:driverlink_approval/models/request.dart';
import 'package:driverlink_approval/api/api_client.dart';

class ApiService {
  static final Dio _dio = ApiClient.dio;

  static Future<String> login(String email, String password) async {
    try {
      final response = await _dio.post('/auth/login', data: {
        'email': email,
        'password': password,
      });
      return response.data['access_token'];
    } catch (e) {
      rethrow;
    }
  }

  static Future<List<Request>> getApprovalRequests() async {
    try {
      final response = await _dio.get('/admin/approval-requests');
      return (response.data as List).map((e) => Request.fromJson(e)).toList();
    } catch (e) {
      rethrow;
    }
  }

  static Future<void> approveRequest(int driverId) async {
    try {
      await _dio.post('/admin/approval-requests/$driverId/approve');
    } catch (e) {
      rethrow;
    }
  }

  static Future<void> rejectRequest(int driverId) async {
    try {
      await _dio.post('/admin/approval-requests/$driverId/reject');
    } catch (e) {
      rethrow;
    }
  }
}
