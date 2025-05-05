import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:freeway_app/data/models/auth/register_request.dart';
import 'package:freeway_app/data/models/auth/user_info.dart';
import 'package:http/http.dart' as http;

import '../core/errors/api_error.dart';
import '../data/services/auth_service.dart';
import '../models/user_model.dart';

/// Provider para manejar la autenticación del usuario
class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  User? _currentUser;
  String? _errorMessage;
  bool _isAuthenticated = false;
  String? _lastUsername; // Almacena temporalmente el último username usado
  String? _lastPassword; // Almacena temporalmente la última contraseña usada
  bool _requiresTwoFactor = false; // Se mantiene para uso futuro
  String? _authToken;

  // Claves para almacenamiento seguro
  static const String _usernameKey = 'auth_username';
  static const String _passwordKey = 'auth_password';
  static const String _tokenKey = 'auth_token';

  // Getters
  User? get currentUser => _currentUser;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _isAuthenticated;
  bool get requiresTwoFactor =>
      _requiresTwoFactor; // Se mantiene para uso futuro
  String? get authToken => _authToken;

  // Método principal de login (ahora sin 2FA activo)
  Future<bool> loginStep1(String username, String password) async {
    try {
      _errorMessage = null;
      _requiresTwoFactor =
          false; // Siempre será falso mientras el 2FA esté desactivado
      debugPrint('AuthProvider - Iniciando login para usuario: $username');

      // Guardar credenciales temporalmente para uso futuro
      _lastUsername = username;
      _lastPassword = password;

      final response = await _authService.loginStep1(username, password);

      if (response.hasErrors) {
        _errorMessage = response.errorMessage;
        notifyListeners();
        return false;
      }

      // Ya no verificamos requiresTwoFactor porque la API ahora devuelve directamente el token
      return await _completeLogin(response);
    } on ApiError catch (e) {
      // Mejorar el mensaje de error para credenciales incorrectas
      if (e.statusCode == 401 ||
          e.message.toLowerCase().contains('no autorizado') ||
          e.message.toLowerCase().contains('unauthorized')) {
        // Usar la traducción para el mensaje de credenciales incorrectas
        // El contexto no está disponible aquí, así que usamos un mensaje estático
        // que será mostrado en la interfaz de usuario
        _errorMessage = 'auth.incorrectCredentials';
      } else {
        _errorMessage = e.message;
      }
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'Error inesperado: $e';
      notifyListeners();
      return false;
    }
  }

  // Mantenemos este método para uso futuro cuando se reactive el 2FA
  // Actualmente no se utiliza, pero se mantiene la estructura
  Future<bool> loginStep2(String twoFactorCode) async {
    try {
      _errorMessage = null;

      // NOTA: Este método no se usa actualmente ya que el 2FA está desactivado
      // Se mantiene para implementación futura
      final response = await _authService.loginStep2(twoFactorCode);

      if (response.hasErrors) {
        _errorMessage = response.errorMessage;
        notifyListeners();
        return false;
      }

      return await _completeLogin(response);
    } on ApiError catch (e) {
      _errorMessage = e.message;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'Error inesperado: $e';
      notifyListeners();
      return false;
    }
  }

  // Método privado para completar el proceso de login
  Future<bool> _completeLogin(dynamic response) async {
    try {
      // Guardar el token de autenticación
      _authToken = response.token;
      await _secureStorage.write(key: _tokenKey, value: _authToken);

      UserInfo userInfo;
      DateTime? expirationDate;

      try {
        // Intentar obtener la información del usuario desde la API
        final apiResponse = await _fetchUserDataFromAPI();

        if (apiResponse != null) {
          // Si la API devuelve datos válidos, crear un objeto UserInfo con esos datos
          userInfo = UserInfo(
            fullName: "${apiResponse['FirstName']} ${apiResponse['LastName']}",
            policyNumber: apiResponse['PolicyNumber'] ?? '',
            policyType:
                'Auto', // Valor por defecto o se podría extraer de la respuesta
            customerId: apiResponse['PolicyNumber'] ?? '1001',
            email: apiResponse['Email'] ?? _lastUsername ?? 'user@example.com',
            phone: apiResponse['Phone'].toString(),
            avatar: null, // No disponible en la API
            languageCode: 'en_US', // Por defecto o basado en preferencias
            street: apiResponse['Street'] ?? '',
            zipCode: apiResponse['Zip'].toString(),
            city: apiResponse['City'] ?? '',
            state: apiResponse['State'] ?? '',
            carrierName: apiResponse['CarrierName'] ?? '',
            policyUsaState: apiResponse['PolicyUsaState'] ?? '',
          );

          // Parsear la fecha de expiración para usarla como próximo pago
          if (apiResponse['ExpirationDate'] != null) {
            expirationDate =
                _parseDate(apiResponse['ExpirationDate'].toString());
          }

          debugPrint('AuthProvider - Usuario obtenido desde la API');
        } else {
          // Si la API no devuelve datos, usar valores por defecto
          userInfo = UserInfo.defaultInfo(
            email: _lastUsername ?? 'user@example.com',
            customerId: '1001', // ID por defecto
          );
          debugPrint(
            'AuthProvider - API no devolvió datos, usando valores por defecto',
          );
        }
      } catch (e) {
        // En caso de error al llamar a la API, usar valores por defecto
        debugPrint(
          'AuthProvider - Error al obtener datos de usuario desde API: $e',
        );
        userInfo = UserInfo.defaultInfo(
          email: _lastUsername ?? 'user@example.com',
          customerId: '1001', // ID por defecto
        );
      }

      // Crear el objeto de usuario con la información obtenida
      _currentUser = User(
        username: _lastUsername ?? 'user',
        fullName: userInfo.fullName,
        policyNumber: userInfo.policyNumber,
        nextPayment:
            expirationDate ?? DateTime.now().add(const Duration(days: 30)),
        policyType: userInfo.policyType,
        customerId:
            int.parse(userInfo.customerId.replaceAll(RegExp(r'[^0-9]'), '0')),
        email: userInfo.email,
        phone: userInfo.phone,
        avatar: userInfo.avatar,
        languageCode: userInfo.languageCode,
        street: userInfo.street,
        zipCode: userInfo.zipCode,
        city: userInfo.city,
        state: userInfo.state,
        carrierName: userInfo.carrierName,
        policyUsaState: userInfo.policyUsaState,
      );

      _isAuthenticated = true;
      _requiresTwoFactor = false;

      // Si el usuario eligió guardar sus credenciales, las guardamos
      if (_lastUsername != null && _lastPassword != null) {
        await saveCredentials(_lastUsername!, _lastPassword!);
      }

      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Error al completar el login: $e';
      notifyListeners();
      return false;
    }
  }

  /// Método para obtener los datos del usuario desde la API
  Future<Map<String, dynamic>?> _fetchUserDataFromAPI() async {
    try {
      final url = Uri.parse(
        'https://u-n8n.virtalus.cbluna-dev.com/webhook/confie_user_data',
      );

      // Crear el cuerpo de la solicitud con el email del usuario
      final requestBody = json.encode({
        'email': _lastUsername,
      });

      debugPrint('AuthProvider - Llamando a API con email: $_lastUsername');

      // Realizar la solicitud POST
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: requestBody,
      );

      // Verificar si la solicitud fue exitosa (código 200)
      if (response.statusCode == 200) {
        // Decodificar la respuesta JSON
        final dynamic decodedData = json.decode(response.body);
        debugPrint('AuthProvider - Respuesta exitosa de API: ${response.body}');

        // Manejar el caso en que la respuesta sea una lista
        if (decodedData is List && decodedData.isNotEmpty) {
          // Tomar el primer elemento de la lista
          return decodedData.first as Map<String, dynamic>;
        } else if (decodedData is Map<String, dynamic>) {
          // Si ya es un mapa, devolverlo directamente
          return decodedData;
        } else {
          debugPrint(
            'AuthProvider - Formato de respuesta inesperado: ${decodedData.runtimeType}',
          );
          return null;
        }
      } else {
        // Si la solicitud no fue exitosa, registrar el error y devolver null
        debugPrint(
          'AuthProvider - API Error: ${response.statusCode} - ${response.body}',
        );
        return null;
      }
    } catch (e) {
      // En caso de error en la solicitud, registrar el error y devolver null
      debugPrint('AuthProvider - Error al llamar a la API: $e');
      return null;
    }
  }

  /// Método para parsear fechas desde la API
  DateTime? _parseDate(String dateStr) {
    try {
      // Intentar convertir el valor numérico a fecha
      // El formato parece ser un número entero (posiblemente días desde una fecha de referencia)
      final int? days = int.tryParse(dateStr);
      if (days != null) {
        // Asumiendo que es un número de días desde el 30 de diciembre de 1899 (formato Excel/Lotus)
        final DateTime baseDate = DateTime(1899, 12, 30);
        final DateTime resultDate = baseDate.add(Duration(days: days));
        debugPrint(
          'AuthProvider - Fecha parseada: $resultDate desde valor: $dateStr',
        );
        return resultDate;
      }
      return null;
    } catch (e) {
      debugPrint('AuthProvider - Error al parsear fecha: $e');
      return null;
    }
  }

  // Método de compatibilidad para el login antiguo
  Future<bool> login(String username, String password) async {
    return await loginStep1(username, password);
  }

  /// Método simple para cerrar sesión - solo limpia el estado
  void logout() {
    _currentUser = null;
    _isAuthenticated = false;
    _errorMessage = null;
    _lastUsername = null;
    _lastPassword = null;
    _requiresTwoFactor = false;
    _authToken = null;
    notifyListeners();
    debugPrint('AuthProvider: estado de autenticación limpiado');
  }

  /// Método para cerrar sesión y navegar a la pantalla de login
  /// Este método debe ser llamado desde cualquier parte de la aplicación
  /// para cerrar sesión y volver a la pantalla de login
  void performLogout(BuildContext context) {
    try {
      // 1. Limpiar el estado de autenticación
      logout();

      // 2. Navegar a la pantalla de login usando pushNamedAndRemoveUntil
      // Esto asegura que se eliminen todas las pantallas anteriores
      Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);

      debugPrint('Logout completado exitosamente');
    } catch (e) {
      debugPrint('Error durante el logout: $e');

      // Plan de respaldo: intentar navegar directamente a login
      try {
        Navigator.of(context)
            .pushNamedAndRemoveUntil('/login', (route) => false);
      } catch (navError) {
        debugPrint('Error incluso en navegación de respaldo: $navError');

        // Último recurso: intentar navegar a la ruta raíz
        try {
          Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
        } catch (_) {}
      }
    }
  }

  Future<bool> signUp(
    String firstName,
    String lastName,
    String email,
    String password,
    String phoneNumber,
    String policyNumber,
    String birthDate,
  ) async {
    try {
      _errorMessage = null;

      // El número de teléfono ya viene formateado desde la UI

      final request = RegisterRequest(
        firstName: firstName,
        lastName: lastName,
        phoneNumber: phoneNumber,
        email: email,
        password: password,
        birthDate: birthDate,
        policyNumber: policyNumber.isNotEmpty ? policyNumber : null,
      );

      final response = await _authService.register(request);

      if (response.hasErrors) {
        _errorMessage = response.errorMessage;
        notifyListeners();
        return false;
      }

      // Si el registro fue exitoso, iniciar sesión automáticamente
      final loginSuccess = await login(email, password);

      if (!loginSuccess) {
        _errorMessage =
            'Registro exitoso, pero no se pudo iniciar sesión automáticamente. Por favor, inicie sesión manualmente.';
        notifyListeners();
      }

      return loginSuccess;
    } on ApiError catch (e) {
      _errorMessage = e.message;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'Error inesperado durante el registro: $e';
      notifyListeners();
      return false;
    }
  }

  /// Guarda las credenciales del usuario para uso con autenticación biométrica
  Future<bool> saveCredentials(String username, String password) async {
    try {
      await _secureStorage.write(key: _usernameKey, value: username);
      await _secureStorage.write(key: _passwordKey, value: password);
      debugPrint('Credenciales guardadas correctamente');
      return true;
    } catch (e) {
      debugPrint('Error al guardar credenciales: $e');
      return false;
    }
  }

  /// Elimina las credenciales guardadas
  Future<bool> deleteCredentials() async {
    try {
      await _secureStorage.delete(key: _usernameKey);
      await _secureStorage.delete(key: _passwordKey);
      debugPrint('Credenciales eliminadas correctamente');
      return true;
    } catch (e) {
      debugPrint('Error al eliminar credenciales: $e');
      return false;
    }
  }

  /// Inicia sesión usando las credenciales guardadas
  Future<bool> loginWithSavedCredentials() async {
    try {
      final username = await _secureStorage.read(key: _usernameKey);
      final password = await _secureStorage.read(key: _passwordKey);

      if (username == null || password == null) {
        _errorMessage = 'No hay credenciales guardadas';
        return false;
      }

      return await login(username, password);
    } catch (e) {
      _errorMessage = 'Error while retrieving credentials: $e';
      return false;
    }
  }

  /// Guarda las credenciales del usuario actualmente autenticado
  ///
  /// Este método se usa cuando el usuario habilita la autenticación biométrica
  /// desde la configuración del perfil, sin necesidad de cerrar sesión.
  Future<bool> saveCurrentCredentials() async {
    try {
      // Verificar si hay un usuario autenticado
      if (!_isAuthenticated || _currentUser == null) {
        debugPrint('No hay usuario autenticado para guardar credenciales');
        return false;
      }

      // Obtener el nombre de usuario del usuario actual
      final username = _currentUser!.username;

      // Verificar si tenemos la contraseña en memoria
      if (_lastPassword != null) {
        debugPrint('Usando contraseña en memoria para guardar credenciales');
        final result = await saveCredentials(username, _lastPassword!);
        if (result) {
          debugPrint('Credenciales guardadas exitosamente');
        } else {
          debugPrint('Error al guardar las credenciales');
        }
        return result;
      }

      // Si no tenemos la contraseña en memoria, verificar si ya hay una guardada
      final existingPassword = await _secureStorage.read(key: _passwordKey);
      if (existingPassword != null) {
        debugPrint('Usando contraseña existente para guardar credenciales');
        return await saveCredentials(username, existingPassword);
      }

      // Si no tenemos la contraseña de ninguna manera, mostramos un mensaje de depuración
      debugPrint(
        'No se pudo guardar las credenciales: no hay contraseña disponible',
      );

      // En una implementación real, aquí se podría mostrar un diálogo al usuario
      // para pedirle la contraseña nuevamente
      return false;
    } catch (e) {
      debugPrint('Error al guardar las credenciales actuales: $e');
      return false;
    }
  }

  /// Verifica si hay credenciales guardadas
  Future<bool> hasCredentials() async {
    try {
      final username = await _secureStorage.read(key: _usernameKey);
      final password = await _secureStorage.read(key: _passwordKey);
      final hasCredentials = username != null && password != null;
      debugPrint('Verificando credenciales guardadas: $hasCredentials');
      return hasCredentials;
    } catch (e) {
      debugPrint('Error al verificar credenciales: $e');
      return false;
    }
  }
}
