import 'package:json_annotation/json_annotation.dart';

part 'login_response.g.dart';

@JsonSerializable()
class LoginResponse {
  final String message;

  @JsonKey(name: 'customer_id')
  final int customerId;

  @JsonKey(name: 'customer_name')
  final String customerName;

  LoginResponse({
    required this.message,
    required this.customerId,
    required this.customerName,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) =>
      _$LoginResponseFromJson(json);

  Map<String, dynamic> toJson() => _$LoginResponseToJson(this);
}
