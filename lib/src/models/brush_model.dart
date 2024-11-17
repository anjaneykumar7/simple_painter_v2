import 'dart:ui';

class DrawModel {
  DrawModel({
    required this.offset,
    required this.color,
    required this.strokeWidth,
  });

  final Offset offset;
  final Color color;
  final double strokeWidth;
}
