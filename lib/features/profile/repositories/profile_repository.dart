import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/user_profile.dart';

/// Repository responsible for persisting and retrieving user profile data.
/// 
/// This class uses [SharedPreferences] to store the profile as a JSON string,
/// providing a lightweight way to save user preferences and identity locally.
class ProfileRepository {
  static const String _key = 'user_profile';

  /// Loads the [UserProfile] from local storage.
  /// 
  /// If no profile is found or if parsing fails, it returns a default 
  /// empty profile with a new unique identifier.
  Future<UserProfile> loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_key);

    if (jsonString == null) {
      // ✅ Return empty profile - onboarding will set the real name
      final profile = UserProfile(
        id: const Uuid().v4(),
        name: '',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      return profile;
    }

    try {
      return UserProfile.fromMap(json.decode(jsonString));
    } catch (e) {
      return UserProfile(
        id: const Uuid().v4(),
        name: '',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    }
  }

  /// Persists the given [profile] to local storage as a JSON string.
  Future<void> saveProfile(UserProfile profile) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, json.encode(profile.toMap()));
  }

  /// Deletes the user profile data from local storage.
  Future<void> clearAllData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
