import 'package:flutter/services.dart';
import '../../core/constants/app_constants.dart';

class WidgetBridge {
  static const _channel = MethodChannel(AppConstants.channelWidget);

  /// Pushes a data snapshot to the home-screen widget.
  /// Returns `true` if at least one widget instance was updated.
  static Future<bool> updateWidget(Map<String, dynamic> data) async {
    try {
      final updated = await _channel.invokeMethod<bool>('updateWidget', data);
      return updated ?? false;
    } catch (_) {
      return false;
    }
  }

  /// Asks the system launcher to show the "Add widget" pin dialog
  /// (Android 8+). Returns `true` if the request was accepted.
  static Future<bool> requestPin() async {
    try {
      final pinned = await _channel.invokeMethod<bool>('requestPinWidget');
      return pinned ?? false;
    } catch (_) {
      return false;
    }
  }

  /// Whether at least one study widget is currently placed on the home screen.
  static Future<bool> hasWidgets() async {
    try {
      final placed = await _channel.invokeMethod<bool>('hasWidgets');
      return placed ?? false;
    } catch (_) {
      return false;
    }
  }
}
