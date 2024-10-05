import 'package:flutter/material.dart';
import 'package:flutter_painter/src/controllers/items/painter_item.dart';
import 'package:flutter_painter/src/controllers/settings/layer_settings.dart';
import 'package:flutter_painter/src/models/position_model.dart';
import 'package:flutter_painter/src/models/size_model.dart';

class TextItem extends PainterItem {
  TextItem({
    required this.text,
    required super.position,
    required super.layer,
    this.textStyle = const TextStyle(),
    super.id,
    super.size,
    super.enabled = true,
    super.rotation,
  });

  final String text;
  final TextStyle textStyle;

  @override
  TextItem copyWith({
    String? text,
    TextStyle? textStyle,
    PositionModel? position,
    LayerSettings? layer,
    SizeModel? size,
    double? rotation,
    bool? enabled,
  }) {
    return TextItem(
      id: id,
      text: text ?? this.text,
      textStyle: textStyle ?? this.textStyle,
      position: position ?? this.position,
      layer: layer ?? this.layer,
      rotation: rotation ?? this.rotation,
      size: size ?? this.size,
      enabled: enabled ?? this.enabled,
    );
  }
}
