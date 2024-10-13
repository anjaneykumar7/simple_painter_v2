import 'package:flutter/material.dart';
import 'package:flutter_painter/flutter_painter.dart';
import 'package:flutter_painter/src/controllers/custom_paint.dart';
import 'package:flutter_painter/src/controllers/items/painter_item.dart';
import 'package:flutter_painter/src/views/widgets/items/image_item_widget.dart';
import 'package:flutter_painter/src/views/widgets/items/text_item_widget.dart';

class PainterWidget extends StatelessWidget {
  const PainterWidget({required this.controller, super.key});
  final PainterController controller;
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<PainterControllerValue>(
      valueListenable: controller,
      builder: (context, value, child) {
        return viewerWidget(controller);
      },
    );
  }

  Widget viewerWidget(PainterController controller) {
    return InteractiveViewer(
      boundaryMargin: const EdgeInsets.all(20),
      minScale: 0.1,
      maxScale: 10,
      child: Center(
        child: (controller.background.width == 0 ||
                controller.background.height == 0)
            ? null
            : AspectRatio(
                aspectRatio:
                    controller.background.width / controller.background.height,
                child: (!(controller.isDrawing || controller.isErasing))
                    ? mainBody(controller)
                    : drawingWidget(mainBody(controller)),
              ),
      ),
    );
  }

  Widget drawingWidget(Widget child) {
    return GestureDetector(
      onPanUpdate: (details) {
        if (controller.isDrawing || controller.isErasing) {
          controller.addPaintPoint(details.localPosition);
        }
      },
      onPanEnd: (details) {
        if (controller.isDrawing || controller.isErasing) {
          controller.endPath();
        }
      },
      child: child,
    );
  }

  Widget mainBody(PainterController controller) {
    return RepaintBoundary(
      key: controller.repaintBoundaryKey,
      child: GestureDetector(
        onTap: () {
          controller.value.selectedItem = null;
          controller.value = controller.value.copyWith();
        },
        child: CustomPaint(
          painter: PainterCustomPaint(
            color: Colors.blue,
            isErasing: false,
            paths: controller.value.paintPaths.toList(),
            points: controller.value.currentPaintPath.toList(),
            backgroundImage: controller.background.image,
          ),
          child: Stack(
            children: controller.value.items.map(getItemWidget).toList(),
          ),
        ),
      ),
    );
  }

  Widget getItemWidget(
    PainterItem item,
  ) {
    if (item is TextItem) {
      return TextItemWidget(
        item: item,
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
      );
    } else if (item is ImageItem) {
      return ImageItemWidget(
        item: item,
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
      );
    } else {
      return Container();
    }
  }
}
