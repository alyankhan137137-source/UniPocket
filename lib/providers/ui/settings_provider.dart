import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../models/user_settings_model.dart';
import '../../database/database_helper.dart';

part 'settings_provider.g.dart';

@riverpod
class SettingsNotifier extends _$SettingsNotifier {
  final _dbHelper = DatabaseHelper();

  @override
  Future<UserSettings> build() async {
    return _loadSettings();
  }

  Future<UserSettings> _loadSettings() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(DatabaseHelper.tableSettings, limit: 1);
    
    if (maps.isNotEmpty) {
      return UserSettings.fromMap(maps.first);
    } else {
      final defaultSettings = UserSettings.defaultSettings();
      await db.insert(DatabaseHelper.tableSettings, defaultSettings.toMap());
      return defaultSettings;
    }
  }

  Future<void> updateSettings(UserSettings newSettings) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final db = await _dbHelper.database;
      await db.update(
        DatabaseHelper.tableSettings,
        newSettings.toMap(),
        where: 'id = ?',
        whereArgs: [1],
      );
      return newSettings;
    });
  }

  Future<void> setTheme(String theme) async {
    final currentSettings = state.value;
    if (currentSettings != null) {
      await updateSettings(currentSettings.copyWith(theme: theme));
    }
  }

  Future<void> setCurrency(String currency) async {
    final currentSettings = state.value;
    if (currentSettings != null) {
      await updateSettings(currentSettings.copyWith(currency: currency));
    }
  }
}
