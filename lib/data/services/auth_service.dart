import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../core/errors/api_error.dart';
import '../../core/network/api_client.dart';
import '../models/auth/login_request.dart';
import '../models/auth/login_response.dart';
import '../models/auth/register_request.dart';
import '../models/auth/register_response.dart';

class AuthService {
  final Dio _dio;
  static const String _apiKey =
      'jEk40pLbflj4vQ6RyhQmI3JxDAXjUhdWrEjYBgQRAuSs8X6ged161peEtM4mM8sT';

  AuthService() : _dio = ApiClient.createDio();

  // Método principal de login (ahora sin 2FA activo)
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
            'X-API-KEY': _apiKey,
          },
        ),
      );

      // Imprimir la respuesta para depuración
      debugPrint('API Response: ${response.data}');
      
      // Ahora la API devuelve directamente un token en lugar de requerir 2FA
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

  // Mantenemos este método para uso futuro cuando se reactive el 2FA
  // Actualmente no se utiliza, pero se mantiene la estructura
  Future<LoginResponse> loginStep2(String twoFactorCode) async {
    try {
      // NOTA: Este método no se usa actualmente ya que el 2FA está desactivado
      // Se mantiene para implementación futura
      final response = await _dio.post(
        '/api/Mobile/Login',
        data: LoginRequest(
          twoFactorCode: twoFactorCode,
        ).toJson(),
        options: Options(
          headers: {
            'X-API-KEY': _apiKey,
          },
        ),
      );

      return LoginResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw ApiError.fromDioError(e);
    } catch (e) {
      throw ApiError(message: e.toString());
    }
  }

  Future<RegisterResponse> register(RegisterRequest request) async {
    try {
      final response = await _dio.post(
        '/api/Mobile/Register',
        data: request.toJson(),
        options: Options(
          headers: {
            'X-API-KEY': _apiKey,
          },
        ),
      );

      return RegisterResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw ApiError.fromDioError(e);
    } catch (e) {
      throw ApiError(message: e.toString());
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
            'X-API-KEY': _apiKey,
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
            'X-API-KEY': _apiKey,
          },
        ),
      );

      // Devolver la respuesta completa de la API
      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      } else {
        throw ApiError(message: 'Error updating user data: ${response.statusCode}');
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
            'X-API-KEY': _apiKey,
          },
        ),
      );

      // Imprimir la respuesta para depuración
      debugPrint('API Response SendForgotPasswordMessage: ${response.statusCode}');
      
      // Si el código de estado es 200, el mensaje se envió correctamente
      return response.statusCode == 200;
    } on DioException catch (e) {
      debugPrint('Error en sendForgotPasswordMessage: ${e.response?.data}');
      throw ApiError.fromDioError(e);
    } catch (e) {
      debugPrint('Error general en sendForgotPasswordMessage: $e');
      throw ApiError(message: 'Error al enviar código de recuperación: ${e.toString()}');
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
            'X-API-KEY': _apiKey,
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
      throw ApiError(message: 'Error al restablecer contraseña: ${e.toString()}');
    }
  }
}
