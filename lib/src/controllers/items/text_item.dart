import 'package:flutter/material.dart';
import 'package:flutter_painter/src/controllers/items/painter_item.dart';
import 'package:flutter_painter/src/models/position_model.dart';
import 'package:flutter_painter/src/models/size_model.dart';

class TextItem extends PainterItem {
  TextItem({
    required this.text,
    this.textStyle = const TextStyle(),
    required super.position,
    super.size,
    super.enabled = true,
  });

  final String text;
  final TextStyle textStyle;

  TextItem copyWith({
    String? text,
    TextStyle? textStyle,
    PositionModel? position,
    SizeModel? size,
    bool? enabled,
  }) {
    return TextItem(
      text: text ?? this.text,
      textStyle: textStyle ?? this.textStyle,
      position: position ?? this.position,
      size: size ?? this.size,
      enabled: enabled ?? this.enabled,
    );
  }
}
