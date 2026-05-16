import '../entities/task.dart';

abstract class TaskRepository {
  List<TaskEntity> getTasks();
  List<TaskEntity> getTasksForCourse(String courseId);
  void addTask(TaskEntity task);
  void toggleTask(String id);
  void deleteTask(String id);
  Stream<List<TaskEntity>> watchTasks();
}
