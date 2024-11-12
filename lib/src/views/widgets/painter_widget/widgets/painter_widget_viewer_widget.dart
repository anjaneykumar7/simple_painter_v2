part of '../painter_widget.dart';

class _ViewerWidget extends StatelessWidget {
  const _ViewerWidget({required this.controller});
  final PainterController controller;
  @override
  Widget build(BuildContext context) {
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
                    ? _MainWidget(controller: controller)
                    : _DrawingWidget(
                        controller: controller,
                        child: _MainWidget(controller: controller),
                      ),
              ),
      ),
    );
  }
}
