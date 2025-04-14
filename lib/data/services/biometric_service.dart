import 'dart:developer';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:local_auth/error_codes.dart' as auth_error;
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BiometricService {
  static final BiometricService _instance = BiometricService._internal();
  factory BiometricService() => _instance;
  BiometricService._internal();

  final LocalAuthentication _localAuth = LocalAuthentication();

  // Clave para almacenar la preferencia de autenticación biométrica
  static const String _biometricEnabledKey = 'biometric_enabled';

  /// Verifica si el dispositivo tiene capacidades biométricas
  Future<bool> isBiometricAvailable() async {
    try {
      // Verifica si el hardware soporta biometría
      final bool canAuthenticateWithBiometrics =
          await _localAuth.canCheckBiometrics;
      // Verifica si el dispositivo puede autenticar con biometría o PIN/patrón
      final bool canAuthenticate =
          canAuthenticateWithBiometrics || await _localAuth.isDeviceSupported();

      return canAuthenticate;
    } on PlatformException catch (e) {
      log('Error al verificar biometría: $e');
      return false;
    }
  }

  /// Obtiene los tipos de biometría disponibles en el dispositivo
  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _localAuth.getAvailableBiometrics();
    } on PlatformException catch (e) {
      log('Error al obtener biometrías disponibles: $e');
      return [];
    }
  }

  /// Autentica al usuario usando biometría
  ///
  /// Si [checkEnabled] es false, no verificará si la biometría está habilitada.
  /// Esto es útil cuando estamos en el proceso de habilitar la biometría.
  Future<bool> authenticate({bool checkEnabled = true}) async {
    try {
      // Verifica si la biometría está habilitada en la app (opcional)
      if (checkEnabled && !await isBiometricEnabled()) {
        return false;
      }

      // Verifica si el dispositivo soporta biometría
      if (!await isBiometricAvailable()) {
        return false;
      }

      String localizedReason;
      if (Platform.isIOS) {
        localizedReason = 'Authenticate to access your account';
      } else {
        localizedReason = 'Scan your fingerlog to access your account';
      }

      return await _localAuth.authenticate(
        localizedReason: localizedReason,
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: false,
        ),
      );
    } on PlatformException catch (e) {
      log('Error de autenticación: $e');
      if (e.code == auth_error.notAvailable) {
        // Biometría no disponible
        return false;
      } else if (e.code == auth_error.notEnrolled) {
        // No hay biometría registrada
        return false;
      } else if (e.code == auth_error.lockedOut ||
          e.code == auth_error.permanentlyLockedOut) {
        // Demasiados intentos fallidos
        return false;
      }
      return false;
    }
  }

  /// Habilita o deshabilita la autenticación biométrica
  Future<bool> setBiometricEnabled(bool enabled) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.setBool(_biometricEnabledKey, enabled);
    } catch (e) {
      log('Error al guardar preferencia biométrica: $e');
      return false;
    }
  }

  /// Verifica si la autenticación biométrica está habilitada
  Future<bool> isBiometricEnabled() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_biometricEnabledKey) ?? false;
    } catch (e) {
      log('Error al obtener preferencia biométrica: $e');
      return false;
    }
  }

  /// Obtiene el nombre de la biometría principal disponible
  Future<String> getBiometricTypeName() async {
    final biometrics = await getAvailableBiometrics();

    if (biometrics.contains(BiometricType.face)) {
      return 'Face ID';
    } else if (biometrics.contains(BiometricType.fingerprint)) {
      return 'Huella digital';
    } else if (biometrics.contains(BiometricType.strong) ||
        biometrics.contains(BiometricType.weak)) {
      return 'Biometría';
    } else {
      return 'Touch ID';
    }
  }
}
