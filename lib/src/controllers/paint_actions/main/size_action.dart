import 'package:flutter_painter/src/controllers/items/painter_item.dart';
import 'package:flutter_painter/src/controllers/paint_actions/paint_action.dart';
import 'package:flutter_painter/src/models/position_model.dart';
import 'package:flutter_painter/src/models/size_model.dart';

// Represents an action to change the size of an item.
class ActionSize extends PaintAction {
  const ActionSize({
    required this.oldPosition, // The previous position of the item.
    required this.newPosition, // The new position of the item.
    required this.oldSize, // The previous size of the item.
    required this.newSize, // The updated size of the item.
    required this.item, // The item whose size is changing.
    required super.timestamp, // Timestamp of when the action occurred.
    required super.actionType, // Type of action (sizeItem).
  });

  final PainterItem item; // The item whose size is changing.
  final PositionModel oldPosition; // The previous position of the item.
  final PositionModel newPosition; // The updated position of the item.
  final SizeModel oldSize; // The previous size of the item.
  final SizeModel newSize; // The updated size of the item.
}
