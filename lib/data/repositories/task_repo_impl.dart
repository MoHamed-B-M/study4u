import 'dart:async';
import '../../domain/entities/task.dart';
import '../../domain/repositories/task_repository.dart';
import '../datasources/local_storage.dart';
import '../../shared/models/models.dart' as shared_models;

class TaskRepositoryImpl implements TaskRepository {
  @override
  List<TaskEntity> getTasks() {
    return LocalStorage.tasksBox.values.map(_toEntity).toList();
  }

  @override
  List<TaskEntity> getTasksForCourse(String courseId) {
    return LocalStorage.tasksBox.values
        .where((t) => t.courseId == courseId)
        .map(_toEntity)
        .toList();
  }

  @override
  void addTask(TaskEntity entity) {
    final model = shared_models.StudyTask(
      id: entity.id,
      title: entity.title,
      dueDate: entity.dueDate,
      urgency: entity.urgency == TaskUrgency.urgent
          ? shared_models.TaskUrgency.urgent
          : shared_models.TaskUrgency.normal,
      isCompleted: entity.isCompleted,
      courseId: entity.courseId,
      content: entity.content,
      type: entity.type == TaskType.note ? 'note' : 'task',
    );
    LocalStorage.tasksBox.put(model.id, model);
  }

  @override
  void toggleTask(String id) {
    final task = LocalStorage.tasksBox.get(id);
    if (task != null) {
      task.isCompleted = !task.isCompleted;
      task.save();
    }
  }

  @override
  void deleteTask(String id) {
    LocalStorage.tasksBox.delete(id);
  }

  @override
  Stream<List<TaskEntity>> watchTasks() {
    return LocalStorage.tasksBox.watch().map((_) => getTasks());
  }

  TaskEntity _toEntity(shared_models.StudyTask m) {
    return TaskEntity(
      id: m.id,
      courseId: m.courseId,
      title: m.title,
      content: m.content,
      type: m.type == 'note' ? TaskType.note : TaskType.task,
      urgency: m.urgency == shared_models.TaskUrgency.urgent
          ? TaskUrgency.urgent
          : TaskUrgency.normal,
      dueDate: m.dueDate,
      isCompleted: m.isCompleted,
    );
  }
}
