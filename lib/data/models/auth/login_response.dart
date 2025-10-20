import 'package:json_annotation/json_annotation.dart';

import 'customer_model.dart';
import 'error_model.dart';
import 'policy_model.dart';

part 'login_response.g.dart';

@JsonSerializable()
class LoginResponse {
  final String? token;
  final CustomerModel? customer;
  final List<PolicyModel> policies;
  final bool requiresTwoFactor;
  final List<ErrorModel> errors;

  // Añade este nuevo campo
  // Usamos @JsonKey(includeFromJson: false) porque este campo no viene en el JSON de la respuesta
  @JsonKey(includeFromJson: false)
  String? twoFactorUserId;

  LoginResponse({
    this.token,
    this.customer,
    this.policies = const [],
    this.requiresTwoFactor = false,
    this.errors = const [],
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    List<ErrorModel> errorsList = [];
    if (json['errors'] != null) {
      if (json['errors'] is List) {
        errorsList = (json['errors'] as List)
            .map((e) => ErrorModel.fromJson(e as Map<String, dynamic>))
            .toList();
      }
    }

    List<PolicyModel> policiesList = [];
    if (json['policies'] != null) {
      if (json['policies'] is List) {
        policiesList = (json['policies'] as List)
            .map((e) => PolicyModel.fromJson(e as Map<String, dynamic>))
            .toList();
      }
    }

    return LoginResponse(
      token: json['token'],
      customer: json['customer'] != null
          ? CustomerModel.fromJson(json['customer'] as Map<String, dynamic>)
          : null,
      policies: policiesList,
      requiresTwoFactor: json['requiresTwoFactor'] ?? false,
      errors: errorsList,
    );
  }

  bool get hasErrors => errors.isNotEmpty;

  String get errorMessage {
    if (!hasErrors) return '';
    return errors.map((e) => '${e.field}: ${e.message}').join(', ');
  }

  Map<String, dynamic> toJson() => _$LoginResponseToJson(this);
}
