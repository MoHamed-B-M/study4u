enum TaskUrgency { urgent, normal }
enum TaskType { task, note }

class TaskEntity {
  final String id;
  final String courseId;
  final String title;
  final String content;
  final TaskType type;
  final TaskUrgency urgency;
  final DateTime dueDate;
  bool isCompleted;

  TaskEntity({
    required this.id,
    required this.courseId,
    required this.title,
    this.content = '',
    this.type = TaskType.task,
    this.urgency = TaskUrgency.normal,
    required this.dueDate,
    this.isCompleted = false,
  });
}
