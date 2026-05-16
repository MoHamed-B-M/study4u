import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_constants.dart';

enum PomodoroStatus { focus, shortBreak, longBreak, idle }

class PomodoroState {
  final int remainingSeconds;
  final PomodoroStatus status;
  final bool isActive;
  final int completedSessions;
  final String? courseId;

  PomodoroState({
    required this.remainingSeconds,
    required this.status,
    this.isActive = false,
    this.completedSessions = 0,
    this.courseId,
  });

  PomodoroState copyWith({
    int? remainingSeconds,
    PomodoroStatus? status,
    bool? isActive,
    int? completedSessions,
    String? courseId,
  }) {
    return PomodoroState(
      remainingSeconds: remainingSeconds ?? this.remainingSeconds,
      status: status ?? this.status,
      isActive: isActive ?? this.isActive,
      completedSessions: completedSessions ?? this.completedSessions,
      courseId: courseId ?? this.courseId,
    );
  }

  String get timerString {
    final minutes = (remainingSeconds / 60).floor().toString().padLeft(2, '0');
    final seconds = (remainingSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }
}

class PomodoroNotifier extends StateNotifier<PomodoroState> {
  Timer? _timer;

  PomodoroNotifier()
      : super(PomodoroState(
          remainingSeconds: AppConstants.pomodoroFocusMinutes * 60,
          status: PomodoroStatus.idle,
        ));

  void startTimer({String? courseId}) {
    if (state.isActive) return;
    HapticFeedback.mediumImpact();
    state = state.copyWith(
      isActive: true,
      status: state.status == PomodoroStatus.idle ? PomodoroStatus.focus : state.status,
      courseId: courseId ?? state.courseId,
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
    HapticFeedback.mediumImpact();
    state = state.copyWith(isActive: false);
  }

  void resetTimer() {
    pauseTimer();
    state = PomodoroState(
      remainingSeconds: AppConstants.pomodoroFocusMinutes * 60,
      status: PomodoroStatus.idle,
    );
  }

  void skipSession() {
    _handleSessionComplete();
  }

  void _handleSessionComplete() {
    pauseTimer();
    HapticFeedback.heavyImpact();
    Future.delayed(const Duration(milliseconds: 200), () {
      HapticFeedback.heavyImpact();
    });

    if (state.status == PomodoroStatus.focus) {
      final newSessions = state.completedSessions + 1;
      if (newSessions % AppConstants.pomodoroSessionsBeforeLongBreak == 0) {
        state = state.copyWith(
          status: PomodoroStatus.longBreak,
          remainingSeconds: AppConstants.pomodoroLongBreakMinutes * 60,
          completedSessions: newSessions,
        );
      } else {
        state = state.copyWith(
          status: PomodoroStatus.shortBreak,
          remainingSeconds: AppConstants.pomodoroShortBreakMinutes * 60,
          completedSessions: newSessions,
        );
      }
    } else {
      state = state.copyWith(
        status: PomodoroStatus.focus,
        remainingSeconds: AppConstants.pomodoroFocusMinutes * 60,
      );
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

final pomodoroProvider = StateNotifierProvider<PomodoroNotifier, PomodoroState>((ref) {
  return PomodoroNotifier();
});
