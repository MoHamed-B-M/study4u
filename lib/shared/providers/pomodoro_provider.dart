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
      _logSession();
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

  void _logSession() {
    _repository.addSession(PomodoroSessionEntity(
      id: const Uuid().v4(),
      courseId: state.courseId,
      durationSeconds: AppConstants.pomodoroFocusMinutes * 60,
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
