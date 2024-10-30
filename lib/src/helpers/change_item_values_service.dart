import 'package:flutter_painter/flutter_painter.dart';
import 'package:flutter_painter/src/controllers/items/painter_item.dart';
import 'package:flutter_painter/src/controllers/paint_actions/main/image_actions/image_change_value_action.dart';
import 'package:flutter_painter/src/controllers/paint_actions/main/shape_actions/shape_change_value_action.dart';
import 'package:flutter_painter/src/controllers/paint_actions/paint_action.dart';
import 'package:flutter_painter/src/controllers/paint_actions/text_actions/text_change_value_action.dart';

class ChangeItemValuesService {
  List<PainterItem> items = [];
  void changeItemValues(
    PainterItem item,
    List<PainterItem> itemsList,
    void Function(
      PaintAction action,
      List<PainterItem> items,
      dynamic selectedItem,
    ) updatedValues,
  ) {
    items = itemsList;
    final index = items.indexWhere((element) => element.id == item.id);
    final lastItem = items[index];
    final newItem = item.copyWith(
      size: lastItem.size,
      position: lastItem.position,
      rotation: lastItem.rotation,
    );
    items
      ..removeAt(index)
      ..insert(index, newItem);

    updatedValues(_getAction(newItem, lastItem), items, item);
  }

  PaintAction _getAction(PainterItem item, PainterItem lastItem) {
    if (item is TextItem && lastItem is TextItem) {
      return ActionTextChangeValue(
        currentItem: item,
        lastItem: lastItem,
        timestamp: DateTime.now(),
        actionType: ActionType.changeTextValue,
      );
    } else if (item is ImageItem && lastItem is ImageItem) {
      return ActionImageChangeValue(
        currentItem: item,
        lastItem: lastItem,
        timestamp: DateTime.now(),
        actionType: ActionType.changeImageValue,
      );
    } else {
      return ActionShapeChangeValue(
        currentItem: item as ShapeItem,
        lastItem: lastItem as ShapeItem,
        timestamp: DateTime.now(),
        actionType: ActionType.changeShapeValue,
      );
    }
  }
}
