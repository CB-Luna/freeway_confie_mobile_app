import 'package:json_annotation/json_annotation.dart';

part 'policy_model.g.dart';

@JsonSerializable()
class PolicyModel {
  final String policyId;
  final String insuredName;
  final String policyNumber;
  final String effectiveDate;
  final String expirationDate;
  final String createdDate;
  final String lineOfBusiness;
  final String carrierName;
  final String programName;
  String? carrierLogoUrl;
  String? carrierClaimUrl;
  String? carrierClaimPhone;
  final String organizationName;
  final String organizationCode;
  final String? nextPaymentDate;
  final String? policyStatus;

  PolicyModel({
    required this.policyId,
    required this.insuredName,
    required this.policyNumber,
    required this.effectiveDate,
    required this.expirationDate,
    required this.createdDate,
    required this.lineOfBusiness,
    required this.carrierName,
    required this.programName,
    required this.organizationName,
    required this.organizationCode,
    this.carrierLogoUrl,
    this.carrierClaimUrl,
    this.carrierClaimPhone,
    this.nextPaymentDate,
    this.policyStatus,
  });

  factory PolicyModel.fromJson(Map<String, dynamic> json) =>
      _$PolicyModelFromJson(json);

  Map<String, dynamic> toJson() => _$PolicyModelToJson(this);
}
