import '../../core/utils/grade_calculator.dart';
import '../entities/course.dart';

class CgpaResult {
  final double cgpa;
  final double percentage;
  final String letterGrade;
  final double delta;

  const CgpaResult({
    required this.cgpa,
    required this.percentage,
    required this.letterGrade,
    this.delta = 0.0,
  });
}

class CgpaCalculatorUseCase {
  CgpaResult execute(List<CourseEntity> courses) {
    final grades = courses
        .where((c) => c.currentGrade > 0)
        .map((c) => (grade: c.currentGrade, credits: c.creditHours))
        .toList();

    final cgpa = GradeCalculator.computeCgpa(grades);
    final percentage = GradeCalculator.percentageFromGpa(cgpa);
    final letter = GradeCalculator.gpaToLetter(cgpa);

    return CgpaResult(
      cgpa: double.parse(cgpa.toStringAsFixed(2)),
      percentage: double.parse(percentage.toStringAsFixed(1)),
      letterGrade: letter,
    );
  }
}
