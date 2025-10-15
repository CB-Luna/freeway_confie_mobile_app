import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:freeway_app/data/constants.dart';
import 'package:http/http.dart' as http;

import '../../core/errors/api_error.dart';
import '../../core/network/api_client.dart';
import '../models/auth/login_request.dart';
import '../models/auth/login_response.dart';
import '../models/auth/register_request.dart';
import '../models/auth/register_response.dart';

class AuthService {
  final Dio _dio;

  AuthService() : _dio = ApiClient.createDio();

  // Método principal de login - Paso 1: enviar credenciales
  Future<LoginResponse> loginStep1(String username, String password) async {
    try {
      final response = await _dio.post(
        '/api/Mobile/Login',
        data: LoginRequest(
          username: username,
          password: password,
        ).toJson(),
        options: Options(
          headers: {
            'X-API-KEY': apiKeyLogin,
          },
        ),
      );

      // Imprimir la respuesta para depuración
      debugPrint('API Response loginStep1: ${response.data}');

      // La API puede devolver:
      // 1. requiresTwoFactor: true (requiere código 2FA)
      // 2. token directamente (login exitoso sin 2FA)
      try {
        return LoginResponse.fromJson(response.data);
      } catch (parseError) {
        debugPrint('Error al parsear la respuesta: $parseError');
        // Intentar identificar qué campo está causando el problema
        final Map<String, dynamic> data = response.data;
        debugPrint('Campos en la respuesta: ${data.keys.join(', ')}');

        // Relanzar el error con más información
        throw ApiError(message: 'Error al procesar la respuesta: $parseError');
      }
    } on DioException catch (e) {
      throw ApiError.fromDioError(e);
    } catch (e) {
      throw ApiError(message: 'Error en loginStep1: ${e.toString()}');
    }
  }

  // Paso 2: enviar código 2FA junto con las credenciales
  Future<LoginResponse> loginStep2(
    String username,
    String password,
    String twoFactorCode,
  ) async {
    try {
      debugPrint('Enviando código 2FA: $twoFactorCode');
      
      final response = await _dio.post(
        '/api/Mobile/Login',
        data: LoginRequest(
          username: username,
          password: password,
          twoFactorCode: twoFactorCode,
        ).toJson(),
        options: Options(
          headers: {
            'X-API-KEY': apiKeyLogin,
          },
        ),
      );

      debugPrint('API Response loginStep2: ${response.data}');
      return LoginResponse.fromJson(response.data);
    } on DioException catch (e) {
      // Manejar específicamente el error 401 para código inválido
      if (e.response?.statusCode == 401) {
        debugPrint('Código 2FA inválido o credenciales incorrectas');
      }
      throw ApiError.fromDioError(e);
    } catch (e) {
      throw ApiError(message: 'Error en loginStep2: ${e.toString()}');
    }
  }

  Future<RegisterResponse> register(RegisterRequest request) async {
    try {
      final url = Uri.parse('$envLogin/api/Mobile/Register');
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'X-API-KEY': apiKeyLogin,
        },
        body: jsonEncode(request.toJson()),
      );

      final responseData = json.decode(utf8.decode(response.bodyBytes));

      // Verificar si hubo un error HTTP
      if (response.statusCode != 200) {
        debugPrint(
          'Error HTTP ${response.statusCode} en registro: ${response.body}',
        );
        // Intentar parsear la respuesta de error como un RegisterResponse
        try {
          return RegisterResponse.fromJson(responseData);
        } catch (parseError) {
          debugPrint('Error al parsear respuesta de error: $parseError');
          throw ApiError(
            statusCode: response.statusCode,
            message: 'Error: ${response.statusCode} ${response.reasonPhrase}',
            responseData: responseData,
          );
        }
      }

      // Si todo salió bien, parsear la respuesta exitosa
      return RegisterResponse.fromJson(responseData);
    } catch (e) {
      debugPrint('Error en registro: $e');
      if (e is http.ClientException) {
        throw ApiError(message: 'Error de conexión: ${e.message}');
      } else if (e is FormatException) {
        throw ApiError(message: 'Error al procesar la respuesta del servidor');
      } else if (e is ApiError) {
        rethrow;
      } else {
        throw ApiError(message: 'Error inesperado: $e');
      }
    }
  }

  // Método para cambiar la contraseña del usuario
  Future<bool> changePassword({
    required String username,
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final response = await _dio.post(
        '/api/Mobile/ChangePassword',
        data: {
          'userName': username,
          'currentPassword': currentPassword,
          'newPassword': newPassword,
        },
        options: Options(
          headers: {
            'X-API-KEY': apiKeyLogin,
          },
        ),
      );

      // Si el código de estado es 200, la contraseña se cambió correctamente
      return response.statusCode == 200;
    } on DioException catch (e) {
      throw ApiError.fromDioError(e);
    } catch (e) {
      throw ApiError(message: e.toString());
    }
  }

  // Método para actualizar los datos del usuario
  Future<Map<String, dynamic>> updateUserData({
    required String username,
    required String firstName,
    required String lastName,
    required String phoneNumber,
    required String birthDate,
    required String policyNumber,
    String verificationType = 'Unknown',
  }) async {
    try {
      final response = await _dio.post(
        '/api/Mobile/User',
        data: {
          'userName': username,
          'firstName': firstName,
          'lastName': lastName,
          'phoneNumber': phoneNumber,
          'birthDate': birthDate,
          'policyNumber': policyNumber,
          'verificationType': verificationType,
        },
        options: Options(
          headers: {
            'X-API-KEY': apiKeyLogin,
          },
        ),
      );

      // Devolver la respuesta completa de la API
      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      } else {
        throw ApiError(
          message: 'Error updating user data: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      throw ApiError.fromDioError(e);
    } catch (e) {
      throw ApiError(message: e.toString());
    }
  }

  // Método para enviar el código de recuperación de contraseña
  Future<bool> sendForgotPasswordMessage({
    required String userName,
    required String verificationType, // "SmsCode" o "EmailCode"
  }) async {
    try {
      final response = await _dio.post(
        '/api/Mobile/SendForgotPasswordMessage',
        data: {
          'userName': userName,
          'verificationType': verificationType,
        },
        options: Options(
          headers: {
            'X-API-KEY': apiKeyLogin,
          },
        ),
      );

      // Imprimir la respuesta para depuración
      debugPrint(
        'API Response SendForgotPasswordMessage: ${response.statusCode}',
      );

      // Si el código de estado es 200, el mensaje se envió correctamente
      return response.statusCode == 200;
    } on DioException catch (e) {
      debugPrint('Error en sendForgotPasswordMessage: ${e.response?.data}');
      throw ApiError.fromDioError(e);
    } catch (e) {
      debugPrint('Error general en sendForgotPasswordMessage: $e');
      throw ApiError(
        message: 'Error al enviar código de recuperación: ${e.toString()}',
      );
    }
  }

  // Método para restablecer la contraseña con el código recibido
  Future<bool> resetPassword({
    required String userName,
    required String code,
    required String newPassword,
  }) async {
    try {
      final response = await _dio.post(
        '/api/Mobile/ResetPassword',
        data: {
          'userName': userName,
          'code': code,
          'newPassword': newPassword,
        },
        options: Options(
          headers: {
            'X-API-KEY': apiKeyLogin,
          },
        ),
      );

      // Imprimir la respuesta para depuración
      debugPrint('API Response ResetPassword: ${response.statusCode}');

      // Si el código de estado es 200, la contraseña se restableció correctamente
      return response.statusCode == 200;
    } on DioException catch (e) {
      debugPrint('Error en resetPassword: ${e.response?.data}');
      throw ApiError.fromDioError(e);
    } catch (e) {
      debugPrint('Error general en resetPassword: $e');
      throw ApiError(
        message: 'Error al restablecer contraseña: ${e.toString()}',
      );
    }
  }
}
