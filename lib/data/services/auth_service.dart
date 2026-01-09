import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../core/errors/api_error.dart';
import '../models/auth/login_request.dart';
import '../models/auth/login_response.dart';
import '../models/auth/register_request.dart';
import '../models/auth/register_response.dart';
import 'storage_service.dart';

class AuthService {
  final Dio _dio;
  final StorageService _storageService;

  AuthService(this._dio) : _storageService = StorageService();

  // Método principal de login - Paso 1: enviar credenciales
  Future<LoginResponse> loginStep1(String username, String password) async {
    try {
      // Obtener cookies almacenadas
      final storedCookies = await _storageService.getAuthCookies();
      final options = Options(headers: {});

      // Si hay cookies almacenadas, incluirlas en el header
      if (storedCookies.isNotEmpty) {
        final cookieHeader =
            storedCookies.entries.map((e) => '${e.key}=${e.value}').join('; ');
        options.headers?['Cookie'] = cookieHeader;
      }

      final response = await _dio.post(
        '/api/Mobile/Login',
        data: LoginRequest(
          username: username,
          password: password,
        ).toJson(),
        options: options,
      );

      // Procesar las cookies de la respuesta
      final setCookieHeaders = response.headers['set-cookie'];
      if (setCookieHeaders != null) {
        final cookies = <String, String>{};

        for (var header in setCookieHeaders) {
          if (header.contains('.AspNetCore.Identity.Application=')) {
            final value = header.split(';')[0];
            cookies['.AspNetCore.Identity.Application'] = value.split('=')[1];
          } else if (header.contains('Identity.TwoFactorRememberMe=')) {
            final value = header.split(';')[0];
            cookies['Identity.TwoFactorRememberMe'] = value.split('=')[1];
          }
        }

        // Guardar las cookies
        if (cookies.isNotEmpty) {
          await _storageService.saveAuthCookies(
            aspNetCoreIdentity: cookies['.AspNetCore.Identity.Application'],
            identityTwoFactorRememberMe:
                cookies['Identity.TwoFactorRememberMe'],
          );
        }
      }

      // Imprimir la respuesta para depuración
      debugPrint('API Response loginStep1: ${response.data}');

      // Extraer el Identity.TwoFactorUserId del Set-Cookie
      // Usar la lista de cookies ya obtenida en lugar de .value() que falla con múltiples cookies
      String? twoFactorUserId;
      if (setCookieHeaders != null && setCookieHeaders.isNotEmpty) {
        // Buscar el TwoFactorUserId en todas las cookies
        for (var cookieHeader in setCookieHeaders) {
          debugPrint('Set-Cookie header: $cookieHeader');
          final regex = RegExp(r'Identity\.TwoFactorUserId=([^;]+)');
          final match = regex.firstMatch(cookieHeader);
          if (match != null && match.groupCount >= 1) {
            twoFactorUserId = match.group(1);
            debugPrint('Extracted TwoFactorUserId: $twoFactorUserId');
            break; // Salir del loop una vez encontrado
          }
        }
      }

      // La API puede devolver:
      // 1. requiresTwoFactor: true (requiere código 2FA)
      // 2. token directamente (login exitoso sin 2FA)
      try {
        final loginResponse = LoginResponse.fromJson(response.data);

        // Si has agregado el campo twoFactorUserId a LoginResponse, asígnalo aquí
        if (loginResponse.requiresTwoFactor && twoFactorUserId != null) {
          // Asumiendo que hay un setter o que el campo es mutable
          loginResponse.twoFactorUserId = twoFactorUserId;
        }

        return loginResponse;
      } catch (parseError) {
        debugPrint('Error al parsear la respuesta: $parseError');
        // Intentar identificar qué campo está causando el problema
        final Map<String, dynamic> data = response.data;
        debugPrint('Campos en la respuesta: ${data.keys.join(', ')}');

        // Relanzar el error con más información
        throw ApiError(message: 'Error al procesar la respuesta: $parseError');
      }
    } on DioException catch (e) {
      debugPrint('Error en loginStep1: ${e.toString()}');
      throw ApiError.fromDioError(e);
    } catch (e) {
      debugPrint('Error en loginStep1: ${e.toString()}');
      throw ApiError(message: 'Error en loginStep1: ${e.toString()}');
    }
  }

  // Paso 2: enviar código 2FA junto con las credenciales
  Future<LoginResponse> loginStep2(
    String username,
    String password,
    String twoFactorCode,
    String twoFactorUserId,
  ) async {
    try {
      final response = await _dio.post(
        '/api/Mobile/Login',
        data: LoginRequest(
          username: username,
          password: password,
          twoFactorCode: twoFactorCode,
          trustedDevice: true, // Para recordar el dispositivo
        ).toJson(),
        options: Options(
          headers: {
            'Cookie': 'Identity.TwoFactorUserId=$twoFactorUserId',
          },
        ),
      );

      // Procesar las cookies de la respuesta
      final setCookieHeaders = response.headers['set-cookie'];
      if (setCookieHeaders != null) {
        final cookies = <String, String>{};

        for (var header in setCookieHeaders) {
          if (header.contains('.AspNetCore.Identity.Application=')) {
            final value = header.split(';')[0];
            cookies['.AspNetCore.Identity.Application'] = value.split('=')[1];
          } else if (header.contains('Identity.TwoFactorRememberMe=')) {
            final value = header.split(';')[0];
            cookies['Identity.TwoFactorRememberMe'] = value.split('=')[1];
          }
        }

        // Guardar las cookies
        if (cookies.isNotEmpty) {
          await _storageService.saveAuthCookies(
            aspNetCoreIdentity: cookies['.AspNetCore.Identity.Application'],
            identityTwoFactorRememberMe:
                cookies['Identity.TwoFactorRememberMe'],
          );
        }
      }

      debugPrint('API Response loginStep2: ${response.data}');

      try {
        return LoginResponse.fromJson(response.data);
      } catch (parseError) {
        debugPrint('Error al parsear la respuesta: $parseError');
        final Map<String, dynamic> data = response.data;
        debugPrint('Campos en la respuesta: ${data.keys.join(', ')}');
        throw ApiError(message: 'Error al procesar la respuesta: $parseError');
      }
    } on DioException catch (e) {
      throw ApiError.fromDioError(e);
    } catch (e) {
      throw ApiError(message: 'Error en loginStep2: ${e.toString()}');
    }
  }

  Future<RegisterResponse> register(RegisterRequest request) async {
    try {
      final response = await _dio.post(
        '/api/Mobile/Register',
        data: request.toJson(),
      );

      // Si todo salió bien, parsear la respuesta exitosa
      return RegisterResponse.fromJson(response.data);
    } on DioException catch (e) {
      debugPrint('Error en registro: $e');

      // Si hay respuesta del servidor, intentar parsear como RegisterResponse
      if (e.response != null && e.response!.data != null) {
        try {
          return RegisterResponse.fromJson(e.response!.data);
        } catch (parseError) {
          debugPrint('Error al parsear respuesta de error: $parseError');
        }
      }

      throw ApiError.fromDioError(e);
    } catch (e) {
      debugPrint('Error inesperado en registro: $e');
      throw ApiError(message: 'Error inesperado: $e');
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
    String verificationType = 'None',
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
      );

      // Devolver la respuesta completa de la API
      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      } else {
        throw ApiError(
          message: '${response.statusCode}',
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

  // Método para limpiar las cookies de autenticación
  Future<void> clearAuthCookies() async {
    try {
      await _storageService.clearAuthCookies();
      debugPrint('Cookies de autenticación limpiadas correctamente');
    } catch (e) {
      debugPrint('Error al limpiar cookies: $e');
    }
  }
}
