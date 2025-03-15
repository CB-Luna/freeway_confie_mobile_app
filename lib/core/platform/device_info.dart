import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';

class DeviceInfo {
  static final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();

  /// Verifica si el dispositivo es un emulador o simulador
  Future<bool> isEmulatorOrSimulator() async {
    try {
      if (Platform.isAndroid) {
        return _isAndroidEmulator();
      } else if (Platform.isIOS) {
        return _isIOSSimulator();
      }
      return false;
    } catch (e) {
      debugPrint('Error detectando emulador/simulador: $e');
      return false;
    }
  }

  /// Detecta emulador de Android usando propiedades específicas del dispositivo
  Future<bool> _isAndroidEmulator() async {
    final androidInfo = await _deviceInfo.androidInfo;

    // Múltiples comprobaciones para mayor precisión
    final bool isEmulator =
        androidInfo.isPhysicalDevice == false || // Propiedad directa
            androidInfo.model.toLowerCase().contains('sdk') ||
            androidInfo.model.toLowerCase().contains('emulator') ||
            androidInfo.model.toLowerCase().contains('android sdk') ||
            androidInfo.fingerprint.startsWith('generic') ||
            androidInfo.fingerprint.startsWith('unknown') ||
            androidInfo.manufacturer.toLowerCase().contains('genymotion') ||
            androidInfo.product.toLowerCase().contains('sdk') ||
            androidInfo.hardware.toLowerCase().contains('goldfish') ||
            androidInfo.hardware.toLowerCase().contains('ranchu');

    debugPrint(
      'Dispositivo Android detectado como ${isEmulator ? "emulador" : "físico"}',
    );
    return isEmulator;
  }

  /// Detecta simulador de iOS usando propiedades específicas del dispositivo
  Future<bool> _isIOSSimulator() async {
    final iosInfo = await _deviceInfo.iosInfo;
    final bool isSimulator = !iosInfo.isPhysicalDevice;

    debugPrint(
      'Dispositivo iOS detectado como ${isSimulator ? "simulador" : "físico"}',
    );
    return isSimulator;
  }
}
