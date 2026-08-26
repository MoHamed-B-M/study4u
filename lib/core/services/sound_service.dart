import 'package:flutter/services.dart';
import 'package:flutter_vibrate/flutter_vibrate.dart';

class SoundService {
  SoundService._();
  static final instance = SoundService._();
  static bool pressSoundEnabled = true;

  void playClick() {
    if (!pressSoundEnabled) return;
    try {
      Vibrate.feedback(FeedbackType.light);
      SystemSound.play(SystemSoundType.click);
    } catch (_) {}
  }

  void dispose() {}
}
