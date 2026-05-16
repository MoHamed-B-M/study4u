import '../entities/course.dart';

abstract class CourseRepository {
  List<CourseEntity> getCourses();
  CourseEntity? getCourse(String id);
  void addCourse(CourseEntity course);
  void updateCourse(CourseEntity course);
  void deleteCourse(String id);
  Stream<List<CourseEntity>> watchCourses();
}
