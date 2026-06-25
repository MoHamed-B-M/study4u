import 'dart:async';
import 'package:flutter/services.dart';
import 'package:just_audio/just_audio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../core/constants/app_constants.dart';
import '../../domain/entities/pomodoro_session.dart';
import '../../data/repositories/pomodoro_repo_impl.dart';
import '../providers/logic_providers.dart';

enum PomodoroStatus { focus, shortBreak, longBreak, idle }

class PomodoroState {
  final int remainingSeconds;
  final PomodoroStatus status;
  final bool isActive;
  final int completedSessions;
  final String? courseId;
  final int focusMinutes;
  final int shortBreakMinutes;
  final int longBreakMinutes;
  final String? musicFilePath;
  final bool isMusicPlaying;

  PomodoroState({
    required this.remainingSeconds,
    required this.status,
    this.isActive = false,
    this.completedSessions = 0,
    this.courseId,
    this.focusMinutes = AppConstants.pomodoroFocusMinutes,
    this.shortBreakMinutes = AppConstants.pomodoroShortBreakMinutes,
    this.longBreakMinutes = AppConstants.pomodoroLongBreakMinutes,
    this.musicFilePath,
    this.isMusicPlaying = false,
  });

  PomodoroState copyWith({
    int? remainingSeconds,
    PomodoroStatus? status,
    bool? isActive,
    int? completedSessions,
    String? courseId,
    int? focusMinutes,
    int? shortBreakMinutes,
    int? longBreakMinutes,
    String? musicFilePath,
    bool? isMusicPlaying,
  }) {
    return PomodoroState(
      remainingSeconds: remainingSeconds ?? this.remainingSeconds,
      status: status ?? this.status,
      isActive: isActive ?? this.isActive,
      completedSessions: completedSessions ?? this.completedSessions,
      courseId: courseId ?? this.courseId,
      focusMinutes: focusMinutes ?? this.focusMinutes,
      shortBreakMinutes: shortBreakMinutes ?? this.shortBreakMinutes,
      longBreakMinutes: longBreakMinutes ?? this.longBreakMinutes,
      musicFilePath: musicFilePath ?? this.musicFilePath,
      isMusicPlaying: isMusicPlaying ?? this.isMusicPlaying,
    );
  }

  String get timerString {
    final minutes = (remainingSeconds / 60).floor().toString().padLeft(2, '0');
    final seconds = (remainingSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }
}

class PomodoroNotifier extends StateNotifier<PomodoroState> {
  final PomodoroRepositoryImpl _repository;
  Timer? _timer;
  final AudioPlayer _audioPlayer = AudioPlayer();

  PomodoroNotifier(this._repository)
      : super(PomodoroState(
          remainingSeconds: AppConstants.pomodoroFocusMinutes * 60,
          status: PomodoroStatus.idle,
        ));

  void startTimer({String? courseId}) {
    if (state.isActive) return;
    HapticFeedback.mediumImpact();
    if (state.musicFilePath != null) {
      _audioPlayer.play();
    }
    state = state.copyWith(
      isActive: true,
      status: state.status == PomodoroStatus.idle ? PomodoroStatus.focus : state.status,
      courseId: courseId ?? state.courseId,
      isMusicPlaying: state.musicFilePath != null,
    );
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state.remainingSeconds > 0) {
        state = state.copyWith(remainingSeconds: state.remainingSeconds - 1);
      } else {
        _handleSessionComplete();
      }
    });
  }

  void pauseTimer() {
    _timer?.cancel();
    _audioPlayer.pause();
    HapticFeedback.mediumImpact();
    state = state.copyWith(isActive: false, isMusicPlaying: false);
  }

  void resetTimer() {
    pauseTimer();
    _audioPlayer.stop();
    state = PomodoroState(
      remainingSeconds: state.focusMinutes * 60,
      status: PomodoroStatus.idle,
      focusMinutes: state.focusMinutes,
      shortBreakMinutes: state.shortBreakMinutes,
      longBreakMinutes: state.longBreakMinutes,
    );
  }

  void skipSession() {
    _handleSessionComplete();
  }

  void setDurations(int focus, int shortBreak, int longBreak) {
    if (state.isActive) {
      state = state.copyWith(
        focusMinutes: focus,
        shortBreakMinutes: shortBreak,
        longBreakMinutes: longBreak,
      );
    } else {
      int newRemaining = state.remainingSeconds;
      if (state.status == PomodoroStatus.idle || state.status == PomodoroStatus.focus) {
        newRemaining = focus * 60;
      } else if (state.status == PomodoroStatus.shortBreak) {
        newRemaining = shortBreak * 60;
      } else if (state.status == PomodoroStatus.longBreak) {
        newRemaining = longBreak * 60;
      }
      state = state.copyWith(
        focusMinutes: focus,
        shortBreakMinutes: shortBreak,
        longBreakMinutes: longBreak,
        remainingSeconds: newRemaining,
      );
    }
  }

  void setMusicFile(String? path) {
    if (path != null) {
      _audioPlayer.setFilePath(path);
    }
    state = state.copyWith(musicFilePath: path, isMusicPlaying: false);
  }

  void toggleMusic() {
    if (state.isMusicPlaying) {
      _audioPlayer.pause();
    } else if (state.musicFilePath != null) {
      _audioPlayer.play();
    }
    state = state.copyWith(isMusicPlaying: !state.isMusicPlaying);
  }

  void _handleSessionComplete() {
    pauseTimer();
    HapticFeedback.heavyImpact();
    Future.delayed(const Duration(milliseconds: 200), () {
      HapticFeedback.heavyImpact();
    });

    if (state.status == PomodoroStatus.focus) {
      _logSession();
      final newSessions = state.completedSessions + 1;
      if (newSessions % AppConstants.pomodoroSessionsBeforeLongBreak == 0) {
        state = state.copyWith(
          status: PomodoroStatus.longBreak,
          remainingSeconds: state.longBreakMinutes * 60,
          completedSessions: newSessions,
        );
      } else {
        state = state.copyWith(
          status: PomodoroStatus.shortBreak,
          remainingSeconds: state.shortBreakMinutes * 60,
          completedSessions: newSessions,
        );
      }
    } else {
      state = state.copyWith(
        status: PomodoroStatus.focus,
        remainingSeconds: state.focusMinutes * 60,
      );
    }
  }

  void _logSession() {
    _repository.addSession(PomodoroSessionEntity(
      id: const Uuid().v4(),
      courseId: state.courseId,
      durationSeconds: state.focusMinutes * 60,
      timestamp: DateTime.now(),
      completed: true,
    ));
  }

  @override
  void dispose() {
    _timer?.cancel();
    _audioPlayer.dispose();
    super.dispose();
  }
}

final pomodoroProvider = StateNotifierProvider<PomodoroNotifier, PomodoroState>((ref) {
  final repo = ref.watch(pomodoroRepositoryProvider);
  return PomodoroNotifier(repo);
});
