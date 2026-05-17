import 'dart:async';
import 'package:flutter/services.dart';
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

  PomodoroState({
    required this.remainingSeconds,
    required this.status,
    this.isActive = false,
    this.completedSessions = 0,
    this.courseId,
    this.focusMinutes = AppConstants.pomodoroFocusMinutes,
    this.shortBreakMinutes = AppConstants.pomodoroShortBreakMinutes,
    this.longBreakMinutes = AppConstants.pomodoroLongBreakMinutes,
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

  PomodoroNotifier(this._repository)
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
    super.dispose();
  }
}

final pomodoroProvider = StateNotifierProvider<PomodoroNotifier, PomodoroState>((ref) {
  final repo = ref.watch(pomodoroRepositoryProvider);
  return PomodoroNotifier(repo);
});
