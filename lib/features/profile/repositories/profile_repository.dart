import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/user_profile.dart';

class ProfileRepository {
  static const String _key = 'user_profile';

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

  Future<void> saveProfile(UserProfile profile) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, json.encode(profile.toMap()));
  }

  Future<void> clearAllData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
