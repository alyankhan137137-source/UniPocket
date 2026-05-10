import 'package:flutter/material.dart';

/// Represents the user's personal profile and application preferences.
/// 
/// This model stores identity information (name, email) as well as
/// display settings (theme, currency, date format) and security settings
/// (biometrics, privacy mode).
class UserProfile {
  /// Unique identifier for the user.
  final String id;
  
  /// User's display name.
  final String name;
  
  /// Optional email address.
  final String? email;
  
  /// Optional phone number.
  final String? phone;
  
  /// Path to the user's avatar image in local storage or remote URL.
  final String? avatarPath;
  
  /// Preferred currency code (e.g., 'USD').
  final String currency;
  
  /// Preferred locale for internationalization (e.g., 'en_US').
  final String locale;
  
  /// Preferred pattern for date formatting.
  final String dateFormat;
  
  /// Selected theme mode (light, dark, or system).
  final ThemeMode themeMode;
  
  /// Whether push notifications are enabled.
  final bool notificationsEnabled;
  
  /// Whether biometric authentication is required for app access.
  final bool biometricEnabled;
  
  /// Whether privacy mode is enabled (e.g., hiding sensitive amounts).
  final bool privacyModeEnabled;
  
  /// Timestamp of when the profile was created.
  final DateTime createdAt;
  
  /// Timestamp of the last profile update.
  final DateTime updatedAt;

  UserProfile({
    required this.id,
    required this.name,
    this.email,
    this.phone,
    this.avatarPath,
    this.currency = 'USD',
    this.locale = 'en_US',
    this.dateFormat = 'dd/MM/yyyy',
    this.themeMode = ThemeMode.system,
    this.notificationsEnabled = true,
    this.biometricEnabled = false,
    this.privacyModeEnabled = false,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Creates a copy of this [UserProfile] with the given fields replaced.
  UserProfile copyWith({
    String? name,
    String? email,
    String? phone,
    String? avatarPath,
    String? currency,
    String? locale,
    String? dateFormat,
    ThemeMode? themeMode,
    bool? notificationsEnabled,
    bool? biometricEnabled,
    bool? privacyModeEnabled,
    DateTime? updatedAt,
  }) {
    return UserProfile(
      id: id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      avatarPath: avatarPath ?? this.avatarPath,
      currency: currency ?? this.currency,
      locale: locale ?? this.locale,
      dateFormat: dateFormat ?? this.dateFormat,
      themeMode: themeMode ?? this.themeMode,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      biometricEnabled: biometricEnabled ?? this.biometricEnabled,
      privacyModeEnabled: privacyModeEnabled ?? this.privacyModeEnabled,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Converts the [UserProfile] instance into a [Map] for storage (e.g., SQLite).
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'avatarPath': avatarPath,
      'currency': currency,
      'locale': locale,
      'dateFormat': dateFormat,
      'themeMode': themeMode.index,
      'notificationsEnabled': notificationsEnabled,
      'biometricEnabled': biometricEnabled,
      'privacyModeEnabled': privacyModeEnabled,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// Creates a [UserProfile] instance from a [Map].
  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      id: map['id'],
      name: map['name'],
      email: map['email'],
      phone: map['phone'],
      avatarPath: map['avatarPath'],
      currency: map['currency'] ?? 'USD',
      locale: map['locale'] ?? 'en_US',
      dateFormat: map['dateFormat'] ?? 'dd/MM/yyyy',
      themeMode: ThemeMode.values[map['themeMode'] ?? 0],
      notificationsEnabled: map['notificationsEnabled'] ?? true,
      biometricEnabled: map['biometricEnabled'] ?? false,
      privacyModeEnabled: map['privacyModeEnabled'] ?? false,
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: DateTime.parse(map['updatedAt']),
    );
  }
}
