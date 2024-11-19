import 'package:flutter/material.dart';
import 'package:simple_painter/src/controllers/settings/brush_settings.dart';
import 'package:simple_painter/src/controllers/settings/erase_settings.dart';
import 'package:simple_painter/src/controllers/settings/text_settings.dart';

/// A class containing global settings for the painter,
/// including brush and eraser configurations.
class PainterSettings {
  const PainterSettings({
    this.text,
    this.brush,
    this.erase,
    Size? scale,
    Color? itemDragHandleColor,
  })  : scale = scale ?? const Size(800, 800),
        itemDragHandleColor = itemDragHandleColor ?? Colors.blue;

  /// Settings related to text, such as style and alignment.
  final TextSettings? text;

  /// The default canvas scale size.
  final Size? scale;

  /// Color of the handles used to drag items on the canvas.
  final Color itemDragHandleColor;

  /// Settings related to the brush tool.
  final BrushSettings? brush;

  /// Settings related to the eraser tool.
  final EraseSettings? erase;
}
