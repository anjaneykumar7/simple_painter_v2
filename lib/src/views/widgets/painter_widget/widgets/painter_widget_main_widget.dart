part of '../painter_widget.dart';

class _MainWidget extends StatelessWidget {
  const _MainWidget({required this.controller});
  final PainterController controller;
  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      key: controller.repaintBoundaryKey,
      child: GestureDetector(
        onTap: controller.clearSelectedItem,
        child: _buildMainWidget(),
      ),
    );
  }

  Widget _buildMainWidget() {
    if (controller.background.image != null) {
      if (controller.cacheBackgroundImage != null) {
        return customPaint(backgroundImage: controller.cacheBackgroundImage);
      }
      return FutureBuilder<ui.Image?>(
        future: uint8ListToUiImage(controller.background.image!),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            controller.cacheBackgroundImage = snapshot.data;
            return customPaint(backgroundImage: snapshot.data);
          }
          return customPaint();
        },
      );
    }
    return customPaint();
  }

  Widget customPaint({ui.Image? backgroundImage}) {
    return CustomPaint(
      painter: PainterCustomPaint(
        isErasing: false,
        paths: controller.value.paintPaths.toList(),
        points: controller.value.currentPaintPath.toList(),
        backgroundImage: backgroundImage,
      ),
      child: Stack(
        children: controller.value.items
            .map((item) => _ItemWidget(item: item, controller: controller))
            .toList()
            .reversed
            .toList(),
      ),
    );
  }

  Future<ui.Image?> uint8ListToUiImage(Uint8List uint8List) async {
    try {
      final completer = Completer<ui.Image>();
      ui.decodeImageFromList(uint8List, completer.complete);
      return completer.future;
    } catch (e) {
      return null;
    }
  }
}
