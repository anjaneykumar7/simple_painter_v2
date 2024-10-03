import 'package:flutter/material.dart';
import 'package:flutter_painter/flutter_painter.dart';
import 'package:flutter_painter/src/controllers/items/painter_item.dart';
import 'package:flutter_painter/src/controllers/paint_actions/main/add_item_action.dart';
import 'package:flutter_painter/src/controllers/paint_actions/main/position_action.dart';
import 'package:flutter_painter/src/controllers/paint_actions/main/rotate_action.dart';
import 'package:flutter_painter/src/controllers/paint_actions/main/size_action.dart';
import 'package:flutter_painter/src/controllers/paint_actions/paint_action.dart';
import 'package:flutter_painter/src/controllers/paint_actions/paint_actions.dart';

class ActionsService {
  List<PaintAction> currentActions = [];
  int currentIndex = 0;
  List<PainterItem> items = [];

  void updateActionWithChangeActionIndex(
    ValueNotifier<PaintActions> changeActions,
    PainterControllerValue value,
    int index,
    void Function(List<PainterItem> items) updatedList,
    void Function(int index) updateIndex,
  ) {
    _setValues(changeActions, value);

    void undoActions() {
      for (var i = currentIndex; i > index; i--) {
        if (currentActions[i] is ActionAddItem) {
          final item = items
              .where(
                (element) =>
                    element.id == (currentActions[i] as ActionAddItem).item.id,
              )
              .first;
          _removeItemFromList(item.id);
        }
        if (currentActions[i] is ActionPosition) {
          var item = items
              .where(
                (element) =>
                    element.id == (currentActions[i] as ActionPosition).item.id,
              )
              .first;
          item = item.copyWith(
            position: (currentActions[i] as ActionPosition).oldPosition,
          );
          _updateList(item);
        } else if (currentActions[i] is ActionSize) {
          var item = items
              .where(
                (element) =>
                    element.id == (currentActions[i] as ActionSize).item.id,
              )
              .first;
          item = item.copyWith(
            size: (currentActions[i] as ActionSize).oldSize,
            position: (currentActions[i] as ActionSize).oldPosition,
          );

          _updateList(item);
        } else if (currentActions[i] is ActionRotation) {
          var item = items
              .where(
                (element) =>
                    element.id == (currentActions[i] as ActionRotation).item.id,
              )
              .first;
          item = item.copyWith(
            rotation: (currentActions[i] as ActionRotation).oldRotateAngle,
          );
          _updateList(item);
        }
      }
    }

    void redoActions() {
      for (var i = currentIndex + 1; i <= index; i++) {
        if (currentActions[i] is ActionAddItem) {
          final item = currentActions[i] as ActionAddItem;
          _addItem(item);
        }
        if (currentActions[i] is ActionPosition) {
          var item = items
              .where(
                (element) =>
                    element.id == (currentActions[i] as ActionPosition).item.id,
              )
              .first;
          item = item.copyWith(
            position: (currentActions[i] as ActionPosition).newPosition,
          );
          _updateList(item);
        } else if (currentActions[i] is ActionSize) {
          var item = items
              .where(
                (element) =>
                    element.id == (currentActions[i] as ActionSize).item.id,
              )
              .first;
          item = item.copyWith(
            size: (currentActions[i] as ActionSize).newSize,
            position: (currentActions[i] as ActionSize).newPosition,
          );

          _updateList(item);
        } else if (currentActions[i] is ActionRotation) {
          var item = items
              .where(
                (element) =>
                    element.id == (currentActions[i] as ActionRotation).item.id,
              )
              .first;
          item = item.copyWith(
            rotation: (currentActions[i] as ActionRotation).newRotateAngle,
          );
          _updateList(item);
        }
      }
    }

    if (index < currentIndex) {
      undoActions();
    } else {
      redoActions();
    }
    updatedList(items);
    updateIndex(index);
  }

  void _updateList(PainterItem item) {
    final itemIndex = items.indexWhere((element) {
      return element.id == item.id;
    });
    items
      ..removeAt(itemIndex)
      ..insert(itemIndex, item);
  }

  void _addItem(ActionAddItem item) {
    items.insert(item.listIndex, item.item);
  }

  void _removeItemFromList(String itemId) {
    items.removeWhere((element) => element.id == itemId);
  }

  void undo(
    ValueNotifier<PaintActions> changeActions,
    PainterControllerValue value,
    void Function(List<PainterItem> items) updatedList,
    void Function(int index) updateIndex,
  ) {
    _setValues(changeActions, value);
    if (currentIndex < 0) return;
    updateActionWithChangeActionIndex(
      changeActions,
      value,
      currentIndex - 1,
      updatedList,
      updateIndex,
    );
  }

  void redo(
    ValueNotifier<PaintActions> changeActions,
    PainterControllerValue value,
    void Function(List<PainterItem> items) updatedList,
    void Function(int index) updateIndex,
  ) {
    _setValues(changeActions, value);
    if (currentIndex == currentActions.length - 1) return;
    updateActionWithChangeActionIndex(
      changeActions,
      value,
      currentIndex + 1,
      updatedList,
      updateIndex,
    );
  }

  void _setValues(
    ValueNotifier<PaintActions> changeActions,
    PainterControllerValue value,
  ) {
    currentActions = changeActions.value.changeList;
    currentIndex = changeActions.value.index;
    items = value.items.toList();
  }
}
