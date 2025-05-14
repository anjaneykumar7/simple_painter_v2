part of '../actions_service.dart';

extension ActionsServiceItem on ActionsService {
  void _addItem(PainterItem item, int index) {
    //Insert item at the specified index.
    items.insert(index, item);
    _checkLayerIndex(index);
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

  void _actionBackgroundImageChange(
    ActionChangeBackgroundImage item,
    bool isRedo,
  ) {
    // If it's a redo, update the background image with the new value.
    if (isRedo) {
      backgroundImage = item.newImage;
    } else {
      // If it's an undo, revert to the last background image value.
      backgroundImage = item.oldImage;
    }
  }

  void _actionImportPainter(
    ActionImportPainter item,
    bool isRedo,
  ) {
    if (isRedo) {
      // Set the values before performing any action.
      _setValues(
        item.newSnapshot.paintPaths,
        PainterControllerValue(
          settings: item.newSnapshot.settings,
          paintPaths: item.newSnapshot.paintPaths,
          items: item.newSnapshot.items,
          brushSize: item.newSnapshot.brushSize,
          eraseSize: item.newSnapshot.eraseSize,
          brushColor: item.newSnapshot.brushColor,
        ),
        item.newSnapshot.backgroundImage,
        itemsValue: item.newSnapshot.items,
      );
    } else {
      _setValues(
        item.oldSnapshot.paintPaths,
        PainterControllerValue(
          settings: item.oldSnapshot.settings,
          paintPaths: item.oldSnapshot.paintPaths,
          items: item.oldSnapshot.items,
          brushSize: item.oldSnapshot.brushSize,
          eraseSize: item.oldSnapshot.eraseSize,
          brushColor: item.oldSnapshot.brushColor,
        ),
        item.oldSnapshot.backgroundImage,
        itemsValue: item.oldSnapshot.items,
      );
    }
  }

  // Helper function for setting values for state updates.
  void _setValues(
    List<List<DrawModel?>> paintPath,
    PainterControllerValue value,
    Uint8List? backgroundImageValue, {
    ValueNotifier<PaintActions>? changeActions,
    List<PainterItem>? itemsValue,
  }) {
    // Update the current action values based on the changeActions object.
    if (changeActions != null) {
      currentActions = changeActions.value.changeList;
      currentIndex = changeActions.value.index;
    }
    currentPaintPath = paintPath;
    backgroundImage = backgroundImageValue;
    items = itemsValue ?? value.items.toList();
  }
}
