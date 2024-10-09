import 'dart:ui';

import 'package:flutter_painter/src/controllers/paint_actions/paint_action.dart';

class ActionErase extends PaintAction {
  const ActionErase({
    required this.lastPaintPath,
    required this.currentPaintPath,
    required super.timestamp,
    required super.actionType,
  });

  final List<List<Offset?>> lastPaintPath;
  final List<List<Offset?>> currentPaintPath;
}
