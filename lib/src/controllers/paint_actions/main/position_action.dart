import 'package:flutter_painter/src/controllers/items/painter_item.dart';
import 'package:flutter_painter/src/controllers/paint_actions/paint_action.dart';
import 'package:flutter_painter/src/models/position_model.dart';

class ActionPosition extends PaintAction {
  const ActionPosition({
    required this.oldPosition,
    required this.newPosition,
    required this.oldRotateAngle,
    required this.newRotateAngle,
    required this.item,
    required super.timestamp,
    required super.actionType,
  });
  final PainterItem item;
  final PositionModel oldPosition;
  final PositionModel newPosition;
  final double oldRotateAngle;
  final double newRotateAngle;
}
