// ignore_for_file: lines_longer_than_80_chars

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_painter/src/models/position_model.dart';
import 'package:flutter_painter/src/models/size_model.dart';

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
    this.onPositionChangeEnd,
    this.onSizeChangeEnd,
    this.itemPosition,
    this.itemSize,
    this.enabled,
    this.position,
    this.size,
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
  final void Function(
    PositionModel oldPosition,
    PositionModel newPosition,
    double oldRotateAngle,
    double newRotateAngle,
  )? onPositionChangeEnd;
  final void Function(
    PositionModel oldPosition,
    SizeModel oldSize,
    PositionModel newPosition,
    SizeModel newSize,
  )? onSizeChangeEnd;
  final Widget? child;
  final double? minimumContainerHeight;
  final double? minimumContainerWidth;
  final PositionModel? itemPosition;
  final SizeModel? itemSize;
  final bool? enabled;
  final PositionModel? position;
  final SizeModel? size;
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
  double currentRotateAngel = -1;
  bool initializeSize = false;
  bool changesFromOutside = false;
  bool calculatingPositionForSize = false;
  bool changedSize = false;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    final stackHeight = widget.height / 2;
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
                Positioned(
                  left: stackPosition.x,
                  top: stackPosition.y,
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: handleWidgetHeight,
                      vertical: handleWidgetWidth,
                    ),
                    child: GestureDetector(
                      onTap: () {
                        if (widget.onTapItem != null) {
                          widget.onTapItem?.call(tapItem: !widget.selectedItem);
                        }
                      },
                      onScaleStart: (details) {
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
                        currentRotateAngel = rotateAngle;
                        changesFromOutside = true;
                      },
                      onScaleUpdate: (details) {
                        changesFromOutside = false;
                        if (details.pointerCount == 1) {
                          final pos = details.focalPointDelta;
                          setState(() {
                            final cosAngle = cos(rotateAngle);
                            final sinAngle = sin(rotateAngle);

                            final deltaX =
                                pos.dx * cosAngle - pos.dy * sinAngle;
                            final deltaY =
                                pos.dx * sinAngle + pos.dy * cosAngle;
                            position = position.copyWith(
                              x: position.x + deltaX,
                              y: position.y + deltaY,
                            );

                            stackPosition = stackPosition.copyWith(
                              x: stackWidth / 2 - containerSize.width / 2,
                              y: stackHeight / 2 - containerSize.height / 2,
                            );
                          });
                        } else if (details.pointerCount == 2) {
                          if (scaleCurrentHeight == -1) {
                            scaleCurrentHeight = containerSize.height;
                          }
                          if (currentRotateAngel == -1) {
                            currentRotateAngel = rotateAngle;
                          }
                          final realScale =
                              (scaleCurrentHeight * details.scale) /
                                  containerSize.height;
                          final realRotateAngle =
                              currentRotateAngel + details.rotation;
                          final oldWidth = containerSize.width;
                          final oldHeight = containerSize.height;
                          setState(() {
                            rotateAngle = realRotateAngle; // set rotation
                            if (containerSize.width * realScale <
                                    minimumContainerWidth ||
                                containerSize.height * realScale <
                                    minimumContainerHeight) {
                              return;
                            } else {
                              containerSize = containerSize.copyWith(
                                width: containerSize.width * realScale,
                                height: containerSize.height * realScale,
                              );
                            }
                            final oldStackXPosition = stackPosition.x;
                            final oldStackYPosition = stackPosition.y;
                            final newStackXPosition =
                                stackWidth / 2 - containerSize.width / 2;
                            final newStackYPosition =
                                stackHeight / 2 - containerSize.height / 2;
                            position = position.copyWith(
                              x: position.x -
                                  (containerSize.width - oldWidth) / 2,
                              y: position.y -
                                  (containerSize.height - oldHeight) / 2,
                            );

                            position = position.copyWith(
                              x: position.x +
                                  oldStackXPosition -
                                  newStackXPosition,
                              y: position.y +
                                  oldStackYPosition -
                                  newStackYPosition,
                            );

                            stackPosition = stackPosition.copyWith(
                              x: newStackXPosition,
                              y: newStackYPosition,
                            );
                          });
                        }
                      },
                      child: Container(
                        width: containerSize.width,
                        height: containerSize.height,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: widget.selectedItem
                                ? widget.dragHandleColor ?? Colors.blue
                                : Colors.transparent,
                          ),
                        ),
                        child: Center(child: widget.child),
                      ),
                    ),
                  ),
                ),
                if (widget.selectedItem)
                  Positioned(
                    left: stackPosition.x,
                    top: stackPosition.y,
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: handleWidgetHeight / 2,
                        vertical: handleWidgetWidth / 2,
                      ),
                      child: SizedBox(
                        width: containerSize.width + handleWidgetHeight,
                        height: containerSize.height + handleWidgetWidth,
                        child: Stack(
                          children:
                              _HandlePosition.values.map((handlePosition) {
                            return Align(
                              alignment: handlePosition == _HandlePosition.top
                                  ? Alignment.topCenter
                                  : handlePosition == _HandlePosition.bottom
                                      ? Alignment.bottomCenter
                                      : handlePosition == _HandlePosition.left
                                          ? Alignment.centerLeft
                                          : handlePosition ==
                                                  _HandlePosition.right
                                              ? Alignment.centerRight
                                              : Alignment.center,
                              child: GestureDetector(
                                onPanEnd: (details) {
                                  calculateSizeAfterChangedSize(
                                    stackWidth,
                                    stackHeight,
                                  );
                                  changesFromOutside = true;
                                  calculatingPositionForSize = true;
                                  changedSize = true;
                                },
                                onPanUpdate: (details) {
                                  changesFromOutside = false;
                                  // endSizeControl = true;
                                  setState(() {
                                    if (handlePosition ==
                                        _HandlePosition.left) {
                                      if (containerSize.width <=
                                              minimumContainerWidth &&
                                          details.delta.dx > 0) {
                                        //container genişliği minimum genişlikten küçükse ve sola doğru kaydırma yapılıyorsa

                                        containerSize = containerSize.copyWith(
                                          width: minimumContainerWidth,
                                        );
                                        return;
                                      }

                                      containerSize = containerSize.copyWith(
                                        width: containerSize.width -
                                            details.delta.dx,
                                      );

                                      stackPosition = stackPosition.copyWith(
                                        x: stackPosition.x + details.delta.dx,
                                      );
                                    } else if (handlePosition ==
                                        _HandlePosition.right) {
                                      if (containerSize.width <=
                                              minimumContainerWidth &&
                                          details.delta.dx < 0) {
                                        //container genişliği minimum genişlikten küçükse ve sağa doğru kaydırma yapılıyorsa

                                        containerSize = containerSize.copyWith(
                                          width: minimumContainerWidth,
                                        );
                                        return;
                                      }

                                      containerSize = containerSize.copyWith(
                                        width: containerSize.width +
                                            details.delta.dx,
                                      );
                                    } else if (handlePosition ==
                                        _HandlePosition.top) {
                                      if (containerSize.height <=
                                              minimumContainerHeight &&
                                          details.delta.dy > 0) {
                                        //container yüksekliği minimum yükseklikten küçükse ve yukarı doğru kaydırma yapılıyorsa

                                        containerSize = containerSize.copyWith(
                                          height: minimumContainerHeight,
                                        );
                                        return;
                                      } else {
                                        containerSize = containerSize.copyWith(
                                          height: containerSize.height -
                                              details.delta.dy,
                                        );
                                        stackPosition = stackPosition.copyWith(
                                          y: stackPosition.y + details.delta.dy,
                                        );
                                      }
                                    } else if (handlePosition ==
                                        _HandlePosition.bottom) {
                                      if (containerSize.height <=
                                              minimumContainerHeight &&
                                          details.delta.dy < 0) {
                                        //container yüksekliği minimum yükseklikten küçükse ve aşağı doğru kaydırma yapılıyorsa

                                        containerSize = containerSize.copyWith(
                                          height: minimumContainerHeight,
                                        );
                                        return;
                                      }
                                      if (position.y +
                                              containerSize.height +
                                              details.delta.dy >
                                          widget.height) {
                                        //eğer container en aşağı kaydırıldıysa container yüksekliği sabit kalır

                                        containerSize = containerSize.copyWith(
                                          height: widget.height - position.y,
                                        );
                                      } else {
                                        containerSize = containerSize.copyWith(
                                          height: containerSize.height +
                                              details.delta.dy,
                                        );
                                      }
                                    }
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
                                },
                                child: _HandleWidget(
                                  handlePosition: handlePosition,
                                  height: getHandleWidgetHeight(handlePosition),
                                  width: getHandleWidgetWidth(handlePosition),
                                  backgroundColor:
                                      widget.dragHandleColor ?? Colors.blue,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void calculateSizeAfterChangedSize(double stackWidth, double stackHeight) {
    setState(() {
      final oldStackXPosition = stackPosition.x;
      final oldStackYPosition = stackPosition.y;
      final newStackXPosition = stackWidth / 2 - containerSize.width / 2;
      final newStackYPosition = stackHeight / 2 - containerSize.height / 2;

      if (rotateAngle != 0) {
        // rotateAngle 0'dan farklı olduğunda trigonometrik dönüşümler kullan
        final deltaX = oldStackXPosition - newStackXPosition;
        final deltaY = oldStackYPosition - newStackYPosition;
        final cosAngle = cos(rotateAngle);
        final sinAngle = sin(rotateAngle);

        position = position.copyWith(
          x: position.x + (deltaX * cosAngle - deltaY * sinAngle),
          y: position.y + (deltaX * sinAngle + deltaY * cosAngle),
        );
      } else {
        // rotateAngle 0 olduğunda mevcut hesaplamaları kullan

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

  void initializeWidgetSize(double stackWidth, double stackHeight) {
    if (initializeSize == false &&
        (widget.minimumContainerHeight != null ||
            widget.minimumContainerWidth != null)) {
      minimumContainerHeight =
          widget.minimumContainerHeight ?? minimumContainerHeight;
      minimumContainerWidth =
          widget.minimumContainerWidth ?? minimumContainerWidth;

      containerSize = containerSize.copyWith(
        height: minimumContainerHeight,
      );
      stackPosition = stackPosition.copyWith(
        x: stackWidth / 2 - containerSize.width / 2,
        y: stackHeight / 2 - containerSize.height / 2,
      );
      initializeSize = true;
    }
  }

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
  }

  void updateEvents() {
    if (position != oldPosition && !changedSize) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (widget.onPositionChangeEnd != null && changesFromOutside) {
          widget.onPositionChangeEnd
              ?.call(oldPosition, position, oldRotateAngle, rotateAngle);
          oldPosition = position;
          oldRotateAngle = rotateAngle;
        }
        if (widget.onPositionChange != null) {
          widget.onPositionChange?.call(oldPosition, position);
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

  double getHandleWidgetHeight(_HandlePosition handlePosition) {
    switch (handlePosition) {
      case _HandlePosition.top:
      case _HandlePosition.bottom:
        return handleWidgetHeight;
      case _HandlePosition.left:
      case _HandlePosition.right:
        return containerSize.height / 7;
    }
  }

  double getHandleWidgetWidth(_HandlePosition handlePosition) {
    switch (handlePosition) {
      case _HandlePosition.top:
      case _HandlePosition.bottom:
        return containerSize.width / 7;
      case _HandlePosition.left:
      case _HandlePosition.right:
        return handleWidgetWidth;
    }
  }

  double? getHandleLeft(_HandlePosition handlePosition) {
    switch (handlePosition) {
      case _HandlePosition.left:
        return position.x - handleWidgetWidth / 2;
      case _HandlePosition.right:
        return position.x + containerSize.width - handleWidgetWidth / 2;
      case _HandlePosition.top:
      case _HandlePosition.bottom:
        return position.x + containerSize.width / 2 - 5.0;
    }
  }

  double? getHandleTop(_HandlePosition handlePosition) {
    switch (handlePosition) {
      case _HandlePosition.top:
        return position.y - handleWidgetHeight / 2;
      case _HandlePosition.bottom:
        return position.y + containerSize.height - handleWidgetHeight / 2;
      case _HandlePosition.left:
      case _HandlePosition.right:
        return position.y + containerSize.height / 2 - 5.0;
    }
  }
}

enum _HandlePosition {
  top,
  left,
  right,
  bottom,
}

class _HandleWidget extends StatelessWidget {
  const _HandleWidget({
    required this.height,
    required this.width,
    required this.handlePosition,
    required this.backgroundColor,
  });
  final double height;
  final double width;
  final _HandlePosition handlePosition;
  final Color backgroundColor;
  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      color: Colors.transparent,
      child: Center(
        child: Container(
          width: getWidthFromPosition(),
          height: getHeightFromPosition(),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(5),
          ),
        ),
      ),
    );
  }

  double getHeightFromPosition() {
    if (handlePosition == _HandlePosition.top ||
        handlePosition == _HandlePosition.bottom) {
      return 3;
    } else {
      return height;
    }
  }

  double getWidthFromPosition() {
    if (handlePosition == _HandlePosition.left ||
        handlePosition == _HandlePosition.right) {
      return 3;
    } else {
      return width;
    }
  }
}
