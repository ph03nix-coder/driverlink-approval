// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Request _$RequestFromJson(Map<String, dynamic> json) => Request(
      firstName: json['first_name'] as String,
      lastName: json['last_name'] as String,
      phoneNumber: json['phone_number'] as String,
      vehicleType: json['vehicle_type'] as String,
      vehiclePlate: json['vehicle_plate'] as String,
      vehicleModel: json['vehicle_model'] as String,
      vehicleYear: (json['vehicle_year'] as num).toInt(),
      id: (json['id'] as num).toInt(),
      userId: (json['user_id'] as num).toInt(),
      status: json['status'] as String,
      approvalStatus: json['approval_status'] as String,
      currentLatitude: (json['current_latitude'] as num?)?.toDouble(),
      currentLongitude: (json['current_longitude'] as num?)?.toDouble(),
      lastLocationUpdate: json['last_location_update'] == null
          ? null
          : DateTime.parse(json['last_location_update'] as String),
      licenseDocument: json['license_document'] as String?,
      idDocument: json['id_document'] as String?,
      documentsSubmittedAt: json['documents_submitted_at'] == null
          ? null
          : DateTime.parse(json['documents_submitted_at'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
    );

Map<String, dynamic> _$RequestToJson(Request instance) => <String, dynamic>{
      'first_name': instance.firstName,
      'last_name': instance.lastName,
      'phone_number': instance.phoneNumber,
      'vehicle_type': instance.vehicleType,
      'vehicle_plate': instance.vehiclePlate,
      'vehicle_model': instance.vehicleModel,
      'vehicle_year': instance.vehicleYear,
      'id': instance.id,
      'user_id': instance.userId,
      'status': instance.status,
      'approval_status': instance.approvalStatus,
      'current_latitude': instance.currentLatitude,
      'current_longitude': instance.currentLongitude,
      'last_location_update': instance.lastLocationUpdate?.toIso8601String(),
      'license_document': instance.licenseDocument,
      'id_document': instance.idDocument,
      'documents_submitted_at':
          instance.documentsSubmittedAt?.toIso8601String(),
      'created_at': instance.createdAt.toIso8601String(),
    };
