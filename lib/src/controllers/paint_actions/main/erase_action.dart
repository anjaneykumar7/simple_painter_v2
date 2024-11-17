import 'dart:ui';

import 'package:flutter_painter/src/controllers/paint_actions/paint_action.dart';
import 'package:flutter_painter/src/models/brush_model.dart';

class ActionErase extends PaintAction {
  const ActionErase({
    required this.lastPaintPath,
    required this.currentPaintPath,
    required super.timestamp,
    required super.actionType,
  });

  final List<List<DrawModel?>> lastPaintPath;
  final List<List<DrawModel?>> currentPaintPath;
}
