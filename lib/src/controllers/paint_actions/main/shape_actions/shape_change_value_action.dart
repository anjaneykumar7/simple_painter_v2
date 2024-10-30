import 'package:flutter_painter/flutter_painter.dart';
import 'package:flutter_painter/src/controllers/paint_actions/paint_action.dart';

class ActionShapeChangeValue extends PaintAction {
  const ActionShapeChangeValue({
    required this.currentItem,
    required this.lastItem,
    required super.timestamp,
    required super.actionType,
  });
  final ShapeItem currentItem;
  final ShapeItem lastItem;
}
