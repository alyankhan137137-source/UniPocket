import 'dart:convert';

/// Represents user-specific application preferences and security settings.
/// 
/// This model persists choices like the primary currency, UI theme, 
/// and security features (notifications and biometrics).
class UserSettings {
  /// The ISO currency code used globally in the app (e.g., 'USD').
  final String currency;
  
  /// The visual theme preference: 'light', 'dark', or 'system'.
  final String theme; 
  
  /// The locale or language code for the UI (e.g., 'en').
  final String language;
  
  /// The percentage threshold (0.0 to 100.0) at which the user 
  /// should be notified about budget limits.
  final double budgetAlertPercentage; 
  
  /// Whether push notifications for budget alerts and summaries are enabled.
  final bool enableNotifications;
  
  /// Whether biometric authentication (Fingerprint/FaceID) is required to open the app.
  final bool enableBiometric;

  /// The monthly allowance amount in cents.
  final int monthlyAllowance;

  UserSettings({
    required this.currency,
    required this.theme,
    required this.language,
    required this.budgetAlertPercentage,
    required this.enableNotifications,
    required this.enableBiometric,
    this.monthlyAllowance = 0,
  });

  /// Provides the standard default configuration for a new user session.
  factory UserSettings.defaultSettings() {
    return UserSettings(
      currency: 'USD',
      theme: 'system',
      language: 'en',
      budgetAlertPercentage: 80.0,
      enableNotifications: true,
      enableBiometric: false,
      monthlyAllowance: 0,
    );
  }

  /// Creates a copy of this [UserSettings] with the given fields replaced.
  UserSettings copyWith({
    String? currency,
    String? theme,
    String? language,
    double? budgetAlertPercentage,
    bool? enableNotifications,
    bool? enableBiometric,
    int? monthlyAllowance,
  }) {
    return UserSettings(
      currency: currency ?? this.currency,
      theme: theme ?? this.theme,
      language: language ?? this.language,
      budgetAlertPercentage: budgetAlertPercentage ?? this.budgetAlertPercentage,
      enableNotifications: enableNotifications ?? this.enableNotifications,
      enableBiometric: enableBiometric ?? this.enableBiometric,
      monthlyAllowance: monthlyAllowance ?? this.monthlyAllowance,
    );
  }

  /// Creates a [UserSettings] instance from a storage map (SharedPreferences/SQLite).
  factory UserSettings.fromMap(Map<String, dynamic> map) {
    return UserSettings(
      currency: map['currency'] ?? 'USD',
      theme: map['theme'] ?? 'system',
      language: map['language'] ?? 'en',
      budgetAlertPercentage: (map['budgetAlertPercentage'] as num).toDouble(),
      enableNotifications: map['enableNotifications'] == 1 || map['enableNotifications'] == true,
      enableBiometric: map['enableBiometric'] == 1 || map['enableBiometric'] == true,
      monthlyAllowance: map['monthlyAllowance'] ?? 0,
    );
  }

  /// Converts the [UserSettings] instance into a map for storage.
  Map<String, dynamic> toMap() {
    return {
      'currency': currency,
      'theme': theme,
      'language': language,
      'budgetAlertPercentage': budgetAlertPercentage,
      'enableNotifications': enableNotifications ? 1 : 0,
      'enableBiometric': enableBiometric ? 1 : 0,
      'monthlyAllowance': monthlyAllowance,
    };
  }

  /// Serializes the [UserSettings] instance to a JSON string.
  String toJson() => json.encode(toMap());

  /// Deserializes a [UserSettings] instance from a JSON string.
  factory UserSettings.fromJson(String source) => UserSettings.fromMap(json.decode(source));

  @override
  String toString() {
    return 'UserSettings(currency: $currency, theme: $theme, alert: $budgetAlertPercentage%, allowance: $monthlyAllowance)';
  }
}
