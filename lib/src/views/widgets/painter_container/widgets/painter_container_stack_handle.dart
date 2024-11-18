part of '../painter_container.dart';

// A widget that handles the resizing and repositioning of a stack container.
// It allows the user to drag the edges (handles) of the container to resize it
// and updates the container's size and position based on user interaction.
class _StackHandle extends StatelessWidget {
  const _StackHandle({
    required this.stackPosition, // Position of the stack within
    // the parent container
    required this.containerSize, // The current size
    // (width and height) of the container
    required this.oldContainerSize, // The previous size of
    // the container before resizing
    required this.handleWidgetHeight, // Height of the resizing handle widgets
    required this.handleWidgetWidth, // Width of the resizing handle widgets
    required this.minimumContainerWidth, // Minimum width of the container
    required this.minimumContainerHeight, // Minimum height of the container
    required this.stackWidth, // The width of the stack (used for positioning)
    required this.stackHeight, // The height of the stack (used for positioning)
    required this.position, // Current position of the stack within the screen
    required this.height, // The total height of the screen or container
    required this.onPanEnd, // Callback when the user finishes dragging
    required this.onPanUpdate, // Callback for updating
    //the container's size or position during dragging
    this.dragHandleColor, // Optional color for the drag handle
    this.onSizeChange, // Optional callback for size change events
  });

  final PositionModel stackPosition; // Position model for the stack
  final SizeModel containerSize; // Current size of the container
  final SizeModel oldContainerSize; // Previous size of the container
  final double handleWidgetHeight; // Height of the resize handle
  final double handleWidgetWidth; // Width of the resize handle
  final double
      minimumContainerWidth; // Minimum allowable width for the container
  final double
      minimumContainerHeight; // Minimum allowable height for the container
  final double stackWidth; // Width of the stack to help position the container
  final double
      stackHeight; // Height of the stack to help position the container
  final PositionModel position; // Position of the stack
  final double height; // Height constraint of the parent container or screen
  final Color? dragHandleColor; // Color for the drag
  //handle, defaults to blue if not provided
  final void Function() onPanEnd; // Function to call when dragging ends
  final void Function(SizeModel containerSize, PositionModel? stackPosition)
      onPanUpdate; // Function to call for updates during dragging

  final void Function(
    PositionModel newPosition, // The new position after resizing or dragging
    SizeModel oldSize, // The old size of the container
    SizeModel newSize, // The new size of the container after resizing
  )? onSizeChange; // Optional callback for when the size changes

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: stackPosition.x, // Position the widget at the specified X position
      top: stackPosition.y, // Position the widget at the specified Y position
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal:
              handleWidgetHeight / 2, // Horizontal padding for handle size
          vertical: handleWidgetWidth / 2, // Vertical padding for handle size
        ),
        child: SizedBox(
          width: containerSize.width +
              handleWidgetHeight, // Width including the handle size
          height: containerSize.height +
              handleWidgetWidth, // Height including the handle size
          child: Stack(
            children: _HandlePosition.values.map((handlePosition) {
              return Align(
                alignment: handlePosition == _HandlePosition.top
                    ? Alignment.topCenter // Align top handle
                    : handlePosition == _HandlePosition.bottom
                        ? Alignment.bottomCenter // Align bottom handle
                        : handlePosition == _HandlePosition.left
                            ? Alignment.centerLeft // Align left handle
                            : handlePosition == _HandlePosition.right
                                ? Alignment.centerRight // Align right handle
                                : Alignment.center, // Align center for
                //the default position
                child: GestureDetector(
                  onPanEnd: (details) =>
                      onPanEnd.call(), // Call onPanEnd when drag ends
                  onPanUpdate: (details) => gestureUpdate(
                    details,
                    handlePosition,
                  ), // Handle updates while dragging
                  child: _HandleWidget(
                    handlePosition: handlePosition, // Position of the handle
                    height: _getHandleWidgetHeight(
                      handlePosition, // Get the height for the handle widget
                      handleWidgetHeight, // Height of the handle widget
                      containerSize, // Current size of the container
                    ),
                    width: _getHandleWidgetWidth(
                      handlePosition, // Get the width for the handle widget
                      handleWidgetWidth, // Width of the handle widget
                      containerSize, // Current size of the container
                    ),
                    backgroundColor: dragHandleColor ??
                        Colors.blue, // Set background color for the handle
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  void gestureUpdate(
    DragUpdateDetails details, // Details of the drag update
    _HandlePosition
        handlePosition, // Position of the current handle being dragged
  ) {
    if (handlePosition == _HandlePosition.left) {
      stackLeftUpdate(details); // Handle left-side drag
    } else if (handlePosition == _HandlePosition.right) {
      stackRightUpdate(details); // Handle right-side drag
    } else if (handlePosition == _HandlePosition.top) {
      stackTopUpdate(details); // Handle top-side drag
    } else if (handlePosition == _HandlePosition.bottom) {
      stackBottomUpdate(details); // Handle bottom-side drag
    }

    // If onSizeChange callback is provided, call it to
    //notify of the size change
    if (onSizeChange != null) {
      onSizeChange?.call(
        PositionModel(
          x: position.x, // Current X position of the container
          y: position.y, // Current Y position of the container
        ),
        SizeModel(
          width: oldContainerSize.width, // Old width before resize
          height: oldContainerSize.height, // Old height before resize
        ),
        SizeModel(
          width: containerSize.width, // New width after resize
          height: containerSize.height, // New height after resize
        ),
      );
    }
  }

  void stackLeftUpdate(DragUpdateDetails details) {
    if (containerSize.width <= minimumContainerWidth && details.delta.dx > 0) {
      // If the container width is smaller than the
      //minimum width and dragged right
      onPanUpdate.call(
        containerSize.copyWith(
          width: minimumContainerWidth, // Set the width to the minimum allowed
        ),
        null,
      );
      return;
    }

    onPanUpdate.call(
      containerSize.copyWith(
        width: containerSize.width -
            details.delta.dx, // Update width based on drag
      ),
      stackPosition.copyWith(
        x: stackPosition.x +
            details.delta.dx, // Update X position based on drag
      ),
    );
  }

  void stackRightUpdate(DragUpdateDetails details) {
    if (containerSize.width <= minimumContainerWidth && details.delta.dx < 0) {
      // If the container width is smaller than
      //the minimum width and dragged left
      onPanUpdate.call(
        containerSize.copyWith(
          width: minimumContainerWidth, // Set the width to the minimum allowed
        ),
        null,
      );
      return;
    }

    onPanUpdate.call(
      containerSize.copyWith(
        width: containerSize.width +
            details.delta.dx, // Update width based on drag
      ),
      null,
    );
  }

  void stackTopUpdate(DragUpdateDetails details) {
    if (containerSize.height <= minimumContainerHeight &&
        details.delta.dy > 0) {
      // If the container height is smaller
      //than the minimum height and dragged up
      onPanUpdate.call(
        containerSize.copyWith(
          height:
              minimumContainerHeight, // Set the height to the minimum allowed
        ),
        null,
      );
      return;
    }

    onPanUpdate.call(
      containerSize.copyWith(
        height: containerSize.height -
            details.delta.dy, // Update height based on drag
      ),
      stackPosition.copyWith(
        y: stackPosition.y +
            details.delta.dy, // Update Y position based on drag
      ),
    );
  }

  void stackBottomUpdate(DragUpdateDetails details) {
    if (containerSize.height <= minimumContainerHeight &&
        details.delta.dy < 0) {
      // If the container height is
      //smaller than the minimum height and dragged down
      onPanUpdate.call(
        containerSize.copyWith(
          height:
              minimumContainerHeight, // Set the height to the minimum allowed
        ),
        null,
      );
      return;
    }

    if (position.y + containerSize.height + details.delta.dy > height) {
      // If the container is dragged to the bottom limit, maintain its height
      onPanUpdate.call(
        containerSize.copyWith(
          height: height - position.y, // Set height to fit the remaining space
        ),
        null,
      );
    } else {
      onPanUpdate.call(
        containerSize.copyWith(
          height: containerSize.height +
              details.delta.dy, // Update height based on drag
        ),
        null,
      );
    }
  }
}
