import 'dart:async';
import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import '../../domain/entities/pomodoro_session.dart';
import '../../domain/repositories/pomodoro_repository.dart';
import '../datasources/local_storage.dart';

class PomodoroRepositoryImpl implements PomodoroRepository {
  Box<String> get _box => LocalStorage.pomodoroSessionsBox;

  @override
  List<PomodoroSessionEntity> getSessions() {
    return _box.values.map(_decodeSession).toList();
  }

  @override
  void addSession(PomodoroSessionEntity session) {
    _box.put(session.id, _encodeSession(session));
  }

  @override
  Stream<List<PomodoroSessionEntity>> watchSessions() {
    return _box.watch().map((_) => getSessions());
  }

  String _encodeSession(PomodoroSessionEntity s) {
    return jsonEncode({
      'id': s.id,
      'courseId': s.courseId,
      'durationSeconds': s.durationSeconds,
      'timestamp': s.timestamp.toIso8601String(),
      'completed': s.completed,
    });
  }

  PomodoroSessionEntity _decodeSession(String json) {
    final m = jsonDecode(json) as Map<String, dynamic>;
    return PomodoroSessionEntity(
      id: m['id'] as String,
      courseId: m['courseId'] as String?,
      durationSeconds: m['durationSeconds'] as int,
      timestamp: DateTime.parse(m['timestamp'] as String),
      completed: m['completed'] as bool? ?? true,
    );
  }
}
