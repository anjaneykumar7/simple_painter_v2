part of '../painter_widget.dart';

class _ItemWidget extends StatelessWidget {
  const _ItemWidget({required this.item, required this.controller});
  final PainterItem item;
  final PainterController controller;
  @override
  Widget build(BuildContext context) {
    if (item is TextItem) {
      return TextItemWidget(
        item: item as TextItem,
        height: controller.background.height,
        painterController: controller,
        onPositionChange: (position) {
          final newItem = controller.value.items.firstWhere(
            //Position veya size değiştiğinde eski item geliyor,
            //bundan dolayı da indexi bulamayıp hata veriyor. Hata vermemesi
            //için tekrardan size üzerinden itemi
            //bulup onun üzeirinden indeks alıyorum.
            (element) => element.id == item.id,
          );
          final itemIndex = controller.value.items.indexOf(newItem);
          controller.setItemPosition(itemIndex, position);
        },
        onRotationChange: (rotation) {
          final newItem = controller.value.items.firstWhere(
            //Position veya size değiştiğinde eski item geliyor,
            //bundan dolayı da indexi bulamayıp hata veriyor. Hata vermemesi
            //için tekrardan size üzerinden itemi
            //bulup onun üzeirinden indeks alıyorum.
            (element) => element.id == item.id,
          );
          final itemIndex = controller.value.items.indexOf(newItem);
          controller.setItemRotation(itemIndex, rotation);
        },
        onSizeChange: (position, size) {
          final newItem = controller.value.items.firstWhere(
            //Position veya size değiştiğinde eski item geliyor,
            //bundan dolayı da indexi bulamayıp hata veriyor. Hata vermemesi
            //için tekrardan size üzerinden itemi
            //bulup onun üzeirinden indeks alıyorum.
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
    } else if (item is ImageItem) {
      return ImageItemWidget(
        item: item as ImageItem,
        height: controller.background.height,
        painterController: controller,
        onPositionChange: (position) {
          final newItem = controller.value.items.firstWhere(
            //Position veya size değiştiğinde eski item geliyor,
            //bundan dolayı da indexi bulamayıp hata veriyor. Hata vermemesi
            //için tekrardan size üzerinden itemi
            //bulup onun üzeirinden indeks alıyorum.
            (element) => element.id == item.id,
          );
          final itemIndex = controller.value.items.indexOf(newItem);
          controller.setItemPosition(itemIndex, position);
        },
        onRotationChange: (rotation) {
          final newItem = controller.value.items.firstWhere(
            //Position veya size değiştiğinde eski item geliyor,
            //bundan dolayı da indexi bulamayıp hata veriyor. Hata vermemesi
            //için tekrardan size üzerinden itemi
            //bulup onun üzeirinden indeks alıyorum.
            (element) => element.id == item.id,
          );
          final itemIndex = controller.value.items.indexOf(newItem);
          controller.setItemRotation(itemIndex, rotation);
        },
        onSizeChange: (position, size) {
          final newItem = controller.value.items.firstWhere(
            //Position veya size değiştiğinde eski item geliyor,
            //bundan dolayı da indexi bulamayıp hata veriyor. Hata vermemesi
            //için tekrardan size üzerinden itemi
            //bulup onun üzeirinden indeks alıyorum.
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
    } else if (item is ShapeItem) {
      return ShapeItemWidget(
        item: item as ShapeItem,
        height: controller.background.height,
        painterController: controller,
        onPositionChange: (position) {
          final newItem = controller.value.items.firstWhere(
            //Position veya size değiştiğinde eski item geliyor,
            //bundan dolayı da indexi bulamayıp hata veriyor. Hata vermemesi
            //için tekrardan size üzerinden itemi
            //bulup onun üzeirinden indeks alıyorum.
            (element) => element.id == item.id,
          );
          final itemIndex = controller.value.items.indexOf(newItem);
          controller.setItemPosition(itemIndex, position);
        },
        onRotationChange: (rotation) {
          final newItem = controller.value.items.firstWhere(
            //Position veya size değiştiğinde eski item geliyor,
            //bundan dolayı da indexi bulamayıp hata veriyor. Hata vermemesi
            //için tekrardan size üzerinden itemi
            //bulup onun üzeirinden indeks alıyorum.
            (element) => element.id == item.id,
          );
          final itemIndex = controller.value.items.indexOf(newItem);
          controller.setItemRotation(itemIndex, rotation);
        },
        onSizeChange: (position, size) {
          final newItem = controller.value.items.firstWhere(
            //Position veya size değiştiğinde eski item geliyor,
            //bundan dolayı da indexi bulamayıp hata veriyor. Hata vermemesi
            //için tekrardan size üzerinden itemi
            //bulup onun üzeirinden indeks alıyorum.
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
    } else {
      return Container();
    }
  }
}
