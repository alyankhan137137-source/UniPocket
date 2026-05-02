import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecurityHelper {
  static const _storage = FlutterSecureStorage();
  static const String _pinKey = 'user_pin';
  static const String _biometricEnabledKey = 'biometric_enabled';

  /// Check if biometric hardware is available (not supported on web)
  static Future<bool> canCheckBiometrics() async {
    if (kIsWeb) return false;
    try {
      // local_auth is not supported on web
      return false;
    } catch (_) {
      return false;
    }
  }

  /// Authenticate user using Biometrics (not supported on web)
  static Future<bool> authenticate() async {
    if (kIsWeb) return true; // Skip auth on web
    return false;
  }

  /// Save PIN securely
  static Future<void> savePin(String pin) async {
    await _storage.write(key: _pinKey, value: pin);
  }

  /// Retrieve saved PIN
  static Future<String?> getPin() async {
    return await _storage.read(key: _pinKey);
  }

  /// Check if PIN is set
  static Future<bool> hasPin() async {
    final pin = await getPin();
    return pin != null && pin.isNotEmpty;
  }

  /// Set Biometric Preference
  static Future<void> setBiometricEnabled(bool enabled) async {
    await _storage.write(key: _biometricEnabledKey, value: enabled.toString());
  }

  /// Check if Biometric is enabled by user
  static Future<bool> isBiometricEnabled() async {
    final enabled = await _storage.read(key: _biometricEnabledKey);
    return enabled == 'true';
  }

  /// Clear all security data
  static Future<void> clearSecurityData() async {
    await _storage.delete(key: _pinKey);
    await _storage.delete(key: _biometricEnabledKey);
  }
}
