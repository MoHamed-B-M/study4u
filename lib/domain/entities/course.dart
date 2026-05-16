class CourseEntity {
  final String id;
  final String code;
  final String name;
  final String room;
  final String professor;
  final String startTime;
  final String endTime;
  final int colorValue;
  final double targetGrade;
  final double currentGrade;
  final double creditHours;
  final String scheduleJson;
  final List<String> weekDays;

  CourseEntity({
    required this.id,
    required this.code,
    required this.name,
    required this.room,
    this.professor = '',
    required this.startTime,
    required this.endTime,
    required this.colorValue,
    this.targetGrade = 4.0,
    this.currentGrade = 0.0,
    this.creditHours = 3.0,
    this.scheduleJson = '[]',
    this.weekDays = const [],
  });

  double get percentage => (currentGrade / targetGrade * 100).clamp(0, 100);
}
