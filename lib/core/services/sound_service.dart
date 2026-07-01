import 'dart:async';
import 'package:just_audio/just_audio.dart';

class SoundService {
  SoundService._();
  static final instance = SoundService._();

  AudioPlayer? _clickPlayer;
  bool _initialized = false;

  Future<void> init() async {
    try {
      _clickPlayer = AudioPlayer();
      await _clickPlayer!.setAsset('assets/audio/mechanical_click.wav');
      await _clickPlayer!.setVolume(0.5);
      _clickPlayer!.setLoopMode(LoopMode.off);
      _initialized = true;
    } catch (_) {
      _initialized = false;
    }
  }

  Future<void> playClick() async {
    if (!_initialized || _clickPlayer == null) return;
    try {
      await _clickPlayer!.stop();
      await _clickPlayer!.seek(Duration.zero);
      unawaited(_clickPlayer!.play());
    } catch (_) {}
  }

  void dispose() {
    _clickPlayer?.dispose();
    _clickPlayer = null;
  }
}
