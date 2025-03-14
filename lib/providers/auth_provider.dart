import 'package:flutter/material.dart';

import '../core/errors/api_error.dart';
import '../data/services/auth_service.dart';
import '../models/user_model.dart';

/// Provider para manejar la autenticación del usuario
class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  User? _currentUser;
  String? _errorMessage;
  bool _isAuthenticated = false;

  // Getters
  User? get currentUser => _currentUser;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _isAuthenticated;

  // Método para iniciar sesión
  Future<bool> login(String username, String password) async {
    try {
      _errorMessage = null;
      debugPrint('AuthProvider - Iniciando login para usuario: $username');

      final response = await _authService.login(username, password);
      debugPrint('AuthProvider - Respuesta de login: ${response.message}');
      debugPrint('AuthProvider - Customer ID: ${response.customerId}');
      debugPrint('AuthProvider - Customer Name: ${response.customerName}');

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
        );

        debugPrint('AuthProvider - Usuario creado: ${_currentUser!.fullName}');
        debugPrint(
            'AuthProvider - Customer ID del usuario: ${_currentUser!.customerId}',);

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
}
