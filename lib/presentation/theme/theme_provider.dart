import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/local_storage.dart';
import '../../data/models/app_settings.dart';
import '../../data/repositories/settings_repo_impl.dart';

final settingsRepositoryProvider = Provider((ref) => SettingsRepositoryImpl());

final settingsProvider = StateNotifierProvider<SettingsNotifier, AppSettings>((ref) {
  return SettingsNotifier();
});

final themeModeProvider = Provider<ThemeMode>((ref) {
  final s = ref.watch(settingsProvider);
  switch (s.themeMode) {
    case 'dark':
      return ThemeMode.dark;
    case 'light':
      return ThemeMode.light;
    default:
      return ThemeMode.system;
  }
});

class SettingsNotifier extends StateNotifier<AppSettings> {
  SettingsNotifier() : super(LocalStorage.appSettingsBox.get('default') ?? AppSettings());

  AppSettings _copy({
    int? primaryColorValue,
    String? themeMode,
    bool? notificationEnabled,
    String? userName,
    bool? onboardingComplete,
    bool? useDynamicColor,
  }) {
    return AppSettings(
      id: state.id,
      primaryColorValue: primaryColorValue ?? state.primaryColorValue,
      themeMode: themeMode ?? state.themeMode,
      notificationEnabled: notificationEnabled ?? state.notificationEnabled,
      userName: userName ?? state.userName,
      onboardingComplete: onboardingComplete ?? state.onboardingComplete,
      useDynamicColor: useDynamicColor ?? state.useDynamicColor,
    );
  }

  void _saveAndUpdate(AppSettings updated) {
    LocalStorage.appSettingsBox.put('default', updated);
    state = updated;
  }

  void setThemeMode(String mode) => _saveAndUpdate(_copy(themeMode: mode));

  void setPrimaryColor(int value) => _saveAndUpdate(_copy(primaryColorValue: value));

  void setNotificationEnabled(bool enabled) => _saveAndUpdate(_copy(notificationEnabled: enabled));

  void setUserName(String name) => _saveAndUpdate(_copy(userName: name));

  void setOnboardingComplete(bool value) => _saveAndUpdate(_copy(onboardingComplete: value));

  void setUseDynamicColor(bool value) => _saveAndUpdate(_copy(useDynamicColor: value));
}
