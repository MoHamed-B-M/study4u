import 'package:flutter/services.dart';

import '../../core/constants/app_constants.dart';

/// Switches the Android launcher icon between the default comic icon and the
/// alternate one (see `AppIconPlugin.kt`). The choice itself is persisted in
/// Hive (`AppSettings.useAltAppIcon`) and re-applied on startup.
class AppIconBridge {
  static const _channel = MethodChannel(AppConstants.channelAppIcon);

  /// Enables the matching launcher alias and disables the other one.
  /// Returns `true` if the switch succeeded.
  static Future<bool> setAlternate(bool useAlt) async {
    try {
      final ok = await _channel.invokeMethod<bool>('setAppIcon', useAlt);
      return ok ?? false;
    } catch (_) {
      return false;
    }
  }

  /// Whether the alternate launcher icon is currently active.
  static Future<bool> isAlternate() async {
    try {
      final alt = await _channel.invokeMethod<bool>('isAltIcon');
      return alt ?? false;
    } catch (_) {
      return false;
    }
  }

  /// Applies [useAlt] only when it differs from the currently enabled alias
  /// (e.g. after a reinstall cleared the native component state).
  static Future<void> syncWithSettings(bool useAlt) async {
    try {
      if (await isAlternate() != useAlt) await setAlternate(useAlt);
    } catch (_) {
      // Icon switching must never crash the app.
    }
  }
}
