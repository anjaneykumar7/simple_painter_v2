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
        child: CustomPaint(
          painter: PainterCustomPaint(
            color: Colors.blue,
            isErasing: false,
            paths: controller.value.paintPaths.toList(),
            points: controller.value.currentPaintPath.toList(),
            backgroundImage: controller.background.image,
          ),
          child: Stack(
            children: controller.value.items
                .map((item) => _ItemWidget(item: item, controller: controller))
                .toList()
                .reversed
                .toList(),
          ),
        ),
      ),
    );
  }
}
