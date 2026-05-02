import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/user_profile.dart';
import '../repositories/profile_repository.dart';
import 'package:flutter/material.dart';

part 'profile_provider.g.dart';

@riverpod
class ProfileNotifier extends _$ProfileNotifier {
  final _repository = ProfileRepository();

  @override
  Future<UserProfile> build() async {
    return _repository.loadProfile();
  }

  Future<void> updateProfile(UserProfile updated) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _repository.saveProfile(updated);
      return updated;
    });
  }

  Future<void> updateTheme(ThemeMode mode) async {
    final current = state.value;
    if (current != null) {
      await updateProfile(current.copyWith(themeMode: mode, updatedAt: DateTime.now()));
    }
  }

  Future<void> updateThemeMode(ThemeMode mode) async {
     final current = state.value;
    if (current != null) {
      await updateProfile(current.copyWith(themeMode: mode, updatedAt: DateTime.now()));
    }
  }

  Future<void> updateCurrency(String code) async {
    final current = state.value;
    if (current != null) {
      await updateProfile(current.copyWith(currency: code, updatedAt: DateTime.now()));
    }
  }

  Future<void> togglePrivacyMode() async {
    final current = state.value;
    if (current != null) {
      await updateProfile(current.copyWith(
        privacyModeEnabled: !current.privacyModeEnabled,
        updatedAt: DateTime.now(),
      ));
    }
  }
}
