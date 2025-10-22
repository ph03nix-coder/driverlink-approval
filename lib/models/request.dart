import 'package:json_annotation/json_annotation.dart';

part 'request.g.dart';

@JsonSerializable()
class Request {
  @JsonKey(name: 'first_name')
  final String firstName;
  @JsonKey(name: 'last_name')
  final String lastName;
  @JsonKey(name: 'phone_number')
  final String phoneNumber;
  @JsonKey(name: 'vehicle_type')
  final String vehicleType;
  @JsonKey(name: 'vehicle_plate')
  final String vehiclePlate;
  @JsonKey(name: 'vehicle_model')
  final String vehicleModel;
  @JsonKey(name: 'vehicle_year')
  final int vehicleYear;
  @JsonKey(name: 'id')
  final int id;
  @JsonKey(name: 'user_id')
  final int userId;
  @JsonKey(name: 'status')
  final String status;
  @JsonKey(name: 'approval_status')
  final String approvalStatus;
  @JsonKey(name: 'current_latitude')
  final double? currentLatitude;
  @JsonKey(name: 'current_longitude')
  final double? currentLongitude;
  @JsonKey(name: 'last_location_update')
  final DateTime? lastLocationUpdate;
  @JsonKey(name: 'license_document')
  final String? licenseDocument;
  @JsonKey(name: 'id_document')
  final String? idDocument;
  @JsonKey(name: 'documents_submitted_at')
  final DateTime? documentsSubmittedAt;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  Request({
    required this.firstName,
    required this.lastName,
    required this.phoneNumber,
    required this.vehicleType,
    required this.vehiclePlate,
    required this.vehicleModel,
    required this.vehicleYear,
    required this.id,
    required this.userId,
    required this.status,
    required this.approvalStatus,
    required this.currentLatitude,
    required this.currentLongitude,
    required this.lastLocationUpdate,
    required this.licenseDocument,
    required this.idDocument,
    required this.documentsSubmittedAt,
    required this.createdAt,
  });

  factory Request.fromJson(Map<String, dynamic> json) =>
      _$RequestFromJson(json);
  Map<String, dynamic> toJson() => _$RequestToJson(this);
}
