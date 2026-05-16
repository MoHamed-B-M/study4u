import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/local_storage.dart';
import '../../data/models/app_settings.dart';
import '../../data/repositories/settings_repo_impl.dart';
import 'app_theme.dart';

final settingsRepositoryProvider = Provider((ref) => SettingsRepositoryImpl());

final settingsProvider = StateNotifierProvider<SettingsNotifier, AppSettings>((ref) {
  return SettingsNotifier();
});

final themeModeProvider = Provider<ThemeMode>((ref) {
  final settings = ref.watch(settingsProvider);
  switch (settings.themeMode) {
    case 'dark':
      return ThemeMode.dark;
    case 'light':
      return ThemeMode.light;
    default:
      return ThemeMode.system;
  }
});

final themeDataProvider = Provider<ThemeData>((ref) {
  final settings = ref.watch(settingsProvider);
  final isDark = ref.watch(themeModeProvider) == ThemeMode.dark ||
      (ref.watch(themeModeProvider) == ThemeMode.system &&
          WidgetsBinding.instance.platformDispatcher.platformBrightness == Brightness.dark);
  final color = Color(settings.primaryColorValue);
  return isDark ? AppTheme.darkTheme(color) : AppTheme.lightTheme(color);
});

class SettingsNotifier extends StateNotifier<AppSettings> {
  SettingsNotifier() : super(LocalStorage.appSettingsBox.get('default') ?? AppSettings());

  void setThemeMode(String mode) {
    final updated = AppSettings(
      id: state.id,
      primaryColorValue: state.primaryColorValue,
      themeMode: mode,
      notificationEnabled: state.notificationEnabled,
      userName: state.userName,
    );
    LocalStorage.appSettingsBox.put('default', updated);
    state = updated;
  }

  void setPrimaryColor(int value) {
    final updated = AppSettings(
      id: state.id,
      primaryColorValue: value,
      themeMode: state.themeMode,
      notificationEnabled: state.notificationEnabled,
      userName: state.userName,
    );
    LocalStorage.appSettingsBox.put('default', updated);
    state = updated;
  }

  void setNotificationEnabled(bool enabled) {
    final updated = AppSettings(
      id: state.id,
      primaryColorValue: state.primaryColorValue,
      themeMode: state.themeMode,
      notificationEnabled: enabled,
      userName: state.userName,
    );
    LocalStorage.appSettingsBox.put('default', updated);
    state = updated;
  }

  void setUserName(String name) {
    final updated = AppSettings(
      id: state.id,
      primaryColorValue: state.primaryColorValue,
      themeMode: state.themeMode,
      notificationEnabled: state.notificationEnabled,
      userName: name,
    );
    LocalStorage.appSettingsBox.put('default', updated);
    state = updated;
  }
}
