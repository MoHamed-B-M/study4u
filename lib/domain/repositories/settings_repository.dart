abstract class SettingsRepository {
  int getPrimaryColorValue();
  String getThemeMode();
  bool getNotificationEnabled();
  String getUserName();
  void setPrimaryColorValue(int value);
  void setThemeMode(String mode);
  void setNotificationEnabled(bool enabled);
  void setUserName(String name);
  Stream<void> watchSettings();
}
