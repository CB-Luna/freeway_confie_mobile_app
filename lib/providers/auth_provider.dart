import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:freeway_app/data/models/auth/login_response.dart';
import 'package:freeway_app/data/models/auth/register_request.dart';
import 'package:freeway_app/utils/app_localizations_extension.dart';

import '../core/errors/api_error.dart';
import '../data/constants.dart';
import '../data/services/auth_service.dart';
import '../models/user_model.dart';

/// Provider para manejar la autenticación del usuario
class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService(
    Dio(
      BaseOptions(
        baseUrl: envLogin,
        headers: {
          'X-API-KEY': apiKeyLogin,
          'Content-Type': 'application/json',
        },
      ),
    ),
  );
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  User? _currentUser;
  String? _errorMessage;
  bool _isAuthenticated = false;
  String? _lastUsername; // Almacena temporalmente el último username usado
  String? _lastPassword; // Almacena temporalmente la última contraseña usada
  bool _requiresTwoFactor = false; // Se mantiene para uso futuro
  String? _authToken;

  // Agregar este campo para guardar la respuesta del paso 1
  LoginResponse? _lastLoginResponse;

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

  // Método principal de login - Paso 1: enviar credenciales
  Future<bool> loginStep1(
    String username,
    String password,
    BuildContext context,
  ) async {
    try {
      _errorMessage = null;
      _requiresTwoFactor = false;
      debugPrint('AuthProvider - Iniciando login para usuario: $username');

      // Guardar credenciales temporalmente para uso en el paso 2 si es necesario
      _lastUsername = username;
      _lastPassword = password;

      final response = await _authService.loginStep1(username, password);

      // Guardar la respuesta para usarla en el paso 2
      _lastLoginResponse = response;

      if (response.hasErrors) {
        _errorMessage = response.errorMessage;
        notifyListeners();
        return false;
      }

      // Verificar si la API requiere autenticación de dos factores
      if (response.requiresTwoFactor == true) {
        debugPrint('AuthProvider - Se requiere autenticación de dos factores');
        _requiresTwoFactor = true;
        notifyListeners();
        return true; // Retornar true para indicar que el paso 1 fue exitoso
      }

      // Si no requiere 2FA, completar el login directamente
      if (context.mounted) {
        return await _completeLogin(response, context);
      }
      return false;
    } on ApiError catch (e) {
      debugPrint('ApiError en loginStep1: ${e.message}');
      // Detectar errores de conexión primero
      final errorString = e.message.toLowerCase();
      if (errorString.contains('socketexception') ||
          errorString.contains('failed host lookup') ||
          errorString.contains('connection error') ||
          errorString.contains('network is unreachable') ||
          errorString.contains('no address associated with hostname')) {
        if (context.mounted) {
          _errorMessage = context.translate('auth.noInternetConnection');
        }
      }
      // Mejorar el mensaje de error para credenciales incorrectas
      else if (e.statusCode == 401 ||
          e.message.toLowerCase().contains('no autorizado') ||
          e.message.toLowerCase().contains('unauthorized')) {
        if (context.mounted) {
          _errorMessage = context.translate('auth.incorrectCredentials');
        }
      } else {
        if (context.mounted) {
          _errorMessage =
              context.translateWithArgs('auth.loginError', args: [e.message]);
        }
      }
      notifyListeners();
      return false;
    } catch (e) {
      debugPrint('Error en loginStep1: $e');
      // Detectar errores de conexión
      final errorString = e.toString().toLowerCase();
      if (errorString.contains('socketexception') ||
          errorString.contains('failed host lookup') ||
          errorString.contains('connection error') ||
          errorString.contains('network is unreachable') ||
          errorString.contains('dioexception')) {
        if (context.mounted) {
          _errorMessage = context.translate('auth.noInternetConnection');
        }
      } else {
        if (context.mounted) {
          _errorMessage = context
              .translateWithArgs('auth.loginError', args: [e.toString()]);
        }
      }
      notifyListeners();
      return false;
    }
  }

  // Paso 2: enviar código 2FA junto con las credenciales guardadas
  Future<bool> loginStep2(String twoFactorCode, BuildContext context) async {
    try {
      _errorMessage = null;

      // Verificar que tengamos las credenciales guardadas del paso 1
      if (_lastUsername == null || _lastPassword == null) {
        if (context.mounted) {
          _errorMessage = context.translate('auth.sessionExpired');
        }
        notifyListeners();
        return false;
      }

      // Verificar que tengamos el twoFactorUserId del paso 1
      final LoginResponse? step1Response =
          _lastLoginResponse; // Necesitas guardar la respuesta del paso 1
      if (step1Response?.twoFactorUserId == null) {
        if (context.mounted) {
          _errorMessage = context.translate('auth.sessionExpired');
        }
        notifyListeners();
        return false;
      }

      debugPrint('AuthProvider - Enviando código 2FA');
      final response = await _authService.loginStep2(
        _lastUsername!,
        _lastPassword!,
        twoFactorCode,
        step1Response!.twoFactorUserId!, // Pasar el ID para la cookie
      );

      if (response.hasErrors) {
        if (context.mounted) {
          _errorMessage = context.translateWithArgs(
            'auth.loginError',
            args: [response.errors.map((e) => e.message).join(', ')],
          );
        }
        notifyListeners();
        return false;
      }

      // Completar el login con la respuesta del paso 2
      if (context.mounted) {
        return await _completeLogin(response, context);
      }
      return false;
    } on ApiError catch (e) {
      // Mejorar el mensaje de error para credenciales incorrectas
      if (e.statusCode == 401 ||
          e.message.toLowerCase().contains('no autorizado') ||
          e.message.toLowerCase().contains('unauthorized')) {
        if (context.mounted) {
          _errorMessage = context.translate('auth.incorrectCredentials');
        }
      } else {
        if (context.mounted) {
          _errorMessage =
              context.translateWithArgs('auth.loginError', args: [e.message]);
        }
      }
      notifyListeners();
      return false;
    } catch (e) {
      if (context.mounted) {
        _errorMessage =
            context.translateWithArgs('auth.loginError', args: [e.toString()]);
      }
      notifyListeners();
      return false;
    }
  }

  // Método privado para completar el proceso de login
  Future<bool> _completeLogin(
    LoginResponse response,
    BuildContext context,
  ) async {
    try {
      // Guardar el token de autenticación
      _authToken = response.token;
      await _secureStorage.write(key: _tokenKey, value: _authToken);

      String fullName = 'Freeway User';
      String firstName = 'Freeway';
      String lastName = 'User';
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
        // Manejo de campos que ahora son opcionales
        final primaryPhone = customer.primaryPhone;
        final primaryAddress = customer.primaryAddress;

        fullName = customer.fullName;
        firstName = customer.firstName;
        lastName = customer.lastName;
        email = customer.email;
        phone = primaryPhone != null
            ? _formatPhoneNumber(primaryPhone.phoneNumber)
            : '';
        customerId = customer.customerId ?? '';

        // Manejo de dirección primaria que ahora es opcional
        if (primaryAddress != null) {
          street = primaryAddress.street;
          zipCode = primaryAddress.zip;
          city = primaryAddress.city;
          state = primaryAddress.state;
        } else {
          street = '';
          zipCode = '';
          city = '';
          state = '';
        }

        birthDate = DateTime.parse(customer.birthDate);
        gender = customer.gender ?? '';

        debugPrint(
          'AuthProvider - Usuario obtenido directamente de la respuesta de login',
        );
      } else {
        // Devolver false en caso de que no se pueda obtener la información del usuario y un mensaje de error
        if (context.mounted) {
          _errorMessage = context.translate('auth.failedToRetrieveUser');
        }
        notifyListeners();
        return false;
      }

      // Siempre usar la información más reciente del usuario que inicia sesión
      // Eliminar cualquier información guardada previamente para evitar conflictos
      await saveFullName(fullName);

      // Crear el objeto de usuario con la información obtenida
      _currentUser = User(
        username: _lastUsername ?? 'user',
        // Usar siempre el nombre del usuario actual que viene del servidor
        fullName: fullName,
        firstName: firstName,
        lastName: lastName,
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
      if (context.mounted) {
        _errorMessage =
            context.translateWithArgs('auth.loginError', args: [e.toString()]);
      }
      notifyListeners();
      return false;
    }
  }

  // Método de compatibilidad para el login antiguo
  Future<bool> login(
    String username,
    String password,
    BuildContext context,
  ) async {
    return await loginStep1(username, password, context);
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

  /// Método para cerrar sesión - limpia el estado y el almacenamiento seguro
  Future<void> logout() async {
    // Limpiar variables en memoria
    _currentUser = null;
    _isAuthenticated = false;
    _errorMessage = null;
    _lastUsername = null;
    _lastPassword = null;
    _requiresTwoFactor = false;
    _authToken = null;

    // Limpiar almacenamiento seguro
    await _secureStorage.delete(key: _tokenKey);
    // Eliminar el nombre completo guardado para evitar conflictos con nuevos inicios de sesión
    await _secureStorage.delete(key: _fullNameKey);

    // Opcional: si quieres mantener las credenciales guardadas, comenta estas líneas
    // await _secureStorage.delete(key: _usernameKey);
    // await _secureStorage.delete(key: _passwordKey);

    notifyListeners();
    debugPrint(
      'AuthProvider: estado de autenticación y almacenamiento seguro limpiados',
    );
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
    BuildContext context,
  ) async {
    try {
      _errorMessage = null;
      debugPrint('AuthProvider - Iniciando registro para usuario: $email');

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

      // Verificar si la respuesta contiene errores (ya sea de un 200 OK con errores o de un error HTTP)
      if (response.hasErrors) {
        // Usar el mensaje de error proporcionado por el servidor
        debugPrint(
          'Error de registro desde servidor: ${response.errorMessage}',
        );
        if (context.mounted) {
          // Usar el mensaje de error tal como viene del servidor
          _errorMessage = context.translateWithArgs(
            'auth.signUpError',
            args: [response.errorMessage],
          );
          notifyListeners();
        }
        return false;
      }

      debugPrint('Registro exitoso, intentando login automático');
      // Si el registro fue exitoso, iniciar sesión automáticamente

      bool loginSuccess;
      if (context.mounted) {
        loginSuccess = await login(email, password, context);
      } else {
        loginSuccess = false;
      }

      if (!loginSuccess) {
        debugPrint('Login automático después del registro falló');
        if (context.mounted) {
          _errorMessage = context.translate('auth.signUpSuccessButNoLogin');
          notifyListeners();
        }
      }

      return loginSuccess;
    } on ApiError catch (e) {
      debugPrint('Error de API en registro: ${e.message}');
      // Detectar errores de conexión primero
      final errorString = e.message.toLowerCase();
      if (errorString.contains('socketexception') ||
          errorString.contains('failed host lookup') ||
          errorString.contains('connection error') ||
          errorString.contains('network is unreachable') ||
          errorString.contains('no address associated with hostname')) {
        if (context.mounted) {
          _errorMessage = context.translate('auth.noInternetConnection');
        }
      } else {
        if (context.mounted) {
          _errorMessage =
              context.translateWithArgs('auth.signUpError', args: [e.message]);
        }
      }
      notifyListeners();
      return false;
    } catch (e) {
      debugPrint('Error general en registro: $e');
      // Detectar errores de conexión
      final errorString = e.toString().toLowerCase();
      if (errorString.contains('socketexception') ||
          errorString.contains('failed host lookup') ||
          errorString.contains('connection error') ||
          errorString.contains('network is unreachable') ||
          errorString.contains('dioexception')) {
        if (context.mounted) {
          _errorMessage = context.translate('auth.noInternetConnection');
        }
      } else {
        if (context.mounted) {
          _errorMessage = context
              .translateWithArgs('auth.signUpError', args: [e.toString()]);
        }
      }
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

  /// Actualiza los datos del usuario actual con los nuevos valores proporcionados
  /// Utiliza el método copyWith del modelo User para crear una nueva instancia con los datos actualizados
  /// Retorna true si la actualización fue exitosa, false en caso contrario
  Future<bool> updateUserData({
    String? firstName,
    String? lastName,
    String? email,
    String? phone,
    DateTime? birthDate,
    String? street,
    String? zipCode,
    String? city,
    String? state,
    String? policyNumber,
  }) async {
    try {
      // Verificar si hay un usuario autenticado
      if (!_isAuthenticated || _currentUser == null) {
        debugPrint('No hay usuario autenticado para actualizar datos');
        return false;
      }

      // Crear una copia del usuario con los nuevos datos
      final updatedUser = _currentUser!.copyWith(
        firstName: firstName,
        lastName: lastName,
        email: email,
        phone: phone,
        birthDate: birthDate,
        street: street,
        zipCode: zipCode,
        city: city,
        state: state,
        // Si se proporciona firstName y lastName, actualizar también el fullName
        fullName: (firstName != null && lastName != null)
            ? '$firstName $lastName'
            : null,
      );

      // Actualizar el usuario actual
      _currentUser = updatedUser;

      // Si se actualizó el nombre completo, guardarlo en el almacenamiento seguro
      if (firstName != null && lastName != null) {
        await saveFullName('$firstName $lastName');
      }

      // Notificar a los listeners para que actualicen la UI
      notifyListeners();

      debugPrint('Datos del usuario actualizados correctamente');
      return true;
    } catch (e) {
      debugPrint('Error al actualizar datos del usuario: $e');
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
  Future<bool> loginWithSavedCredentials(BuildContext context) async {
    try {
      final username = await _secureStorage.read(key: _usernameKey);
      final password = await _secureStorage.read(key: _passwordKey);

      if (username == null || password == null) {
        if (context.mounted) {
          _errorMessage = context.translate('auth.noCredentialsSaved');
        }
        return false;
      }

      bool loginSuccess;
      if (context.mounted) {
        loginSuccess = await login(username, password, context);
      } else {
        loginSuccess = false;
      }
      return loginSuccess;
    } catch (e) {
      if (context.mounted) {
        _errorMessage =
            context.translateWithArgs('auth.loginError', args: [e.toString()]);
      }
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
