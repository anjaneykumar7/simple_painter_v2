// ignore_for_file: unused_element

part of '../painter_container.dart';

// This class defines a widget that can be positioned
//and scaled interactively within a stack.
// It also handles user interactions like tapping, scaling,
//and dragging, and adjusts the size and position of the widget accordingly.
class _StackWidget extends StatelessWidget {
  const _StackWidget({
    required this.oldPosition,
    required this.position,
    required this.stackHeight,
    required this.stackWidth,
    required this.rotateAngle,
    required this.oldRotateAngle,
    required this.handleWidgetHeight,
    required this.handleWidgetWidth,
    required this.minimumContainerWidth,
    required this.minimumContainerHeight,
    required this.stackPosition,
    required this.onTap,
    required this.onScaleStart,
    required this.onScaleEnd,
    required this.containerSize,
    required this.oldContainerSize,
    required this.scaleCurrentHeight,
    required this.currentRotateAngle,
    required this.onScaleUpdate,
    required this.initializeSize,
    required this.height,
    required this.handlePanEnd,
    required this.handlePanUpdate,
    required this.handleSizeChange,
    required this.selectedItem,
    required this.pointerCount2Change,
    this.child,
    this.enabled,
    this.centerChild,
    this.dragHandleColor,
  });

  // These variables hold the current and
  //previous positions and sizes of the widget.
  final PositionModel stackPosition;
  final PositionModel oldPosition;
  final PositionModel position;
  final double stackHeight;
  final double stackWidth;
  final double rotateAngle;
  final double oldRotateAngle;
  final double handleWidgetHeight;
  final double handleWidgetWidth;
  final double minimumContainerWidth;
  final double minimumContainerHeight;
  final double height;
  final bool? enabled;
  final bool selectedItem;
  final SizeModel containerSize;
  final SizeModel oldContainerSize;
  final double scaleCurrentHeight;
  final double currentRotateAngle;
  final bool initializeSize;
  final bool? centerChild;
  final Widget? child;

  // Callbacks and event handlers for user interactions with the widget.
  final void Function(
    double? scaleCurrentHeight,
    double? currentRotateAngle,
    double? rotateAngle,
    SizeModel? containerSize,
  ) pointerCount2Change;
  final void Function() onTap;
  final void Function() onScaleStart;
  final void Function(ScaleEndDetails) onScaleEnd;
  final void Function(ScaleUpdateDetails details) onScaleUpdate;
  final Color? dragHandleColor;
  final void Function() handlePanEnd;
  final void Function(SizeModel containerSize, PositionModel? stackPosition)
      handlePanUpdate;
  final void Function(PositionModel, SizeModel, SizeModel) handleSizeChange;

  // The build method positions the widget
  //within a stack, handling interactions like tapping and scaling.
  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: stackPosition.x, // Position the widget on the X axis
      top: stackPosition.y, // Position the widget on the Y axis
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: handleWidgetHeight, // Padding for horizontal resizing
          vertical: handleWidgetWidth, // Padding for vertical resizing
        ),
        child: GestureDetector(
          onTap: onTap, // Handle tap events
          onScaleStart: (details) => onScaleStart.call(), // Handle scale start
          onScaleEnd: onScaleEnd.call, // Handle scale end
          onScaleUpdate: onScaleUpdate.call,
          child: Container(
            width: containerSize.width, // Set the container width
            height: containerSize.height, // Set the container height
            decoration: BoxDecoration(
              color: Colors.transparent, // Transparent background
              border: Border.all(
                color: selectedItem
                    ? dragHandleColor ??
                        Colors.blue // Border color when selected
                    : Colors.transparent, // No border when not selected
              ),
            ),
            child: initializeSize // If size initialization is needed
                ? (centerChild != null &&
                        centerChild!) // If the widget should be centered
                    ? Center(child: child) // Center the child widget
                    : child
                : Align(child: child), // Align the child widget otherwise
          ),
        ),
      ),
    );
  }

  /* // Handles the scaling update when there
  //are two pointers interacting with the widget.
  void gestureScaleUpdatePointer2(ScaleUpdateDetails details) {
    if (scaleCurrentHeight == -1) {
      pointerCount2Change.call(
        containerSize.height,
        null,
        null,
        null,
      );
      return;
    }
    if (currentRotateAngle == -1) {
      pointerCount2Change.call(
        null,
        rotateAngle,
        null,
        null,
      );
      return;
    }

    // Calculate the real scaling factor based on the pointer scale
    final realScale =
        (scaleCurrentHeight * (details.scale)) / containerSize.height;

    final realRotateAngle =
        currentRotateAngle + details.rotation; // Calculate new rotation angle
    final oldWidth = containerSize.width; // Store the old width
    final oldHeight = containerSize.height; // Store the old height

    pointerCount2Change.call(
      null,
      null,
      realRotateAngle,
      null,
    );
    // Prevent resizing if it goes below the minimum dimensions
    if (containerSize.width * realScale < minimumContainerWidth ||
        containerSize.height * realScale < minimumContainerHeight) {
      return;
    } else {
      pointerCount2Change.call(
        null,
        null,
        null,
        containerSize.copyWith(
          width: containerSize.width * realScale,
          height: containerSize.height * realScale,
        ),
      );
    }
    // Update the widget's stack position based on the new size
    final newStackXPosition = stackWidth / 2 - (containerSize.width / 2);
    final newStackYPosition = stackHeight / 2 - (containerSize.height / 2);

    // Call the scale update callback with new position and size
    onScaleUpdate.call(
      position.copyWith(
        x: position.x - (containerSize.width - oldWidth) / 2,
        y: position.y - (containerSize.height - oldHeight) / 2,
      ),
      stackPosition.copyWith(
        x: newStackXPosition,
        y: newStackYPosition,
      ),
    );
  }

  // Handles the scaling update when there
  //is a single pointer interacting with the widget.
  void gestureScaleUpdatePointer1(ScaleUpdateDetails details) {
    final pos = details.focalPointDelta; // Get the movement of the pointer
    final cosAngle = cos(rotateAngle); // Calculate cosine of the rotation angle
    final sinAngle = sin(rotateAngle); // Calculate sine of the rotation angle

    // Calculate the change in position based on the rotation angle
    final deltaX = pos.dx * cosAngle - pos.dy * sinAngle;
    final deltaY = pos.dx * sinAngle + pos.dy * cosAngle;

    // Call the scale update callback with the new position
    onScaleUpdate.call(
      position.copyWith(
        x: position.x + deltaX,
        y: position.y + deltaY,
      ),
      stackPosition.copyWith(
        x: stackWidth / 2 - containerSize.width / 2,
        y: stackHeight / 2 - containerSize.height / 2,
      ),
    );
  }*/
}
