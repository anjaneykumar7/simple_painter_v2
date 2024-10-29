import 'package:flutter/material.dart';
import 'package:flutter_painter/flutter_painter.dart';

class ShapeSettings {
  const ShapeSettings({
    this.shapeType,
    this.backgroundColor,
    this.lineColor,
    this.thickness,
  });

  final ShapeType? shapeType;
  final Color? backgroundColor;
  final Color? lineColor;
  final double? thickness;
}
