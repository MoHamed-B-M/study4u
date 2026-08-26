import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/local_storage.dart';
import '../../data/models/app_settings.dart';
import '../../data/repositories/settings_repo_impl.dart';

final settingsRepositoryProvider = Provider((ref) => SettingsRepositoryImpl());

final settingsProvider =
    StateNotifierProvider<SettingsNotifier, AppSettings>((ref) {
  return SettingsNotifier();
});

final themeModeProvider = Provider<ThemeMode>((ref) {
  final s = ref.watch(settingsProvider.select((s) => s.themeMode));
  switch (s) {
    case 'dark':
      return ThemeMode.dark;
    case 'light':
      return ThemeMode.light;
    default:
      return ThemeMode.system;
  }
});

final primaryColorProvider = Provider<int>((ref) {
  return ref.watch(settingsProvider.select((s) => s.primaryColorValue));
});

class SettingsNotifier extends StateNotifier<AppSettings> {
  SettingsNotifier() : super(_loadSettings());

  static AppSettings _loadSettings() {
    try {
      return LocalStorage.appSettingsBox.get('default') ?? AppSettings();
    } catch (_) {
      return AppSettings();
    }
  }

  AppSettings _copy({
    int? primaryColorValue,
    String? themeMode,
    bool? notificationEnabled,
    String? userName,
    bool? onboardingComplete,
    bool? useFloatingNavBar,
    bool? hapticFeedback,
    bool? showNavLabels,
    bool? pressSound,
    double? targetCgpa,
    bool? telegramPromptShown,
    bool? useAltAppIcon,
  }) {
    return AppSettings(
      id: state.id,
      primaryColorValue: primaryColorValue ?? state.primaryColorValue,
      themeMode: themeMode ?? state.themeMode,
      notificationEnabled: notificationEnabled ?? state.notificationEnabled,
      userName: userName ?? state.userName,
      onboardingComplete: onboardingComplete ?? state.onboardingComplete,
      useFloatingNavBar: useFloatingNavBar ?? state.useFloatingNavBar,
      hapticFeedback: hapticFeedback ?? state.hapticFeedback,
      showNavLabels: showNavLabels ?? state.showNavLabels,
      pressSound: pressSound ?? state.pressSound,
      targetCgpa: targetCgpa ?? state.targetCgpa,
      telegramPromptShown: telegramPromptShown ?? state.telegramPromptShown,
      useAltAppIcon: useAltAppIcon ?? state.useAltAppIcon,
    );
  }

  void _saveAndUpdate(AppSettings updated) {
    try {
      LocalStorage.appSettingsBox.put('default', updated);
    } catch (_) {}
    state = updated;
  }

  void setThemeMode(String mode) => _saveAndUpdate(_copy(themeMode: mode));

  void setPrimaryColor(int value) =>
      _saveAndUpdate(_copy(primaryColorValue: value));

  void setNotificationEnabled(bool enabled) =>
      _saveAndUpdate(_copy(notificationEnabled: enabled));

  void setUserName(String name) => _saveAndUpdate(_copy(userName: name));

  void setOnboardingComplete(bool value) =>
      _saveAndUpdate(_copy(onboardingComplete: value));
  void setUseFloatingNavBar(bool value) =>
      _saveAndUpdate(_copy(useFloatingNavBar: value));
  void setHapticFeedback(bool value) =>
      _saveAndUpdate(_copy(hapticFeedback: value));
  void setShowNavLabels(bool value) =>
      _saveAndUpdate(_copy(showNavLabels: value));
  void setPressSound(bool value) => _saveAndUpdate(_copy(pressSound: value));
  void setTargetCgpa(double value) => _saveAndUpdate(_copy(targetCgpa: value));

  void setTelegramPromptShown(bool value) =>
      _saveAndUpdate(_copy(telegramPromptShown: value));

  void setUseAltAppIcon(bool value) =>
      _saveAndUpdate(_copy(useAltAppIcon: value));
}

final useFloatingNavBarProvider = Provider<bool>((ref) {
  return ref.watch(settingsProvider.select((s) => s.useFloatingNavBar));
});

final useHapticFeedbackProvider = Provider<bool>((ref) {
  return ref.watch(settingsProvider.select((s) => s.hapticFeedback));
});

final showNavLabelsProvider = Provider<bool>((ref) {
  return ref.watch(settingsProvider.select((s) => s.showNavLabels));
});
