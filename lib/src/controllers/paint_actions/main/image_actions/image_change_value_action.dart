import 'package:flutter_painter/flutter_painter.dart';
import 'package:flutter_painter/src/controllers/paint_actions/paint_action.dart';

class ActionImageChangeValue extends PaintAction {
  const ActionImageChangeValue({
    required this.currentItem,
    required this.lastItem,
    required super.timestamp,
    required super.actionType,
  });
  final ImageItem currentItem;
  final ImageItem lastItem;
}
