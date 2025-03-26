import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

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
  String? _lastPassword; // Almacena temporalmente la última contraseña usada

  // Claves para almacenamiento seguro
  static const String _usernameKey = 'auth_username';
  static const String _passwordKey = 'auth_password';

  // Getters
  User? get currentUser => _currentUser;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _isAuthenticated;

  // Método para iniciar sesión
  Future<bool> login(String username, String password) async {
    try {
      _errorMessage = null;
      debugPrint('AuthProvider - Iniciando login para usuario: $username');

      // Guardar la contraseña temporalmente para uso futuro
      _lastPassword = password;

      final response = await _authService.login(username, password);
      debugPrint('AuthProvider - Respuesta de login: ${response.message}');
      debugPrint('AuthProvider - Customer ID: ${response.customerId}');
      debugPrint('AuthProvider - Customer Name: ${response.customerName}');
      debugPrint('AuthProvider - Avatar: ${response.avatar}');
      debugPrint('AuthProvider - Language Code: ${response.languageCode}');

      if (response.message == 'Login Successful') {
        _currentUser = User(
          username: username,
          fullName: response.customerName,
          policyNumber: 'POLICY-${response.customerId}',
          nextPayment: DateTime.now().add(const Duration(days: 30)),
          policyType: 'Auto Policy',
          customerId: response.customerId,
          email: '$username@example.com',
          phone: '+1 (555) 123-4567',
          avatar: response.avatar,
          languageCode: response.languageCode,
        );

        debugPrint('AuthProvider - Usuario creado: ${_currentUser!.fullName}');
        debugPrint(
          'AuthProvider - Customer ID del usuario: ${_currentUser!.customerId}',
        );

        _isAuthenticated = true;
        notifyListeners();
        return true;
      } else {
        _errorMessage = response.message;
        notifyListeners();
        return false;
      }
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

  /// Método simple para cerrar sesión - solo limpia el estado
  void logout() {
    _currentUser = null;
    _isAuthenticated = false;
    _errorMessage = null;
    _lastPassword = null; // Limpiar la contraseña temporal
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
    String fullName,
    String email,
    String password,
    String phoneNumber,
    String policyNumber,
    String zipCode,
  ) async {
    try {
      // Aquí iría la lógica real de registro con tu backend
      // Por ahora, simularemos un registro exitoso
      _currentUser = User(
        username: email,
        fullName: fullName,
        policyNumber: policyNumber,
        nextPayment: DateTime.now().add(const Duration(days: 30)),
        policyType: 'Auto Policy',
        customerId: 1, // Añadido un valor predeterminado para el registro
      );
      _isAuthenticated = true;
      notifyListeners();
      return true;
    } catch (e) {
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
      if (!_isAuthenticated || _currentUser == null || _currentUser!.username == null) {
        debugPrint('No hay usuario autenticado para guardar credenciales');
        return false;
      }
      
      // Obtener el nombre de usuario del usuario actual
      final username = _currentUser!.username!;
      
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
      debugPrint('No se pudo guardar las credenciales: no hay contraseña disponible');
      
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
