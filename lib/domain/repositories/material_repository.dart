import '../entities/course_material.dart';

abstract class MaterialRepository {
  List<CourseMaterialEntity> getMaterials(String courseId);
  void addMaterial(CourseMaterialEntity material);
  void deleteMaterial(String id);
}
