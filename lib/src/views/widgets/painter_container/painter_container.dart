// ignore_for_file: lines_longer_than_80_chars

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:simple_painter/src/models/position_model.dart';
import 'package:simple_painter/src/models/size_model.dart';
part 'widgets/painter_container_handle_widget.dart';
part 'widgets/painter_container_handle_position_enum.dart';
part 'widgets/painter_container_functions.dart';
part 'widgets/painter_container_stack_handle.dart';
part 'widgets/painter_container_stack_widget.dart';

class PainterContainer extends StatefulWidget {
  const PainterContainer({
    required this.height,
    required this.selectedItem,
    super.key,
    this.dragHandleColor,
    this.onTapItem,
    this.child,
    this.minimumContainerHeight,
    this.minimumContainerWidth,
    this.onPositionChange,
    this.onSizeChange,
    this.onRotateAngleChange,
    this.onRotateAngleChangeEnd,
    this.onPositionChangeEnd,
    this.onSizeChangeEnd,
    this.selectedItemChange,
    this.itemPosition,
    this.itemSize,
    this.enabled,
    this.position,
    this.rotateAngle,
    this.size,
    this.centerChild,
  });
  final double height;
  final Color? dragHandleColor;
  final bool selectedItem;
  final void Function({bool tapItem})? onTapItem;
  final void Function(PositionModel, PositionModel)? onPositionChange;
  final void Function(
    PositionModel newPosition,
    SizeModel oldSize,
    SizeModel newSize,
  )? onSizeChange;
  final void Function(double oldRotateAngle, double newRotateAngle)?
      onRotateAngleChange;
  final void Function(double oldRotateAngle, double newRotateAngle)?
      onRotateAngleChangeEnd;
  final void Function(
    PositionModel oldPosition,
    PositionModel newPosition,
  )? onPositionChangeEnd;
  final void Function(
    PositionModel oldPosition,
    SizeModel oldSize,
    PositionModel newPosition,
    SizeModel newSize,
  )? onSizeChangeEnd;
  final void Function()? selectedItemChange;
  final Widget? child;
  final double? minimumContainerHeight;
  final double? minimumContainerWidth;
  final PositionModel? itemPosition;
  final SizeModel? itemSize;
  final bool? enabled;
  final PositionModel? position;
  final double? rotateAngle;
  final SizeModel? size;
  final bool?
      centerChild; //text widgetı ve diğer widgetlar çağırıldığında ortalamak için kullanılıyor
  @override
  State<PainterContainer> createState() => _PainterContainerState();
}

class _PainterContainerState extends State<PainterContainer> {
  PositionModel position = const PositionModel();
  PositionModel oldPosition = const PositionModel();
  PositionModel stackPosition = const PositionModel();
  SizeModel containerSize = const SizeModel(width: 100, height: 100);
  SizeModel oldContainerSize = const SizeModel(width: 100, height: 100);
  double rotateAngle = 0;
  double oldRotateAngle = 0;
  final handleWidgetWidth = 15.0;
  final handleWidgetHeight = 15.0;
  double minimumContainerWidth = 50;
  double minimumContainerHeight = 50;
  double scaleCurrentHeight = -1;
  double currentRotateAngle = -1;
  bool initializeSize =
      false; //bir defaya mahsus widgetın boyutunu ayarlamak için kullanılıyor, örneğin metin boyutunu measuresize ile alıp set etmek için
  bool changesFromOutside =
      true; //dışarıdan gelen değişikliklerin çalışmasını sağlayan değişken, false olduğu durumda dışarıdan genel değişiklikleri kabul etmiyor
  bool calculatingPositionForSize =
      false; //position değişkeninin widgetın boyutu değiştiğinde çalışması için kullanılıyor, bu değişken olmadığı takdirde widget, size için değişen pozisyonu dışarıdand gelen yeni pozisyon sanıyor ve pozisyonu bozuyor
  bool changedSize =
      false; //bu değişken size değiştiğinde updateEvents fonksiyonunda ki position ve rotateAngle anlık olarak değişmesini engelliyor, çünkü o sırada position ve rotation hesaplanmamış oluyor

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    final stackHeight = screenWidth;
    final stackWidth = screenWidth;
    initializeWidgetSize(stackWidth, stackHeight);
    controlOutsideValues(stackWidth, stackHeight);
    updateEvents();
    return Positioned(
      left: position.x,
      top: position.y,
      child: SizedBox(
        height: stackHeight,
        width: stackWidth,
        child: Transform.rotate(
          angle: rotateAngle,
          child: Opacity(
            opacity: widget.enabled != null && widget.enabled! ? 1 : 0,
            child: Stack(
              children: [
                _StackWidget(
                  position: position,
                  stackHeight: stackHeight,
                  stackWidth: stackWidth,
                  rotateAngle: rotateAngle,
                  handleWidgetHeight: handleWidgetHeight,
                  handleWidgetWidth: handleWidgetWidth,
                  minimumContainerWidth: minimumContainerWidth,
                  minimumContainerHeight: minimumContainerHeight,
                  oldContainerSize: oldContainerSize,
                  containerSize: containerSize,
                  selectedItem: widget.selectedItem,
                  oldPosition: oldPosition,
                  currentRotateAngle: currentRotateAngle,
                  height: widget.height,
                  initializeSize: initializeSize,
                  oldRotateAngle: oldRotateAngle,
                  scaleCurrentHeight: scaleCurrentHeight,
                  stackPosition: stackPosition,
                  centerChild: widget.centerChild,
                  dragHandleColor: widget.dragHandleColor,
                  enabled: widget.enabled,
                  onTap: () {
                    enableItem();
                    if (widget.onTapItem != null) {
                      widget.onTapItem?.call(tapItem: !widget.selectedItem);
                    }
                  },
                  onScaleStart: () {
                    if (!widget.selectedItem) {
                      return;
                    }
                    scaleCurrentHeight = -1;
                  },
                  onScaleEnd: (details) {
                    if (widget.onPositionChange != null) {
                      widget.onPositionChange?.call(
                        PositionModel(x: oldPosition.x, y: oldPosition.y),
                        PositionModel(x: position.x, y: position.y),
                      );
                    }
                    if (widget.onRotateAngleChange != null) {
                      widget.onRotateAngleChange
                          ?.call(oldRotateAngle, rotateAngle);
                    }
                    if (widget.onSizeChange != null) {
                      widget.onSizeChange?.call(
                        PositionModel(x: position.x, y: position.y),
                        SizeModel(
                          width: oldContainerSize.width,
                          height: oldContainerSize.height,
                        ),
                        SizeModel(
                          width: containerSize.width,
                          height: containerSize.height,
                        ),
                      );
                    }
                    currentRotateAngle = rotateAngle;
                    changesFromOutside = true;
                  },

                  /// The reason for defining this function inline is that when defined outside,
                  /// it requires updating the data by providing feedback with `void Function`,
                  /// which causes a delay in Android. As a result, when swiped quickly, the code
                  /// does not work properly, and the scrolling operation lags behind.
                  onScaleUpdate: (details) =>
                      widgetScaleUpdate(details, stackWidth, stackHeight),
                  handlePanEnd: () {
                    calculateSizeAfterChangedSize(
                      stackWidth,
                      stackHeight,
                    );
                    changesFromOutside = true;
                    calculatingPositionForSize = true;
                    changedSize = true;
                  },
                  handlePanUpdate: (newContainerSize, newStackPosition) {
                    changesFromOutside = false;
                    setState(() {
                      containerSize = newContainerSize;
                      if (newStackPosition != null) {
                        stackPosition = newStackPosition;
                      }
                    });
                  },
                  handleSizeChange: (newPosition, oldSize, newSize) {
                    if (widget.onSizeChange != null) {
                      widget.onSizeChange?.call(newPosition, oldSize, newSize);
                    }
                  },
                  pointerCount2Change: (
                    newScaleCurrentHeight,
                    newCurrentRotateAngle,
                    newRotateAngle,
                    newContainerSize,
                  ) {
                    setState(() {
                      if (newScaleCurrentHeight != null) {
                        scaleCurrentHeight = newScaleCurrentHeight;
                      }
                      if (newCurrentRotateAngle != null) {
                        currentRotateAngle = newCurrentRotateAngle;
                      }
                      if (newRotateAngle != null) {
                        rotateAngle = newRotateAngle;
                      }
                      if (newContainerSize != null) {
                        containerSize = newContainerSize;
                      }
                    });
                  },
                  child: widget.child,
                ),
                if (widget.selectedItem)
                  _StackHandle(
                    stackPosition: stackPosition,
                    stackWidth: stackWidth,
                    stackHeight: stackHeight,
                    containerSize: containerSize,
                    minimumContainerHeight: minimumContainerHeight,
                    minimumContainerWidth: minimumContainerWidth,
                    handleWidgetHeight: handleWidgetHeight,
                    handleWidgetWidth: handleWidgetWidth,
                    dragHandleColor: widget.dragHandleColor,
                    oldContainerSize: oldContainerSize,
                    position: position,
                    height: widget.height,
                    onPanEnd: () {
                      calculateSizeAfterChangedSize(
                        stackWidth,
                        stackHeight,
                      );
                      changesFromOutside = true;
                      calculatingPositionForSize = true;
                      changedSize = true;
                    },

                    /// The reason for defining this function inline is that when defined outside,
                    /// it requires updating the data by providing feedback with `void Function`,
                    /// which causes a delay in Android. As a result, when swiped quickly, the code
                    /// does not work properly, and the scrolling operation lags behind.
                    onPanUpdate: handlePanUpdate,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

// Updates the widget's scale, rotation, and position based on user interactions
// This method handles both single-touch and multi-touch gestures.
  void widgetScaleUpdate(
    ScaleUpdateDetails details,
    double stackWidth,
    double stackHeight,
  ) {
    // Handles single-touch gestures for moving the widget
    void pointerCount1() {
      final pos = details.focalPointDelta;
      setState(() {
        final cosAngle = cos(rotateAngle);
        final sinAngle = sin(rotateAngle);

        final deltaX = pos.dx * cosAngle - pos.dy * sinAngle;
        final deltaY = pos.dx * sinAngle + pos.dy * cosAngle;
        position = position.copyWith(
          x: position.x + deltaX,
          y: position.y + deltaY,
        );

        stackPosition = stackPosition.copyWith(
          x: stackWidth / 2 - containerSize.width / 2,
          y: stackHeight / 2 - containerSize.height / 2,
        );
      });
    }

    // Handles multi-touch gestures for scaling and rotating the widget
    void pointerCount2() {
      if (scaleCurrentHeight == -1) {
        scaleCurrentHeight = containerSize.height;
      }
      if (currentRotateAngle == -1) {
        currentRotateAngle = rotateAngle;
      }
      final realScale =
          (scaleCurrentHeight * details.scale) / containerSize.height;
      final realRotateAngle = currentRotateAngle + details.rotation;
      final oldWidth = containerSize.width;
      final oldHeight = containerSize.height;
      setState(() {
        rotateAngle = realRotateAngle; // Set rotation
        if (containerSize.width * realScale < minimumContainerWidth ||
            containerSize.height * realScale < minimumContainerHeight) {
          return;
        } else {
          containerSize = containerSize.copyWith(
            width: containerSize.width * realScale,
            height: containerSize.height * realScale,
          );
        }
        final oldStackXPosition = stackPosition.x;
        final oldStackYPosition = stackPosition.y;
        final newStackXPosition = stackWidth / 2 - containerSize.width / 2;
        final newStackYPosition = stackHeight / 2 - containerSize.height / 2;
        position = position.copyWith(
          x: position.x - (containerSize.width - oldWidth) / 2,
          y: position.y - (containerSize.height - oldHeight) / 2,
        );

        position = position.copyWith(
          x: position.x + oldStackXPosition - newStackXPosition,
          y: position.y + oldStackYPosition - newStackYPosition,
        );

        stackPosition = stackPosition.copyWith(
          x: newStackXPosition,
          y: newStackYPosition,
        );
      });
    }

    enableItem();
    changesFromOutside = false;
    if (details.pointerCount == 1) {
      pointerCount1();
    } else if (details.pointerCount == 2) {
      pointerCount2();
    }
  }

// Handles drag updates for resizing the widget based on the drag position
  void handlePanUpdate(
      DragUpdateDetails details, _HandlePosition handlePosition) {
    changesFromOutside = false;
    setState(() {
      if (handlePosition == _HandlePosition.left) {
        handleLeft(details);
      } else if (handlePosition == _HandlePosition.right) {
        handleRight(details);
      } else if (handlePosition == _HandlePosition.top) {
        handleTop(details);
      } else if (handlePosition == _HandlePosition.bottom) {
        handleBottom(details);
      }
      // Calls an optional callback to notify about size changes
      if (widget.onSizeChange != null) {
        widget.onSizeChange?.call(
          PositionModel(
            x: position.x,
            y: position.y,
          ),
          SizeModel(
            width: oldContainerSize.width,
            height: oldContainerSize.height,
          ),
          SizeModel(
            width: containerSize.width,
            height: containerSize.height,
          ),
        );
      }
    });
  }

// Handles resizing the widget from the bottom handle
  void handleBottom(DragUpdateDetails details) {
    if (containerSize.height <= minimumContainerHeight &&
        details.delta.dy < 0) {
      // Prevents shrinking below the minimum height when dragging down
      containerSize = containerSize.copyWith(
        height: minimumContainerHeight,
      );
      return;
    }
    if (position.y + containerSize.height + details.delta.dy > widget.height) {
      // Prevents resizing beyond the widget's maximum height
      containerSize = containerSize.copyWith(
        height: widget.height - position.y,
      );
    } else {
      containerSize = containerSize.copyWith(
        height: containerSize.height + details.delta.dy,
      );
    }
  }

// Handles resizing the widget from the top handle
  void handleTop(DragUpdateDetails details) {
    if (containerSize.height <= minimumContainerHeight &&
        details.delta.dy > 0) {
      // Prevents shrinking below the minimum height when dragging up
      containerSize = containerSize.copyWith(
        height: minimumContainerHeight,
      );
      return;
    } else {
      containerSize = containerSize.copyWith(
        height: containerSize.height - details.delta.dy,
      );
      stackPosition = stackPosition.copyWith(
        y: stackPosition.y + details.delta.dy,
      );
    }
  }

// Handles resizing the widget from the right handle
  void handleRight(DragUpdateDetails details) {
    if (containerSize.width <= minimumContainerWidth && details.delta.dx < 0) {
      // Prevents shrinking below the minimum width when dragging right
      containerSize = containerSize.copyWith(
        width: minimumContainerWidth,
      );
      return;
    }

    containerSize = containerSize.copyWith(
      width: containerSize.width + details.delta.dx,
    );
  }

// Handles resizing the widget from the left handle
  void handleLeft(DragUpdateDetails details) {
    if (containerSize.width <= minimumContainerWidth && details.delta.dx > 0) {
      // Prevents shrinking below the minimum width when dragging left
      containerSize = containerSize.copyWith(
        width: minimumContainerWidth,
      );
      return;
    }

    containerSize = containerSize.copyWith(
      width: containerSize.width - details.delta.dx,
    );
    stackPosition = stackPosition.copyWith(
      x: stackPosition.x + details.delta.dx,
    );
  }

  // Method to calculate the position and size after changes
// This method adjusts the position of the widget when the stack's size changes.
// It handles both cases where a rotation angle is applied and when it is not.
  void calculateSizeAfterChangedSize(double stackWidth, double stackHeight) {
    setState(() {
      final oldStackXPosition = stackPosition.x;
      final oldStackYPosition = stackPosition.y;
      final newStackXPosition = stackWidth / 2 - containerSize.width / 2;
      final newStackYPosition = stackHeight / 2 - containerSize.height / 2;

      if (rotateAngle != 0) {
        // Use trigonometric transformations when rotateAngle is not 0
        final deltaX = oldStackXPosition - newStackXPosition;
        final deltaY = oldStackYPosition - newStackYPosition;
        final cosAngle = cos(rotateAngle);
        final sinAngle = sin(rotateAngle);

        position = position.copyWith(
          x: position.x + (deltaX * cosAngle - deltaY * sinAngle),
          y: position.y + (deltaX * sinAngle + deltaY * cosAngle),
        );
      } else {
        // Use standard calculations when rotateAngle is 0
        position = position.copyWith(
          x: position.x + (oldStackXPosition - newStackXPosition),
          y: position.y + (oldStackYPosition - newStackYPosition),
        );
      }

      stackPosition = stackPosition.copyWith(
        x: newStackXPosition,
        y: newStackYPosition,
      );
    });
  }

// Initializes the widget size based on the given width and height
// This method sets the initial size and position of the widget based on
// the provided stack dimensions and optional minimum width/height.
  void initializeWidgetSize(double stackWidth, double stackHeight) {
    void setValue() {
      containerSize = containerSize.copyWith(
        height: minimumContainerHeight,
      );
      oldContainerSize = containerSize;
      stackPosition = stackPosition.copyWith(
        x: stackWidth / 2 - containerSize.width / 2,
        y: stackHeight / 2 - containerSize.height / 2,
      );
    }

    if (initializeSize == false &&
        (widget.minimumContainerHeight != null ||
            widget.minimumContainerWidth != null)) {
      minimumContainerHeight =
          widget.minimumContainerHeight ?? minimumContainerHeight;
      minimumContainerWidth =
          widget.minimumContainerWidth ?? minimumContainerWidth;
      setValue();
      initializeSize = true;
    }
  }

  // Controls external changes to position and size
  void controlOutsideValues(double stackWidth, double stackHeight) {
    if (calculatingPositionForSize) {
      calculatingPositionForSize = false;
      return;
    }
    if (widget.size != null &&
        widget.size != containerSize &&
        changesFromOutside) {
      containerSize = widget.size!;
      oldContainerSize = widget.size!;
      calculateSizeAfterChangedSize(stackWidth, stackHeight);
      oldPosition = position;
    }
    if (widget.position != null &&
        widget.position != position &&
        changesFromOutside) {
      position = widget.position!;
      oldPosition = widget.position!;

      stackPosition = stackPosition.copyWith(
        x: stackWidth / 2 - containerSize.width / 2,
        y: stackHeight / 2 - containerSize.height / 2,
      );
    }

    if (widget.rotateAngle != null &&
        widget.rotateAngle != rotateAngle &&
        changesFromOutside) {
      rotateAngle = widget.rotateAngle!;
      oldRotateAngle = widget.rotateAngle!;
    }
  }

  void enableItem() {
    if (widget.selectedItemChange != null) {
      widget.selectedItemChange?.call();
    }
  }

  // Handles updates on position, size, and rotation angle changes
  void updateEvents() {
    if (position != oldPosition && !changedSize) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (widget.onPositionChangeEnd != null && changesFromOutside) {
          widget.onPositionChangeEnd?.call(
            oldPosition,
            position,
          );
          oldPosition = position;
        }
        if (widget.onPositionChange != null) {
          widget.onPositionChange?.call(oldPosition, position);
        }
      });
    }
    if (rotateAngle != oldRotateAngle && !changedSize) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (widget.onRotateAngleChangeEnd != null && changesFromOutside) {
          widget.onRotateAngleChangeEnd?.call(oldRotateAngle, rotateAngle);
          oldRotateAngle = rotateAngle;
        }

        if (widget.onRotateAngleChangeEnd != null) {
          widget.onRotateAngleChange?.call(oldRotateAngle, rotateAngle);
        }
      });
    }
    if (containerSize != oldContainerSize) {
      changedSize = false;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (widget.onSizeChangeEnd != null && changesFromOutside) {
          widget.onSizeChangeEnd
              ?.call(oldPosition, oldContainerSize, position, containerSize);

          oldPosition = position;
          oldContainerSize = containerSize;
        }
        if (widget.onSizeChange != null) {
          widget.onSizeChange?.call(
            position,
            oldContainerSize,
            containerSize,
          );
        }
      });
    }
  }
}
