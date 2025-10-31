import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class StorageService {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  // Keys para las cookies
  static const String _aspNetCoreIdentityKey =
      '.AspNetCore.Identity.Application';
  static const String _identityTwoFactorRememberMeKey =
      'Identity.TwoFactorRememberMe';

  Future<void> saveAuthCookies({
    String? aspNetCoreIdentity,
    String? identityTwoFactorRememberMe,
  }) async {
    if (aspNetCoreIdentity != null) {
      await _storage.write(
          key: _aspNetCoreIdentityKey, value: aspNetCoreIdentity);
    }
    if (identityTwoFactorRememberMe != null) {
      await _storage.write(
          key: _identityTwoFactorRememberMeKey,
          value: identityTwoFactorRememberMe);
    }
  }

  Future<Map<String, String>> getAuthCookies() async {
    final aspNetCoreIdentity = await _storage.read(key: _aspNetCoreIdentityKey);
    final identityTwoFactorRememberMe =
        await _storage.read(key: _identityTwoFactorRememberMeKey);

    return {
      if (aspNetCoreIdentity != null)
        _aspNetCoreIdentityKey: aspNetCoreIdentity,
      if (identityTwoFactorRememberMe != null)
        _identityTwoFactorRememberMeKey: identityTwoFactorRememberMe,
    };
  }

  Future<void> clearAuthCookies() async {
    await _storage.delete(key: _aspNetCoreIdentityKey);
    await _storage.delete(key: _identityTwoFactorRememberMeKey);
  }
}
