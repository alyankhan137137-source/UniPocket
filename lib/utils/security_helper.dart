import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// A utility class for handling application security, including PIN storage and biometric authentication.
/// 
/// This class uses [FlutterSecureStorage] to store sensitive information like the user's PIN
/// and biometric preferences securely on the device.
class SecurityHelper {
  static const _storage = FlutterSecureStorage();
  static const String _pinKey = 'user_pin';
  static const String _biometricEnabledKey = 'biometric_enabled';

  /// Checks if biometric authentication hardware is available and supported.
  /// 
  /// Note: Currently returns false on Web as biometric features are not yet implemented for the platform.
  static Future<bool> canCheckBiometrics() async {
    if (kIsWeb) return false;
    try {
      // TODO: Implement actual biometric check using local_auth package
      return false;
    } catch (_) {
      return false;
    }
  }

  /// Attempts to authenticate the user using biometric data (Fingerprint/FaceID).
  /// 
  /// Returns true if authentication is successful or bypassed on unsupported platforms.
  static Future<bool> authenticate() async {
    if (kIsWeb) return true; // Bypassed for web demo purposes
    // TODO: Implement actual biometric authentication logic
    return false;
  }

  /// Securely persists the user's [pin] to the device's keychain/keystore.
  static Future<void> savePin(String pin) async {
    await _storage.write(key: _pinKey, value: pin);
  }

  /// Retrieves the saved PIN from secure storage.
  static Future<String?> getPin() async {
    return await _storage.read(key: _pinKey);
  }

  /// Checks if a PIN has been previously set by the user.
  static Future<bool> hasPin() async {
    final pin = await getPin();
    return pin != null && pin.isNotEmpty;
  }

  /// Enables or disables the preference for biometric locking.
  static Future<void> setBiometricEnabled(bool enabled) async {
    await _storage.write(key: _biometricEnabledKey, value: enabled.toString());
  }

  /// Checks if the user has opted into using biometric authentication.
  static Future<bool> isBiometricEnabled() async {
    final enabled = await _storage.read(key: _biometricEnabledKey);
    return enabled == 'true';
  }

  /// Deletes all security-related data (PIN and biometric preferences) from secure storage.
  static Future<void> clearSecurityData() async {
    await _storage.delete(key: _pinKey);
    await _storage.delete(key: _biometricEnabledKey);
  }
}
