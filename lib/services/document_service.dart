import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:driverlink_approval/api/api_client.dart';

class DocumentService {
  static final Dio _dio = ApiClient.dio;

  /// Obtener archivo de licencia como bytes
  static Future<Uint8List> getLicenseDocument(int requestId) async {
    try {
      final response = await _dio.get(
        '/admin/requests/$requestId/license-document',
        options: Options(responseType: ResponseType.bytes),
      );
      return Uint8List.fromList(response.data);
    } catch (e) {
      rethrow;
    }
  }

  /// Obtener archivo de identidad como bytes
  static Future<Uint8List> getIdDocument(int requestId) async {
    try {
      final response = await _dio.get(
        '/admin/requests/$requestId/id-document',
        options: Options(responseType: ResponseType.bytes),
      );
      return Uint8List.fromList(response.data);
    } catch (e) {
      rethrow;
    }
  }

  /// Obtener información del archivo (tipo MIME, tamaño, etc.)
  static Future<Map<String, dynamic>> getDocumentInfo(
      int requestId, String documentType) async {
    try {
      final response = await _dio.get(
        '/admin/requests/$requestId/${documentType}-document',
        options: Options(responseType: ResponseType.bytes),
      );
      return {
        'contentType': response.headers.value('content-type'),
        'contentLength': response.headers.value('content-length'),
        'lastModified': response.headers.value('last-modified'),
      };
    } catch (e) {
      rethrow;
    }
  }
}
