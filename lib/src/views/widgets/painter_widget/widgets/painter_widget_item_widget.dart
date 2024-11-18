part of '../painter_widget.dart';

class _ItemWidget extends StatelessWidget {
  const _ItemWidget({required this.item, required this.controller});
  final PainterItem item;
  final PainterController controller;

  @override
  Widget build(BuildContext context) {
    // Check if the item is a TextItem
    if (item is TextItem) {
      return TextItemWidget(
        item: item as TextItem,
        height: controller.background.height,
        painterController: controller,
        onPositionChange: (position) {
          // When the position or size changes, the old item comes back.
          // To prevent an error when the index is not
          //found, we search for the item
          // through its size and get the index based on it.
          final newItem = controller.value.items.firstWhere(
            (element) => element.id == item.id,
          );
          final itemIndex = controller.value.items.indexOf(newItem);
          controller.setItemPosition(itemIndex, position);
        },
        onRotationChange: (rotation) {
          // When the position or size changes, the old item comes back.
          // To prevent an error when the index is not
          //found, we search for the item
          // through its size and get the index based on it.
          final newItem = controller.value.items.firstWhere(
            (element) => element.id == item.id,
          );
          final itemIndex = controller.value.items.indexOf(newItem);
          controller.setItemRotation(itemIndex, rotation);
        },
        onSizeChange: (position, size) {
          // When the position or size changes, the old item comes back.
          // To prevent an error when the index is not
          //found, we search for the item
          // through its size and get the index based on it.
          final newItem = controller.value.items.firstWhere(
            (element) => element.id == item.id,
            orElse: () => item,
          );
          final itemIndex = controller.value.items.indexOf(newItem);
          controller
            ..setItemSize(itemIndex, size)
            ..setItemPosition(itemIndex, position);
        },
        onTapItem: () => controller.triggerEvent(
          ItemPressEvent(
            item: item,
            layerIndex: controller.getLayerIndex(item),
          ),
        ),
      );
    }
    // Check if the item is an ImageItem
    else if (item is ImageItem) {
      return ImageItemWidget(
        item: item as ImageItem,
        height: controller.background.height,
        painterController: controller,
        onPositionChange: (position) {
          // When the position or size changes, the old item comes back.
          // To prevent an error when the index is
          //not found, we search for the item
          // through its size and get the index based on it.
          final newItem = controller.value.items.firstWhere(
            (element) => element.id == item.id,
          );
          final itemIndex = controller.value.items.indexOf(newItem);
          controller.setItemPosition(itemIndex, position);
        },
        onRotationChange: (rotation) {
          // When the position or size changes, the old item comes back.
          // To prevent an error when the index is not
          //found, we search for the item
          // through its size and get the index based on it.
          final newItem = controller.value.items.firstWhere(
            (element) => element.id == item.id,
          );
          final itemIndex = controller.value.items.indexOf(newItem);
          controller.setItemRotation(itemIndex, rotation);
        },
        onSizeChange: (position, size) {
          // When the position or size changes, the old item comes back.
          // To prevent an error when the index is
          //not found, we search for the item
          // through its size and get the index based on it.
          final newItem = controller.value.items.firstWhere(
            (element) => element.id == item.id,
            orElse: () => item,
          );
          final itemIndex = controller.value.items.indexOf(newItem);

          controller
            ..setItemSize(itemIndex, size)
            ..setItemPosition(itemIndex, position);
        },
        onTapItem: () => controller.triggerEvent(
          ItemPressEvent(
            item: item,
            layerIndex: controller.getLayerIndex(item),
          ),
        ),
      );
    }
    // Check if the item is a ShapeItem
    else if (item is ShapeItem) {
      return ShapeItemWidget(
        item: item as ShapeItem,
        height: controller.background.height,
        painterController: controller,
        onPositionChange: (position) {
          // When the position or size changes, the old item comes back.
          // To prevent an error when the index is not
          //found, we search for the item
          // through its size and get the index based on it.
          final newItem = controller.value.items.firstWhere(
            (element) => element.id == item.id,
          );
          final itemIndex = controller.value.items.indexOf(newItem);
          controller.setItemPosition(itemIndex, position);
        },
        onRotationChange: (rotation) {
          // When the position or size changes, the old item comes back.
          // To prevent an error when the index
          //is not found, we search for the item
          // through its size and get the index based on it.
          final newItem = controller.value.items.firstWhere(
            (element) => element.id == item.id,
          );
          final itemIndex = controller.value.items.indexOf(newItem);
          controller.setItemRotation(itemIndex, rotation);
        },
        onSizeChange: (position, size) {
          // When the position or size changes, the old item comes back.
          // To prevent an error when the index
          //is not found, we search for the item
          // through its size and get the index based on it.
          final newItem = controller.value.items.firstWhere(
            (element) => element.id == item.id,
            orElse: () => item,
          );
          final itemIndex = controller.value.items.indexOf(newItem);
          controller
            ..setItemSize(itemIndex, size)
            ..setItemPosition(itemIndex, position);
        },
        onTapItem: () => controller.triggerEvent(
          ItemPressEvent(
            item: item,
            layerIndex: controller.getLayerIndex(item),
          ),
        ),
      );
    }
    // If the item type is not recognized, return an empty container
    else {
      return Container();
    }
  }
}
