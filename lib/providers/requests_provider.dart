import 'package:flutter/material.dart';
import 'package:driverlink_approval/models/request.dart';
import 'package:driverlink_approval/api/api_service.dart';

class RequestsProvider extends ChangeNotifier {
  List<Request> _requests = [];
  bool _isLoading = false;
  String? _error;

  List<Request> get requests => _requests;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Cargar las solicitudes pendientes de aprobación
  Future<void> loadRequests() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _requests = await ApiService.getApprovalRequests();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Aprobar una solicitud
  Future<bool> approveRequest(int requestId) async {
    try {
      await ApiService.approveRequest(requestId);
      // Remover la solicitud aprobada de la lista
      _requests.removeWhere((request) => request.id == requestId);
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Rechazar una solicitud
  Future<bool> rejectRequest(int requestId) async {
    try {
      await ApiService.rejectRequest(requestId);
      // Remover la solicitud rechazada de la lista
      _requests.removeWhere((request) => request.id == requestId);
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Limpiar el error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
