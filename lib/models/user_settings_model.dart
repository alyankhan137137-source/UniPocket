import 'dart:convert';

/// Represents user-specific application preferences and security settings.
class UserSettings {
  final String currency;
  final String theme; // 'light', 'dark', 'system'
  final String language;
  final double budgetAlertPercentage; // e.g., 80.0 for 80%
  final bool enableNotifications;
  final bool enableBiometric;

  UserSettings({
    required this.currency,
    required this.theme,
    required this.language,
    required this.budgetAlertPercentage,
    required this.enableNotifications,
    required this.enableBiometric,
  });

  /// Default settings for a new user.
  factory UserSettings.defaultSettings() {
    return UserSettings(
      currency: 'USD',
      theme: 'system',
      language: 'en',
      budgetAlertPercentage: 80.0,
      enableNotifications: true,
      enableBiometric: false,
    );
  }

  /// Creates a copy of UserSettings with updated fields.
  UserSettings copyWith({
    String? currency,
    String? theme,
    String? language,
    double? budgetAlertPercentage,
    bool? enableNotifications,
    bool? enableBiometric,
  }) {
    return UserSettings(
      currency: currency ?? this.currency,
      theme: theme ?? this.theme,
      language: language ?? this.language,
      budgetAlertPercentage: budgetAlertPercentage ?? this.budgetAlertPercentage,
      enableNotifications: enableNotifications ?? this.enableNotifications,
      enableBiometric: enableBiometric ?? this.enableBiometric,
    );
  }

  /// Converts Map from SharedPreferences/SQLite to UserSettings object.
  factory UserSettings.fromMap(Map<String, dynamic> map) {
    return UserSettings(
      currency: map['currency'] ?? 'USD',
      theme: map['theme'] ?? 'system',
      language: map['language'] ?? 'en',
      budgetAlertPercentage: (map['budgetAlertPercentage'] as num).toDouble(),
      enableNotifications: map['enableNotifications'] == 1 || map['enableNotifications'] == true,
      enableBiometric: map['enableBiometric'] == 1 || map['enableBiometric'] == true,
    );
  }

  /// Converts UserSettings object to Map for storage.
  Map<String, dynamic> toMap() {
    return {
      'currency': currency,
      'theme': theme,
      'language': language,
      'budgetAlertPercentage': budgetAlertPercentage,
      'enableNotifications': enableNotifications ? 1 : 0,
      'enableBiometric': enableBiometric ? 1 : 0,
    };
  }

  /// JSON serialization
  String toJson() => json.encode(toMap());

  /// JSON deserialization
  factory UserSettings.fromJson(String source) => UserSettings.fromMap(json.decode(source));

  @override
  String toString() {
    return 'UserSettings(currency: $currency, theme: $theme, alert: $budgetAlertPercentage%)';
  }
}
