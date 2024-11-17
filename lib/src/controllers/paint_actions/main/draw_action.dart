import 'dart:ui';

import 'package:flutter_painter/src/controllers/paint_actions/paint_action.dart';
import 'package:flutter_painter/src/models/brush_model.dart';

class ActionDraw extends PaintAction {
  const ActionDraw({
    required this.paintPath,
    required this.listIndex,
    required super.timestamp,
    required super.actionType,
  });

  final List<DrawModel?> paintPath;
  final int listIndex;
}
