import 'package:flutter_painter/src/controllers/events/controller_event.dart';
import 'package:flutter_painter/src/controllers/items/painter_item.dart';

class ItemPressEvent extends ControllerEvent {
  const ItemPressEvent({
    required this.item,
    required this.layerIndex,
  });
  final PainterItem item;
  final int layerIndex;
}
