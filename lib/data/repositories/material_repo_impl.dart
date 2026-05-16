import '../../domain/entities/course_material.dart';
import '../../domain/repositories/material_repository.dart';
import '../datasources/local_storage.dart';
import '../../shared/models/models.dart' as shared_models;

class MaterialRepositoryImpl implements MaterialRepository {
  @override
  List<CourseMaterialEntity> getMaterials(String courseId) {
    return LocalStorage.materialsBox.values
        .where((m) => m.courseId == courseId)
        .map(_toEntity)
        .toList();
  }

  @override
  void addMaterial(CourseMaterialEntity entity) {
    final model = shared_models.CourseMaterial(
      id: entity.id,
      courseId: entity.courseId,
      title: entity.title,
      type: entity.type,
      content: entity.content,
      createdAt: entity.createdAt,
    );
    LocalStorage.materialsBox.put(model.id, model);
  }

  @override
  void deleteMaterial(String id) {
    LocalStorage.materialsBox.delete(id);
  }

  CourseMaterialEntity _toEntity(shared_models.CourseMaterial m) {
    return CourseMaterialEntity(
      id: m.id,
      courseId: m.courseId,
      title: m.title,
      type: m.type,
      content: m.content,
      createdAt: m.createdAt,
    );
  }
}
