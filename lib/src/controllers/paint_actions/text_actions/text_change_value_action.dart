import 'package:flutter_painter/flutter_painter.dart';
import 'package:flutter_painter/src/controllers/paint_actions/paint_action.dart';

class ActionTextChangeValue extends PaintAction {
  const ActionTextChangeValue({
    required this.currentItem,
    required this.lastItem,
    required super.timestamp,
    required super.actionType,
  });
  final TextItem currentItem;
  final TextItem lastItem;
}
