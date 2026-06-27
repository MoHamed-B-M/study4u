import 'package:flutter/material.dart';
import 'package:material_new_shapes/material_new_shapes.dart';

class RoundedPolygonShapeBorder extends ShapeBorder {
  final RoundedPolygon polygon;
  final Size size;

  const RoundedPolygonShapeBorder({
    required this.polygon,
    this.size = const Size(200, 200),
  });

  @override
  EdgeInsetsGeometry get dimensions => EdgeInsets.zero;

  @override
  ShapeBorder scale(double t) => this;

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) =>
      getOuterPath(rect, textDirection: textDirection);

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    final scaled = polygon.transformed(
      (Matrix4.identity()
            ..translateByDouble(rect.left, rect.top, 0.0, 1.0)
            ..scaleByDouble(rect.width, rect.height, 1.0, 1.0))
          .asPointTransformer(),
    );
    return pathFromCubics(
      cubics: scaled.cubics,
      path: Path(),
      startAngle: 0,
      repeatPath: false,
      closePath: true,
      rotationPivotX: polygon.centerX,
      rotationPivotY: polygon.centerY,
    );
  }

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {}
}
