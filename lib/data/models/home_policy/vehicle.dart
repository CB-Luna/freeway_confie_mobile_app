import 'package:json_annotation/json_annotation.dart';

part 'vehicle.g.dart';

@JsonSerializable()
class Vehicle {
  @JsonKey(name: 'vehicle_id')
  final int vehicleId;
  
  final String plate;
  final String brand;
  final String model;
  
  @JsonKey(name: 'vehicle_type_id')
  final int? vehicleTypeId;
  
  @JsonKey(name: 'vehicle_type')
  final String? vehicleType;
  
  @JsonKey(name: 'provider_id')
  final int providerId;
  
  @JsonKey(name: 'provider_image')
  final String providerImage;
  
  @JsonKey(name: 'policy_type_id')
  final int policyTypeId;
  
  @JsonKey(name: 'policy_type')
  final String policyType;
  
  @JsonKey(name: 'transaction_type')
  final String? transactionType;
  
  @JsonKey(name: 'member_since')
  final String? memberSince;
  
  @JsonKey(name: 'service_id')
  final int? serviceId;
  
  @JsonKey(name: 'name')
  final String? serviceName;
  
  // Mantenemos el campo status para compatibilidad, pero ahora lo determinamos por policy_type_id
  bool get status => policyTypeId != 3; // Si policyTypeId es 3, entonces es inactivo
  
  @JsonKey(name: 'next_payment_date')
  final String nextPaymentDate;
  
  @JsonKey(name: 'customer_id')
  final int customerId;

  Vehicle({
    required this.vehicleId,
    required this.plate,
    required this.brand,
    required this.model,
    required this.providerId, required this.providerImage, required this.policyTypeId, required this.policyType, required this.nextPaymentDate, required this.customerId, this.vehicleTypeId,
    this.vehicleType,
    this.transactionType,
    this.memberSince,
    this.serviceId,
    this.serviceName,
  });

  factory Vehicle.fromJson(Map<String, dynamic> json) => 
      _$VehicleFromJson(json);
  
  Map<String, dynamic> toJson() => _$VehicleToJson(this);
}
