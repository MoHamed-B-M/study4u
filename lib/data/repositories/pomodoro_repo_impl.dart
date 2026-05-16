import 'dart:async';
import '../../domain/entities/pomodoro_session.dart';
import '../../domain/repositories/pomodoro_repository.dart';

class PomodoroRepositoryImpl implements PomodoroRepository {
  @override
  List<PomodoroSessionEntity> getSessions() {
    return [];
  }

  @override
  void addSession(PomodoroSessionEntity session) {}

  @override
  Stream<List<PomodoroSessionEntity>> watchSessions() {
    return const Stream.empty();
  }
}
