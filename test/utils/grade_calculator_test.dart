import 'package:flutter_test/flutter_test.dart';
import 'package:stdy4u/core/utils/grade_calculator.dart';

void main() {
  group('GradeCalculator.computeCgpa', () {
    test('returns 0.0 for empty list', () {
      final result = GradeCalculator.computeCgpa([]);
      expect(result, 0.0);
    });

    test('returns 4.0 for all A grades with varying credits', () {
      final result = GradeCalculator.computeCgpa([
        (grade: 4.0, credits: 3),
        (grade: 4.0, credits: 4),
        (grade: 4.0, credits: 2),
      ]);
      expect(result, 4.0);
    });

    test('correctly computes weighted CGPA', () {
      // 3 credits of A (4.0) = 12 points
      // 4 credits of B (3.0) = 12 points
      // Total points = 24, Total credits = 7
      // CGPA = 24 / 7 = 3.42857...
      final result = GradeCalculator.computeCgpa([
        (grade: 4.0, credits: 3),
        (grade: 3.0, credits: 4),
      ]);
      expect(result, closeTo(3.4286, 0.001));
    });

    test('handles zero credits gracefully', () {
      final result = GradeCalculator.computeCgpa([
        (grade: 4.0, credits: 0),
        (grade: 3.0, credits: 0),
      ]);
      expect(result, 0.0);
    });

    test('clamps result to 4.0 max', () {
      final result = GradeCalculator.computeCgpa([
        (grade: 4.5, credits: 3),
      ]);
      expect(result, 4.0);
    });

    test('clamps result to 0.0 min', () {
      final result = GradeCalculator.computeCgpa([
        (grade: -1.0, credits: 3),
      ]);
      expect(result, 0.0);
    });

    test('realistic semester calculation', () {
      final result = GradeCalculator.computeCgpa([
        (grade: 3.7, credits: 3),  // A- in 3-credit course
        (grade: 4.0, credits: 4),  // A in 4-credit course
        (grade: 3.0, credits: 3),  // B in 3-credit course
        (grade: 3.3, credits: 3),  // B+ in 3-credit course
      ]);
      // (3.7*3 + 4.0*4 + 3.0*3 + 3.3*3) / (3+4+3+3)
      // = (11.1 + 16.0 + 9.0 + 9.9) / 13
      // = 46.0 / 13
      // = 3.53846...
      expect(result, closeTo(3.5385, 0.001));
    });
  });

  group('GradeCalculator.gpaToLetter', () {
    test('returns A for 4.0', () {
      expect(GradeCalculator.gpaToLetter(4.0), 'A');
    });

    test('returns F for 0.0', () {
      expect(GradeCalculator.gpaToLetter(0.0), 'F');
    });

    test('returns B+ for 3.3', () {
      expect(GradeCalculator.gpaToLetter(3.3), 'B+');
    });
  });

  group('GradeCalculator.letterToGpa', () {
    test('returns 4.0 for A', () {
      expect(GradeCalculator.letterToGpa('A'), 4.0);
    });

    test('returns 0.0 for F', () {
      expect(GradeCalculator.letterToGpa('F'), 0.0);
    });

    test('returns 3.7 for A-', () {
      expect(GradeCalculator.letterToGpa('A-'), 3.7);
    });
  });
}
