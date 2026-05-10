import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/user_profile.dart';
import '../repositories/profile_repository.dart';
import 'package:flutter/material.dart';

part 'profile_provider.g.dart';

/// A notifier that manages the state of the user's profile and preferences.
/// 
/// This provider uses [ProfileRepository] to persist and load settings, 
/// ensuring that user choices like theme and currency are maintained 
/// across app sessions.
@riverpod
class ProfileNotifier extends _$ProfileNotifier {
  final _repository = ProfileRepository();

  /// Loads the initial profile state from the repository.
  @override
  Future<UserProfile> build() async {
    return _repository.loadProfile();
  }

  /// Updates the user profile and persists the changes.
  /// 
  /// Sets the state to [AsyncLoading] while the operation is in progress
  /// and updates the local state once successful.
  Future<void> updateProfile(UserProfile updated) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _repository.saveProfile(updated);
      return updated;
    });
  }

  /// Updates the application theme mode and updates the [updatedAt] timestamp.
  Future<void> updateTheme(ThemeMode mode) async {
    final current = state.value;
    if (current != null) {
      await updateProfile(current.copyWith(themeMode: mode, updatedAt: DateTime.now()));
    }
  }

  /// Alias for [updateTheme] to maintain compatibility with different callers.
  Future<void> updateThemeMode(ThemeMode mode) async {
     final current = state.value;
    if (current != null) {
      await updateProfile(current.copyWith(themeMode: mode, updatedAt: DateTime.now()));
    }
  }

  /// Updates the preferred currency for the user's accounts.
  Future<void> updateCurrency(String code) async {
    final current = state.value;
    if (current != null) {
      await updateProfile(current.copyWith(currency: code, updatedAt: DateTime.now()));
    }
  }

  /// Toggles the privacy mode, which controls visibility of sensitive data in the UI.
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
