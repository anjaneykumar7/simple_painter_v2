part of '../painter_widget.dart';

class _DrawingWidget extends StatelessWidget {
  const _DrawingWidget({required this.controller, required this.child});
  final PainterController controller;
  final Widget child;
  @override
  Widget build(BuildContext context) {
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
}
