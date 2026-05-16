class CourseMaterialEntity {
  final String id;
  final String courseId;
  final String title;
  final String type; // 'link', 'note', 'file'
  final String content;
  final DateTime createdAt;

  CourseMaterialEntity({
    required this.id,
    required this.courseId,
    required this.title,
    this.type = 'link',
    this.content = '',
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();
}
