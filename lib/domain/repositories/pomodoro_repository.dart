import '../entities/pomodoro_session.dart';

abstract class PomodoroRepository {
  List<PomodoroSessionEntity> getSessions();
  void addSession(PomodoroSessionEntity session);
  Stream<List<PomodoroSessionEntity>> watchSessions();
}
