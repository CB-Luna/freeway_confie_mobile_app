import 'package:json_annotation/json_annotation.dart';
import 'error_model.dart';

part 'login_response.g.dart';

@JsonSerializable()
class LoginResponse {
  final String? token;
  // Campo mantenido para compatibilidad con el código existente
  // pero ya no se usa activamente ya que el 2FA está temporalmente desactivado
  @Deprecated('Campo obsoleto, no se utiliza activamente')
  final bool requiresTwoFactor;
  final List<ErrorModel> errors;

  LoginResponse({
    this.token,
    this.requiresTwoFactor = false,
    this.errors = const [],
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    List<ErrorModel> errorsList = [];
    if (json['errors'] != null) {
      if (json['errors'] is List) {
        errorsList = (json['errors'] as List)
            .map((e) => ErrorModel.fromJson(e))
            .toList();
      }
    }

    return LoginResponse(
      token: json['token'],
      // El campo requiresTwoFactor ya no viene en la respuesta de la API
      // siempre será false mientras el 2FA esté desactivado
      requiresTwoFactor: false,
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
