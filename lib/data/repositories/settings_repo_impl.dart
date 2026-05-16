import 'dart:async';
import '../../domain/repositories/settings_repository.dart';
import '../datasources/local_storage.dart';
import '../models/app_settings.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  AppSettings get _s => LocalStorage.appSettingsBox.get('default') ?? AppSettings();

  @override
  int getPrimaryColorValue() => _s.primaryColorValue;

  @override
  String getThemeMode() => _s.themeMode;

  @override
  bool getNotificationEnabled() => _s.notificationEnabled;

  @override
  String getUserName() => _s.userName;

  @override
  void setPrimaryColorValue(int value) {
    final s = _s;
    final updated = AppSettings(
      id: s.id,
      primaryColorValue: value,
      themeMode: s.themeMode,
      notificationEnabled: s.notificationEnabled,
      userName: s.userName,
    );
    LocalStorage.appSettingsBox.put('default', updated);
  }

  @override
  void setThemeMode(String mode) {
    final s = _s;
    final updated = AppSettings(
      id: s.id,
      primaryColorValue: s.primaryColorValue,
      themeMode: mode,
      notificationEnabled: s.notificationEnabled,
      userName: s.userName,
    );
    LocalStorage.appSettingsBox.put('default', updated);
  }

  @override
  void setNotificationEnabled(bool enabled) {
    final s = _s;
    final updated = AppSettings(
      id: s.id,
      primaryColorValue: s.primaryColorValue,
      themeMode: s.themeMode,
      notificationEnabled: enabled,
      userName: s.userName,
    );
    LocalStorage.appSettingsBox.put('default', updated);
  }

  @override
  void setUserName(String name) {
    final s = _s;
    final updated = AppSettings(
      id: s.id,
      primaryColorValue: s.primaryColorValue,
      themeMode: s.themeMode,
      notificationEnabled: s.notificationEnabled,
      userName: name,
    );
    LocalStorage.appSettingsBox.put('default', updated);
  }

  @override
  Stream<void> watchSettings() {
    return LocalStorage.appSettingsBox.watch().map((_) => null);
  }
}
