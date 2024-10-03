import 'package:flutter_painter/src/controllers/items/painter_item.dart';
import 'package:flutter_painter/src/controllers/paint_actions/paint_action.dart';

class ActionAddItem extends PaintAction {
  const ActionAddItem({
    required this.item,
    required this.listIndex,
    required super.timestamp,
    required super.actionType,
  });
  final PainterItem item;
  final int listIndex;
}
