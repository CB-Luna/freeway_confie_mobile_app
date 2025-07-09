import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:freeway_app/data/models/auth/login_response.dart';
import 'package:freeway_app/data/models/auth/register_request.dart';

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
  static const String _fullNameKey = 'auth_fullname';
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
  Future<bool> _completeLogin(LoginResponse response) async {
    try {
      // Guardar el token de autenticación
      _authToken = response.token;
      await _secureStorage.write(key: _tokenKey, value: _authToken);

      String fullName = 'Freeway User';
      String email = _lastUsername ?? 'user@example.com';
      String phone = '+1 (555) 123-4567';
      String customerId = '1001';
      String street = '123 Main St';
      String zipCode = '12345';
      String city = 'City';
      String state = 'State';
      DateTime? birthDate;
      String gender = 'Male';

      // Usar la información del customer que viene directamente en la respuesta
      if (response.customer != null) {
        final customer = response.customer!;
        final primaryPhone = customer.primaryPhone;
        final primaryAddress = customer.primaryAddress;

        fullName = customer.fullName;
        email = customer.email;
        phone = _formatPhoneNumber(primaryPhone.phoneNumber);
        customerId = customer.customerId;
        street = primaryAddress.street;
        zipCode = primaryAddress.zip;
        city = primaryAddress.city;
        state = primaryAddress.state;
        birthDate = DateTime.parse(customer.birthDate);
        gender = customer.gender;

        debugPrint(
          'AuthProvider - Usuario obtenido directamente de la respuesta de login',
        );
      } else {
        // Devolver false en caso de que no se pueda obtener la información del usuario y un mensaje de error
        _errorMessage = 'No se pudo obtener la información del usuario';
        notifyListeners();
        return false;
      }

      // Verificar si hay un nombre y número de póliza guardados en el almacenamiento seguro
      final String? savedFullName = await getFullName();

      // Crear el objeto de usuario con la información obtenida
      _currentUser = User(
        username: _lastUsername ?? 'user',
        // Usar el nombre guardado si existe, de lo contrario usar el del servidor
        fullName: savedFullName ?? fullName,
        customerId: customerId,
        email: email,
        phone: phone,
        avatar: null, // No disponible en la API
        languageCode: response.customer?.documentLanguage == 'Spanish'
            ? 'es_US'
            : 'en_US',
        birthDate: birthDate,
        gender: gender,
        street: street,
        zipCode: zipCode,
        city: city,
        state: state,
        // Guardar la información completa del customer y policies
        customerData: response.customer,
        policies: response.policies,
      );

      _isAuthenticated = true;
      _requiresTwoFactor = false;

      // Si el usuario eligió guardar sus credenciales, las guardamos
      if (_lastUsername != null && _lastPassword != null) {
        await saveCredentials(_lastUsername!, _lastPassword!);
      }

      // Guardar el nombre completo del usuario en el almacenamiento seguro
      if (_currentUser != null && _currentUser!.fullName.isNotEmpty) {
        await saveFullName(_currentUser!.fullName);
      }

      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Error al completar el login: $e';
      notifyListeners();
      return false;
    }
  }

  // Método de compatibilidad para el login antiguo
  Future<bool> login(String username, String password) async {
    return await loginStep1(username, password);
  }

  /// Método para formatear números telefónicos
  /// Elimina el código de país, guiones y otros caracteres no numéricos
  /// y extrae los últimos 10 dígitos
  String _formatPhoneNumber(String phoneNumber) {
    // Si el número está vacío, devolver cadena vacía
    if (phoneNumber.isEmpty) return '';

    // Eliminar todos los caracteres no numéricos (guiones, espacios, paréntesis, etc.)
    String digitsOnly = phoneNumber.replaceAll(RegExp(r'\D'), '');

    // Si el número tiene más de 10 dígitos, tomar solo los últimos 10
    // Esto elimina automáticamente los códigos de país como +1 o +52
    if (digitsOnly.length > 10) {
      digitsOnly = digitsOnly.substring(digitsOnly.length - 10);
    }

    return digitsOnly;
  }

  /// Método simple para cerrar sesión - solo limpia el estado
  Future<void> logout() async {
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

  /// Guarda el nombre completo del usuario en el almacenamiento seguro
  /// y actualiza el objeto User si existe
  Future<bool> saveFullName(String fullName) async {
    try {
      await _secureStorage.write(key: _fullNameKey, value: fullName);
      debugPrint('Nombre completo guardado correctamente');

      // Actualizar el objeto User si existe
      if (_currentUser != null) {
        _currentUser = _currentUser!.copyWith(fullName: fullName);
        // Notificar a los listeners para que actualicen la UI
        notifyListeners();
      }

      return true;
    } catch (e) {
      debugPrint('Error al guardar nombre completo: $e');
      return false;
    }
  }

  /// Lee el nombre completo del usuario desde el almacenamiento seguro
  Future<String?> getFullName() async {
    try {
      final fullName = await _secureStorage.read(key: _fullNameKey);
      return fullName;
    } catch (e) {
      debugPrint('Error al obtener nombre completo: $e');
      return null;
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
