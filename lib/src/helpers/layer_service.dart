import 'package:flutter_painter/src/controllers/items/painter_item.dart';

class LayerService {
  List<PainterItem> items = [];

  void updateLayerIndex(
    PainterItem item,
    int newIndex,
    List<PainterItem> itemList,
    void Function(List<PainterItem>) changedList,
  ) {
    items = itemList;
    final oldIndex = items.indexOf(item);
    items.removeAt(oldIndex);

    // Update the index of the item being moved
    final updatedItem =
        item.copyWith(layer: item.layer.copyWith(index: newIndex));
    final validIndex = newIndex.clamp(0, items.length);
    items.insert(validIndex, updatedItem);

    // Adjust the index of items between oldIndex and newIndex
    if (oldIndex < newIndex) {
      for (var i = oldIndex; i < newIndex; i++) {
        items[i] = items[i].copyWith(layer: items[i].layer.copyWith(index: i));
      }
    } else {
      for (var i = newIndex + 1; i <= oldIndex; i++) {
        items[i] = items[i].copyWith(layer: items[i].layer.copyWith(index: i));
      }
    }

    changedList(items);
  }
}
