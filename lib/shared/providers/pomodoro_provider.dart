import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum PomodoroStatus { focus, shortBreak, longBreak, idle }

class PomodoroState {
  final int remainingSeconds;
  final PomodoroStatus status;
  final bool isActive;
  final int completedSessions;

  PomodoroState({
    required this.remainingSeconds,
    required this.status,
    this.isActive = false,
    this.completedSessions = 0,
  });

  PomodoroState copyWith({
    int? remainingSeconds,
    PomodoroStatus? status,
    bool? isActive,
    int? completedSessions,
  }) {
    return PomodoroState(
      remainingSeconds: remainingSeconds ?? this.remainingSeconds,
      status: status ?? this.status,
      isActive: isActive ?? this.isActive,
      completedSessions: completedSessions ?? this.completedSessions,
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
          remainingSeconds: 25 * 60,
          status: PomodoroStatus.idle,
        ));

  void startTimer() {
    if (state.isActive) return;
    
    state = state.copyWith(isActive: true, status: state.status == PomodoroStatus.idle ? PomodoroStatus.focus : state.status);
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
    state = state.copyWith(isActive: false);
  }

  void resetTimer() {
    pauseTimer();
    state = PomodoroState(
      remainingSeconds: 25 * 60,
      status: PomodoroStatus.idle,
    );
  }

  void _handleSessionComplete() {
    pauseTimer();
    if (state.status == PomodoroStatus.focus) {
      final newSessions = state.completedSessions + 1;
      if (newSessions % 4 == 0) {
        state = state.copyWith(
          status: PomodoroStatus.longBreak,
          remainingSeconds: 15 * 60,
          completedSessions: newSessions,
        );
      } else {
        state = state.copyWith(
          status: PomodoroStatus.shortBreak,
          remainingSeconds: 5 * 60,
          completedSessions: newSessions,
        );
      }
    } else {
      state = state.copyWith(
        status: PomodoroStatus.focus,
        remainingSeconds: 25 * 60,
      );
    }
    // TODO: Trigger local notification
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
