import 'package:flutter/foundation.dart';
import 'package:local_auth/local_auth.dart';

import '../data/services/biometric_service.dart';
import 'auth_provider.dart';

class BiometricProvider extends ChangeNotifier {
  final BiometricService _biometricService = BiometricService();
  // Referencia al AuthProvider para acceder a las credenciales y guardarlas
  AuthProvider? _authProvider;
  
  bool _isAvailable = false;
  bool _isEnabled = false;
  String _biometricType = 'Touch ID';
  bool _isLoading = true;

  bool get isAvailable => _isAvailable;
  bool get isEnabled => _isEnabled;
  String get biometricType => _biometricType;
  bool get isLoading => _isLoading;
  
  // Método para establecer el AuthProvider
  void setAuthProvider(AuthProvider authProvider) {
    _authProvider = authProvider;
  }

  BiometricProvider() {
    _initBiometrics();
  }

  /// Inicializa el estado de la biometría
  Future<void> _initBiometrics() async {
    _isLoading = true;
    notifyListeners();

    // Verifica si el dispositivo soporta biometría
    _isAvailable = await _biometricService.isBiometricAvailable();
    
    if (_isAvailable) {
      // Obtiene el tipo de biometría disponible
      _biometricType = await _biometricService.getBiometricTypeName();
      
      // Verifica si la biometría está habilitada en la app
      _isEnabled = await _biometricService.isBiometricEnabled();
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Habilita o deshabilita la autenticación biométrica
  /// 
  /// Si se está habilitando la biometría, también guarda las credenciales actuales
  /// para que puedan ser usadas en futuras autenticaciones biométricas.
  Future<bool> toggleBiometric(bool enabled) async {
    _isLoading = true;
    notifyListeners();

    // Si estamos habilitando la biometría, verificamos primero que funcione
    if (enabled) {
      // Usamos checkEnabled=false porque estamos en el proceso de habilitación
      final authenticated = await _biometricService.authenticate(checkEnabled: false);
      if (!authenticated) {
        _isLoading = false;
        notifyListeners();
        return false;
      }
      
      // Si la autenticación fue exitosa y estamos habilitando la biometría,
      // guardar las credenciales actuales si el usuario está autenticado
      if (_authProvider != null && _authProvider!.isAuthenticated) {
        // Obtener las credenciales actuales del usuario autenticado
        final currentUser = _authProvider!.currentUser;
        if (currentUser != null && currentUser.username != null) {
          // Guardar las credenciales para uso futuro con biometría
          // Nota: Aquí asumimos que el AuthProvider tiene acceso a la contraseña
          // Si no es así, se podría implementar un método para obtenerla
          final credentialsSaved = await _authProvider!.saveCurrentCredentials();
          if (!credentialsSaved) {
            // Si no se pudieron guardar las credenciales, mostrar un mensaje de error
            debugPrint('No se pudieron guardar las credenciales para biometría');
            // Pero continuamos con la habilitación de la biometría
          }
        }
      }
    } else {
      // Si estamos deshabilitando la biometría, eliminar las credenciales guardadas
      if (_authProvider != null) {
        await _authProvider!.deleteCredentials();
      }
    }

    // Guarda la preferencia
    final success = await _biometricService.setBiometricEnabled(enabled);
    if (success) {
      _isEnabled = enabled;
    }

    _isLoading = false;
    notifyListeners();
    return success;
  }

  /// Autentica al usuario usando biometría
  /// 
  /// Este método se usa para autenticar al usuario cuando la biometría ya está habilitada
  /// y se quiere usar para acceder a la aplicación.
  Future<bool> authenticate() async {
    // No es necesario verificar _isEnabled aquí porque ya lo hacemos en el servicio
    // y podría causar problemas si queremos autenticar durante el proceso de habilitación
    if (!_isAvailable) {
      return false;
    }

    // Llamamos al servicio con checkEnabled=true para que verifique si la biometría está habilitada
    return await _biometricService.authenticate(checkEnabled: true);
  }

  /// Verifica si la biometría está disponible y habilitada
  Future<void> refreshBiometricState() async {
    await _initBiometrics();
  }

  /// Obtiene los tipos de biometría disponibles
  Future<List<BiometricType>> getAvailableBiometrics() async {
    return await _biometricService.getAvailableBiometrics();
  }
}
