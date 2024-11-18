import 'package:flutter/material.dart';
import 'package:flutter_painter/flutter_painter.dart';
import 'package:flutter_painter/src/controllers/items/painter_item.dart';
import 'package:flutter_painter/src/controllers/paint_actions/layer/layer_change_action.dart';
import 'package:flutter_painter/src/controllers/paint_actions/main/add_item_action.dart';
import 'package:flutter_painter/src/controllers/paint_actions/main/draw_action.dart';
import 'package:flutter_painter/src/controllers/paint_actions/main/erase_action.dart';
import 'package:flutter_painter/src/controllers/paint_actions/main/image_actions/image_change_value_action.dart';
import 'package:flutter_painter/src/controllers/paint_actions/main/position_action.dart';
import 'package:flutter_painter/src/controllers/paint_actions/main/remove_item_action.dart';
import 'package:flutter_painter/src/controllers/paint_actions/main/rotate_action.dart';
import 'package:flutter_painter/src/controllers/paint_actions/main/shape_actions/shape_change_value_action.dart';
import 'package:flutter_painter/src/controllers/paint_actions/main/size_action.dart';
import 'package:flutter_painter/src/controllers/paint_actions/paint_action.dart';
import 'package:flutter_painter/src/controllers/paint_actions/paint_actions.dart';
import 'package:flutter_painter/src/controllers/paint_actions/text_actions/text_change_value_action.dart';
import 'package:flutter_painter/src/models/brush_model.dart';

class ActionsService {
  // Keeps track of the list of actions performed.
  List<PaintAction> currentActions = [];
  // The current index in the actions list.
  int currentIndex = 0;
  // List of items in the painting, representing the objects being manipulated.
  List<PainterItem> items = [];
  // Stores the painting paths for drawing or erasing.
  List<List<DrawModel?>> currentPaintPath = [];

  // Updates actions by determining whether to undo or
  //redo and applies the corresponding actions.
  void updateActionWithChangeActionIndex(
    ValueNotifier<PaintActions> changeActions,
    List<List<DrawModel?>> paintPath,
    PainterControllerValue value,
    int index,
    void Function(List<PainterItem> items) updatedList,
    void Function(int index) updateIndex,
    void Function(List<List<DrawModel?>> pathList) updatedPaintPath,
  ) {
    // Set the values before performing any action.
    _setValues(changeActions, paintPath, value);

    // Function to undo actions from the current
    // index back to the specified index.
    void undoActions() {
      for (var i = currentIndex; i > index; i--) {
        if (currentActions[i] is ActionAddItem) {
          _actionAddItem(currentActions[i] as ActionAddItem, false);
        }
        if (currentActions[i] is ActionPosition) {
          _actionPosition(currentActions[i] as ActionPosition, false);
        } else if (currentActions[i] is ActionSize) {
          _actionSize(currentActions[i] as ActionSize, false);
        } else if (currentActions[i] is ActionRotation) {
          _actionRotation(currentActions[i] as ActionRotation, false);
        } else if (currentActions[i] is ActionLayerChange) {
          _actionLayerChange(currentActions[i] as ActionLayerChange, false);
        } else if (currentActions[i] is ActionRemoveItem) {
          _actionRemoveItem(currentActions[i] as ActionRemoveItem, false);
        } else if (currentActions[i] is ActionDraw) {
          _actionDraw(currentActions[i] as ActionDraw, false);
        } else if (currentActions[i] is ActionErase) {
          _actionErese(currentActions[i] as ActionErase, false);
        } else if (currentActions[i] is ActionTextChangeValue ||
            currentActions[i] is ActionImageChangeValue ||
            currentActions[i] is ActionShapeChangeValue) {
          _actionChangeValue(currentActions[i], false);
        }
      }
    }

    // Function to redo actions from the current index to the specified index.
    void redoActions() {
      for (var i = currentIndex + 1; i <= index; i++) {
        if (currentActions[i] is ActionAddItem) {
          _actionAddItem(currentActions[i] as ActionAddItem, true);
        }
        if (currentActions[i] is ActionPosition) {
          _actionPosition(currentActions[i] as ActionPosition, true);
        } else if (currentActions[i] is ActionSize) {
          _actionSize(currentActions[i] as ActionSize, true);
        } else if (currentActions[i] is ActionRotation) {
          _actionRotation(currentActions[i] as ActionRotation, true);
        } else if (currentActions[i] is ActionLayerChange) {
          _actionLayerChange(currentActions[i] as ActionLayerChange, true);
        } else if (currentActions[i] is ActionRemoveItem) {
          _actionRemoveItem(currentActions[i] as ActionRemoveItem, true);
        } else if (currentActions[i] is ActionDraw) {
          _actionDraw(currentActions[i] as ActionDraw, true);
        } else if (currentActions[i] is ActionErase) {
          _actionErese(currentActions[i] as ActionErase, true);
        } else if (currentActions[i] is ActionTextChangeValue ||
            currentActions[i] is ActionImageChangeValue ||
            currentActions[i] is ActionShapeChangeValue) {
          _actionChangeValue(currentActions[i], true);
        }
      }
    }

    // Decide whether to undo or redo actions based on the provided index.
    if (index < currentIndex) {
      undoActions();
    } else {
      redoActions();
    }

    // Update the list, index, and paint path after performing the actions.
    updatedList(items);
    updateIndex(index);
    updatedPaintPath(currentPaintPath);
  }

  // Adds a new action to the list of actions and updates the actions history.
  void addAction(
    PaintAction action,
    ValueNotifier<PaintActions> changeActions,
    PainterControllerValue value,
    void Function(List<PaintAction>? items, int index) updatedValues,
  ) {
    // Set values before adding the new action.
    _setValues(changeActions, currentPaintPath, value);

    // If we're not at the end of the action
    //history, trim the redo actions before adding the new action.
    if (changeActions.value.index < changeActions.value.changeList.length - 1) {
      changeActions.value = changeActions.value.copyWith(
        changeList: changeActions.value.changeList
            .sublist(0, changeActions.value.index + 1),
        index: changeActions.value.index + 1,
      );
    }
    // Add the new action to the history and update the state.
    changeActions.value = changeActions.value.copyWith(
      changeList: changeActions.value.changeList.toList()..add(action),
      index: changeActions.value.changeList.length,
    );

    // Update the values with the new action.
    updatedValues(
      changeActions.value.changeList,
      changeActions.value.changeList.length - 1,
    );
  }

  // Updates the item in the list after an action.
  void _updateList(PainterItem item) {
    // Find the index of the item to update.
    final itemIndex = items.indexWhere((element) {
      return element.id == item.id;
    });

    // Remove the old item and insert the updated one.
    items
      ..removeAt(itemIndex)
      ..insert(itemIndex, item);
  }

  // Handles adding an item to the list of items during redo/undo actions.
  void _actionAddItem(ActionAddItem item, bool isRedo) {
    if (isRedo) {
      // For redo, add the item back to the list at the specified index.
      items.insert(item.listIndex, item.item);
    } else {
      // For undo, remove the item from the list.
      final itemValue = items
          .where(
            (element) => element.id == item.item.id,
          )
          .first;
      _removeItemFromList(itemValue.id);
    }
  }

  // Handles resizing an item and updating its position during redo/undo actions.
  void _actionSize(ActionSize item, bool isRedo) {
    var itemValue = items
        .where(
          (element) => element.id == item.item.id,
        )
        .first;

    // For redo, update the item's size and position to the new values.
    if (isRedo) {
      itemValue = itemValue.copyWith(
        size: item.newSize,
        position: item.newPosition,
      );
    } else {
      // For undo, revert the item's size and position to the original values.
      itemValue = itemValue.copyWith(
        size: item.oldSize,
        position: item.oldPosition,
      );
    }

    // Update the list with the modified item.
    _updateList(itemValue);
  }

  // Handles moving an item to a new position during redo/undo actions.
  void _actionPosition(ActionPosition item, bool isRedo) {
    var itemValue = items
        .where(
          (element) => element.id == item.item.id,
        )
        .first;

    // For redo, update the item's position to the new value.
    if (isRedo) {
      itemValue = itemValue.copyWith(position: item.newPosition);
    } else {
      // For undo, revert the item's position to the original value.
      itemValue = itemValue.copyWith(position: item.oldPosition);
    }

    // Update the list with the modified item.
    _updateList(itemValue);
  }

  // Removes an item from the list based on its ID.
  void _removeItemFromList(String itemId) {
    // Find and remove the item with the matching ID.
    items.removeWhere((element) => element.id == itemId);
  }

  // Handles rotation actions during redo/undo operations.
  void _actionRotation(ActionRotation item, bool isRedo) {
    // Find the item in the list using its ID.
    var itemValue = items
        .where(
          (element) => element.id == item.item.id,
        )
        .first;

    // If it's a redo, apply the new rotation angle.
    if (isRedo) {
      itemValue = itemValue.copyWith(rotation: item.newRotateAngle);
    } else {
      // If it's an undo, revert to the old rotation angle.
      itemValue = itemValue.copyWith(rotation: item.oldRotateAngle);
    }

    // Update the list with the modified item.
    _updateList(itemValue);
  }

  // Handles layer change actions during redo/undo operations.
  void _actionLayerChange(ActionLayerChange item, bool isRedo) {
    // Find the item and changed item in the list using their IDs.
    final itemValue = items
        .where(
          (element) => element.id == item.item.id,
        )
        .first;
    final changedItem = items
        .where(
          (element) => element.id == item.changedItem.id,
        )
        .first;

    // If it's a redo, move the items to the new positions in the list.
    if (isRedo) {
      items
        ..remove(itemValue)
        ..insert(item.newIndex, itemValue)
        ..remove(changedItem)
        ..insert(item.changedItemNewIndex, changedItem);
    } else {
      // If it's an undo, move the items back to their original positions.
      items
        ..remove(itemValue)
        ..insert(item.oldIndex, itemValue)
        ..remove(changedItem)
        ..insert(item.changedItemOldIndex, changedItem);
    }
  }

  // Handles item removal actions during redo/undo operations.
  void _actionRemoveItem(ActionRemoveItem item, bool isRedo) {
    // If it's a redo, remove the item from the list.
    if (isRedo) {
      _removeItemFromList(item.item.id);
    } else {
      // If it's an undo, add the item back to the list at the specified index.
      items.insert(item.listIndex, item.item);
    }
  }

  // Handles drawing actions during redo/undo operations.
  void _actionDraw(ActionDraw item, bool isRedo) {
    // If it's a redo, insert the drawn path at the specified index.
    if (isRedo) {
      currentPaintPath.insert(item.listIndex, item.paintPath);
    } else {
      // If it's an undo, remove the drawn path at the specified index.
      currentPaintPath.removeAt(item.listIndex);
    }
  }

  // Handles erase actions during redo/undo operations.
  void _actionErese(ActionErase item, bool isRedo) {
    // If it's a redo, restore the current paint path.
    if (isRedo) {
      currentPaintPath = item.currentPaintPath;
    } else {
      // If it's an undo, restore the last paint path.
      currentPaintPath = item.lastPaintPath;
    }
  }

  // Handles value change actions (e.g., text, image, or shape) during redo/undo operations.
  void _actionChangeValue(dynamic item, bool isRedo) {
    // Find the item in the list using its ID.
    var itemValue = items
        .where(
          (element) =>
              element.id == ((item as dynamic).currentItem as PainterItem).id,
        )
        .first;

    // If it's a redo, update the item with the current value.
    if (isRedo) {
      itemValue = (item as dynamic).currentItem as PainterItem;
    } else {
      // If it's an undo, revert to the last item value.
      itemValue = (item as dynamic).lastItem as PainterItem;
    }

    // Update the list with the modified item.
    _updateList(itemValue);
  }

  // Handles undo operations by updating
  //the state and applying the previous action.
  void undo(
    ValueNotifier<PaintActions> changeActions,
    List<List<DrawModel?>> paintPath,
    PainterControllerValue value,
    void Function(List<PainterItem> items) updatedList,
    void Function(int index) updateIndex,
    void Function(List<List<DrawModel?>> pathList) updatedPaintPath,
  ) {
    // Set the values for the current action state.
    _setValues(changeActions, paintPath, value);

    // If there are no actions to undo, return early.
    if (currentIndex < 0) return;

    // Apply the previous action (one step back)
    //and update the list and paint path.
    updateActionWithChangeActionIndex(
      changeActions,
      currentPaintPath,
      value,
      currentIndex - 1,
      updatedList,
      updateIndex,
      updatedPaintPath,
    );
  }

  // Handles redo operations by updating the state and applying the next action.
  void redo(
    ValueNotifier<PaintActions> changeActions,
    List<List<DrawModel?>> paintPath,
    PainterControllerValue value,
    void Function(List<PainterItem> items) updatedList,
    void Function(int index) updateIndex,
    void Function(List<List<DrawModel?>> pathList) updatedPaintPath,
  ) {
    // Set the values for the current action state.
    _setValues(changeActions, paintPath, value);

    // If there are no actions to redo, return early.
    if (currentIndex == currentActions.length - 1) return;

    // Apply the next action (one step forward)
    //and update the list and paint path.
    updateActionWithChangeActionIndex(
      changeActions,
      currentPaintPath,
      value,
      currentIndex + 1,
      updatedList,
      updateIndex,
      updatedPaintPath,
    );
  }

  // Helper function for setting values for state updates.
  void _setValues(
    ValueNotifier<PaintActions> changeActions,
    List<List<DrawModel?>> paintPath,
    PainterControllerValue value,
  ) {
    // Update the current action values based on the changeActions object.
    currentActions = changeActions.value.changeList;
    currentIndex = changeActions.value.index;
    currentPaintPath = paintPath;
    items = value.items.toList();
  }
}
