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

  /// Unconditionally applies [useAlt] to the native launcher aliases.
  /// Idempotent on the platform side (re-setting the same state is a no-op),
  /// so calling this on every launch/resume is safe and keeps Hive as the
  /// single source of truth — nothing may "helpfully" revert the choice.
  static Future<void> apply(bool useAlt) => setAlternate(useAlt);
}
