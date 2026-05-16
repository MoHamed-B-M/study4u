class GradeCalculator {
  GradeCalculator._();

  static double letterToGpa(String letter) {
    switch (letter.toUpperCase()) {
      case 'A+': return 4.0;
      case 'A':  return 4.0;
      case 'A-': return 3.7;
      case 'B+': return 3.3;
      case 'B':  return 3.0;
      case 'B-': return 2.7;
      case 'C+': return 2.3;
      case 'C':  return 2.0;
      case 'C-': return 1.7;
      case 'D+': return 1.3;
      case 'D':  return 1.0;
      case 'F':  return 0.0;
      default:   return 0.0;
    }
  }

  static String gpaToLetter(double gpa) {
    if (gpa >= 3.7) return 'A';
    if (gpa >= 3.3) return 'B+';
    if (gpa >= 3.0) return 'B';
    if (gpa >= 2.7) return 'B-';
    if (gpa >= 2.3) return 'C+';
    if (gpa >= 2.0) return 'C';
    if (gpa >= 1.7) return 'C-';
    if (gpa >= 1.3) return 'D+';
    if (gpa >= 1.0) return 'D';
    return 'F';
  }

  static double computeCgpa(List<({double grade, double credits})> grades) {
    if (grades.isEmpty) return 0.0;
    double totalPoints = 0;
    double totalCredits = 0;
    for (final g in grades) {
      totalPoints += g.grade * g.credits;
      totalCredits += g.credits;
    }
    if (totalCredits == 0) return 0.0;
    return (totalPoints / totalCredits).clamp(0.0, 4.0);
  }

  static double percentageFromGpa(double gpa) {
    return (gpa / 4.0 * 100).clamp(0, 100);
  }
}
