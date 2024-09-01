import 'package:flutter/material.dart';
import 'package:flutter_painter/src/controllers/settings/text_settings.dart';

class PainterSettings {
  const PainterSettings({
    this.text,
    this.scale,
    Color? itemDragHandleColor,
  }) : itemDragHandleColor = itemDragHandleColor ?? Colors.blue;
  final TextSettings? text;
  final Size? scale;
  final Color itemDragHandleColor;
}
