import 'package:flutter_painter/flutter_painter.dart';
import 'package:flutter_painter/src/controllers/items/painter_item.dart';
import 'package:flutter_painter/src/controllers/paint_actions/main/image_actions/image_change_value_action.dart';
import 'package:flutter_painter/src/controllers/paint_actions/main/shape_actions/shape_change_value_action.dart';
import 'package:flutter_painter/src/controllers/paint_actions/paint_action.dart';
import 'package:flutter_painter/src/controllers/paint_actions/text_actions/text_change_value_action.dart';

class ChangeItemValuesService {
  // A list to store PainterItem objects.
  List<PainterItem> items = [];

  // Changes the values of a specific PainterItem in the items list.
  void changeItemValues(
    PainterItem item, // The item to update.
    List<PainterItem> itemsList, // The list of items to update from.
    void Function(
      PaintAction action, // The action taken (for undo/redo purposes).
      List<PainterItem> items, // The updated list of items.
      dynamic selectedItem, // The selected item to be updated.
    ) updatedValues, // Callback function to update values.
  ) {
    // Assign the provided list of items to the service's items list.
    items = itemsList;

    // Find the index of the item to be updated by matching IDs.
    final index = items.indexWhere((element) => element.id == item.id);
    final lastItem = items[index]; // Get the current item at that index.

    // Create a new item with updated values based on the last item.
    final newItem = item.copyWith(
      size: lastItem.size, // Keep the size unchanged.
      position: lastItem.position, // Keep the position unchanged.
      rotation: lastItem.rotation, // Keep the rotation unchanged.
    );

    // Remove the old item and insert the new item at the same index.
    items
      ..removeAt(index)
      ..insert(index, newItem);

    // Call the updatedValues function to apply the changes.
    updatedValues(_getAction(newItem, lastItem), items, item);
  }

  // Determines the appropriate action type for the change based on item types.
  PaintAction _getAction(PainterItem item, PainterItem lastItem) {
    // If the item is a TextItem, create a change action for text.
    if (item is TextItem && lastItem is TextItem) {
      return ActionTextChangeValue(
        currentItem: item,
        lastItem: lastItem,
        timestamp: DateTime.now(), // Timestamp for the action.
        actionType:
            ActionType.changeTextValue, // Action type: change text value.
      );
    }
    // If the item is an ImageItem, create a change action for image.
    else if (item is ImageItem && lastItem is ImageItem) {
      return ActionImageChangeValue(
        currentItem: item,
        lastItem: lastItem,
        timestamp: DateTime.now(), // Timestamp for the action.
        actionType:
            ActionType.changeImageValue, // Action type: change image value.
      );
    }
    // Otherwise, create a change action for a shape item.
    else {
      return ActionShapeChangeValue(
        currentItem: item as ShapeItem, // Cast the item to ShapeItem.
        lastItem: lastItem as ShapeItem, // Cast the last item to ShapeItem.
        timestamp: DateTime.now(), // Timestamp for the action.
        actionType:
            ActionType.changeShapeValue, // Action type: change shape value.
      );
    }
  }
}
