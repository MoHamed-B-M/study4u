import 'package:flutter/services.dart';
import '../../core/constants/app_constants.dart';

class SettingsBridge {
  static const _channel = MethodChannel(AppConstants.channelSettings);

  static Future<bool> openAppSettings({required String packageName}) async {
    try {
      await _channel.invokeMethod('openAppSettings', {
        'packageName': packageName,
      });
      return true;
    } catch (_) {
      return false;
    }
  }
}
