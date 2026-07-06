import 'package:flutter/services.dart';

class SoundService {
  SoundService._();
  static final instance = SoundService._();
  static bool pressSoundEnabled = true;

  void playClick() {
    if (!pressSoundEnabled) return;
    try {
      HapticFeedback.lightImpact();
      SystemSound.play(SystemSoundType.click);
    } catch (_) {}
  }

  void dispose() {}
}
