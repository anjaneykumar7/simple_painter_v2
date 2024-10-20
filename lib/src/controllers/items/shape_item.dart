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
    this.setFirstLocation = false,
    super.id,
    super.size,
    super.enabled = true,
    super.rotation,
  });

  final ShapeType shapeType;
  final bool setFirstLocation;
  @override
  ShapeItem copyWith({
    PositionModel? position,
    LayerSettings? layer,
    ShapeType? shapeType,
    bool? setFirstLocation,
    SizeModel? size,
    double? rotation,
    bool? enabled,
  }) {
    return ShapeItem(
      id: id,
      position: position ?? this.position,
      layer: layer ?? this.layer,
      shapeType: shapeType ?? this.shapeType,
      rotation: rotation ?? this.rotation,
      setFirstLocation: setFirstLocation ?? this.setFirstLocation,
      size: size ?? this.size,
      enabled: enabled ?? this.enabled,
    );
  }
}
