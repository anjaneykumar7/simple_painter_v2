import 'package:flutter_painter/src/controllers/items/painter_item.dart';

class LayerService {
  List<PainterItem> items = [];

  void updateLayerIndex(
      PainterItem item,
      int newIndex,
      List<PainterItem> itemList,
      void Function(List<PainterItem>) changedList) {
    items = itemList;
    final oldIndex = items.indexOf(item);
    items
      ..removeAt(oldIndex)
      ..insert(
          newIndex, item.copyWith(layer: item.layer.copyWith(index: newIndex)));
    changedList(items);
  }
}
