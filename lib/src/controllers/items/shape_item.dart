import 'package:flutter/material.dart';
import 'package:flutter_painter/flutter_painter.dart';
import 'package:flutter_painter/src/controllers/items/painter_item.dart';
import 'package:flutter_painter/src/controllers/settings/layer_settings.dart';
import 'package:flutter_painter/src/models/position_model.dart';
import 'package:flutter_painter/src/models/size_model.dart';

class ShapeItem extends PainterItem {
  ShapeItem({
    required super.position,
    required super.layer,
    required this.shapeType,
    this.backgroundColor = Colors.transparent,
    this.lineColor = Colors.black,
    this.thickness = 2,
    super.id,
    super.size,
    super.enabled = true,
    super.rotation,
  });

  final ShapeType shapeType;
  final Color backgroundColor;
  final Color lineColor;
  final double thickness;
  @override
  ShapeItem copyWith({
    PositionModel? position,
    LayerSettings? layer,
    ShapeType? shapeType,
    Color? backgroundColor,
    Color? lineColor,
    double? thickness,
    SizeModel? size,
    double? rotation,
    bool? enabled,
  }) {
    return ShapeItem(
      id: id,
      position: position ?? this.position,
      layer: layer ?? this.layer,
      shapeType: shapeType ?? this.shapeType,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      lineColor: lineColor ?? this.lineColor,
      thickness: thickness ?? this.thickness,
      rotation: rotation ?? this.rotation,
      size: size ?? this.size,
      enabled: enabled ?? this.enabled,
    );
  }
}
