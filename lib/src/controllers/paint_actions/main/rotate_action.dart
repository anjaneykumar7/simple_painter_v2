import 'package:flutter_painter/src/controllers/items/painter_item.dart';
import 'package:flutter_painter/src/controllers/paint_actions/paint_action.dart';

class ActionRotation extends PaintAction {
  const ActionRotation({
    required this.oldRotateAngle,
    required this.newRotateAngle,
    required this.item,
    required super.timestamp,
    required super.actionType,
  });
  final PainterItem item;
  final double oldRotateAngle;
  final double newRotateAngle;
}
