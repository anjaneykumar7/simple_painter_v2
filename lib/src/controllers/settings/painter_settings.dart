import 'package:flutter/material.dart';
import 'package:flutter_painter/src/controllers/settings/brush_settings.dart';
import 'package:flutter_painter/src/controllers/settings/erase_settings.dart';
import 'package:flutter_painter/src/controllers/settings/text_settings.dart';

class PainterSettings {
  const PainterSettings({
    this.text,
    this.brush,
    this.erase,
    Size? scale,
    Color? itemDragHandleColor,
  })  : scale = scale ?? const Size(800, 800),
        itemDragHandleColor = itemDragHandleColor ?? Colors.blue;
  final TextSettings? text;
  final Size? scale;
  final Color itemDragHandleColor;
  final BrushSettings? brush;
  final EraseSettings? erase;
}
