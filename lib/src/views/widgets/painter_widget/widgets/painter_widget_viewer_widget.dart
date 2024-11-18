part of '../painter_widget.dart';

// A StatelessWidget that serves as the viewer for
//the painting or drawing, allowing interactive viewing, zooming, and panning.
class _ViewerWidget extends StatelessWidget {
  // Constructor for the _ViewerWidget, which
  //requires a PainterController instance.
  const _ViewerWidget({required this.controller});

  // The PainterController that controls the
  //background, drawing, and erasing logic.
  final PainterController controller;

  // Builds the widget tree for displaying the
  //viewer with interactive capabilities.
  @override
  Widget build(BuildContext context) {
    // The InteractiveViewer widget allows the user to zoom and pan the content.
    return InteractiveViewer(
      boundaryMargin: const EdgeInsets.all(
        20,
      ), // Adds margin around the boundary of the interactive area.
      minScale: 0.1, // The minimum zoom scale allowed.
      maxScale: 10, // The maximum zoom scale allowed.
      child: Center(
        child: (controller.background.width == 0 ||
                controller.background.height == 0)
            // If the background has no width or height
            //(invalid background), display nothing.
            ? null
            : AspectRatio(
                aspectRatio: controller.background.width /
                    controller.background.height, // Ensures the child maintains
                //the correct aspect ratio of the background.
                child: (!(controller.isDrawing || controller.isErasing))
                    // If not in drawing or erasing
                    //mode, display the main widget.
                    ? _MainWidget(controller: controller)
                    : _DrawingWidget(
                        controller: controller,
                        child: _MainWidget(
                          controller: controller,
                        ), // Wrap the _MainWidget inside
                        // the _DrawingWidget while drawing or erasing.
                      ),
              ),
      ),
    );
  }
}
