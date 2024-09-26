import 'package:flutter_painter/src/controllers/items/painter_item.dart';
import 'package:flutter_painter/src/controllers/paint_actions/paint_action.dart';
import 'package:flutter_painter/src/models/position_model.dart';
import 'package:flutter_painter/src/models/size_model.dart';

class ActionSize extends PaintAction {
  const ActionSize({
    required this.oldPosition,
    required this.newPosition,
    required this.oldSize,
    required this.newSize,
    required this.item,
    required super.timestamp,
    required super.actionType,
  });
  final PainterItem item;
  final PositionModel oldPosition;
  final PositionModel newPosition;
  final SizeModel oldSize;
  final SizeModel newSize;
}
