import 'package:flutter/material.dart';

class UserProfile {
  final String id;
  final String name;
  final String? email;
  final String? phone;
  final String? avatarPath;
  final String currency;
  final String locale;
  final String dateFormat;
  final ThemeMode themeMode;
  final bool notificationsEnabled;
  final bool biometricEnabled;
  final bool privacyModeEnabled;
  final DateTime createdAt;
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
