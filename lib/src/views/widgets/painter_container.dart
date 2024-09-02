// ignore_for_file: lines_longer_than_80_chars

import 'package:flutter/material.dart';
import 'package:flutter_painter/src/models/position_model.dart';
import 'package:flutter_painter/src/models/size_model.dart';

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
    this.itemPosition,
    this.itemSize,
    this.enabled,
  });
  final double height;
  final Color? dragHandleColor;
  final bool selectedItem;
  final void Function({bool tapItem})? onTapItem;
  final void Function(PositionModel)? onPositionChange;
  final void Function(SizeModel)? onSizeChange;
  final Widget? child;
  final double? minimumContainerHeight;
  final double? minimumContainerWidth;
  final PositionModel? itemPosition;
  final SizeModel? itemSize;
  final bool? enabled;
  @override
  State<PainterContainer> createState() => _PainterContainerState();
}

class _PainterContainerState extends State<PainterContainer> {
  PositionModel position = const PositionModel(x: 50, y: 50);
  PositionModel oldPosition = const PositionModel(x: 50, y: 50);
  double containerWidth = 100;
  double containerHeight = 100;
  final handleWidgetWidth = 15.0;
  final handleWidgetHeight = 15.0;
  double minimumContainerWidth = 50;
  double minimumContainerHeight = 50;
  double scaleCurrentHeight = -1;
  double currentRotateAngel = -1;
  double rotateAngle = 0;
  bool setHeights = false;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    controlHeights();
    if (widget.onPositionChange != null && position != oldPosition) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        widget.onPositionChange?.call(position);
      });

      oldPosition = position;
    }
    return Positioned(
      left: position.x,
      top: position.y,
      child: Opacity(
        opacity: widget.enabled != null && widget.enabled! ? 1 : 0,
        child: Transform.rotate(
          angle: rotateAngle,
          child: Stack(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: handleWidgetHeight,
                    vertical: handleWidgetWidth),
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
                        PositionModel(x: position.x, y: position.y),
                      );
                    }
                    if (widget.onSizeChange != null) {
                      widget.onSizeChange?.call(
                        SizeModel(
                          width: containerWidth,
                          height: containerHeight,
                        ),
                      );
                    }
                    currentRotateAngel = rotateAngle;
                  },
                  onScaleUpdate: (details) {
                    if (!widget.selectedItem) {
                      return;
                    }
                    if (details.pointerCount == 1) {
                      final pos = details.focalPointDelta;
                      setState(() {
                        final cosAngle = cos(rotateAngle);
                        final sinAngle = sin(rotateAngle);

                        final deltaX = pos.dx * cosAngle - pos.dy * sinAngle;
                        final deltaY = pos.dx * sinAngle + pos.dy * cosAngle;

                        position = position.copyWith(
                          x: _isXCoordinateMoreThanScreenWidth(
                                  Offset(deltaX, deltaY), screenWidth)
                              ? screenWidth -
                                  containerWidth // stick to right edge of the screen
                              : _isXCoordinateLessThanZero(
                                      Offset(deltaX, deltaY))
                                  ? 0 // stick to left edge, of the screen
                                  : position.x + deltaX,
                          y: _isYCoordinateMoreThanScreenHeight(
                                  Offset(deltaX, deltaY), widget.height)
                              ? (widget.height / 2) -
                                  containerHeight // stick to bottom edge of the screen
                              : _isYCoordinateLessThanZero(
                                      Offset(deltaX, deltaY))
                                  ? 0 // stick to top edge of the screen
                                  : position.y + deltaY,
                        );
                      });
                    } else if (details.pointerCount == 2) {
                      if (scaleCurrentHeight == -1) {
                        scaleCurrentHeight = containerHeight;
                      }
                      if (currentRotateAngel == -1) {
                        currentRotateAngel = rotateAngle;
                      }
                      final realScale = (scaleCurrentHeight * details.scale) /
                          containerHeight;
                      final realRotateAngle =
                          currentRotateAngel + details.rotation;
                      final oldWidth = containerWidth;
                      final oldHeight = containerHeight;
                      setState(() {
                        rotateAngle = realRotateAngle; // set rotation
                        if (containerWidth * realScale <
                                minimumContainerWidth ||
                            containerHeight * realScale <
                                minimumContainerHeight) {
                          return;
                        } else {
                          containerWidth = containerWidth * realScale;
                          containerHeight = containerHeight * realScale;
                        }
                        position = position.copyWith(
                          x: position.x - (containerWidth - oldWidth) / 2,
                          y: position.y - (containerHeight - oldHeight) / 2,
                        );
                      });
                    }
                  },
                  child: SizedBox(
                    width: containerWidth,
                    height: containerHeight,
                    child: Container(
                      width: containerWidth,
                      height: containerHeight,
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
                Positioned.fill(
                    child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: handleWidgetHeight / 2,
                    vertical: handleWidgetWidth / 2,
                  ),
                  child: Stack(
                    children: _HandlePosition.values.map((handlePosition) {
                      return Align(
                        alignment: handlePosition == _HandlePosition.top
                            ? Alignment.topCenter
                            : handlePosition == _HandlePosition.bottom
                                ? Alignment.bottomCenter
                                : handlePosition == _HandlePosition.left
                                    ? Alignment.centerLeft
                                    : handlePosition == _HandlePosition.right
                                        ? Alignment.centerRight
                                        : Alignment.center,
                        child: GestureDetector(
                          onPanUpdate: (details) {
                            setState(() {
                              final deltaX = details.delta.dx;
                              final deltaY = details.delta.dy;

                              // Dönüş açısını hesaba katarak delta değerlerini güncelle
                              final transformedDeltaX =
                                  deltaX * cos(-rotateAngle) -
                                      deltaY * sin(-rotateAngle);
                              final transformedDeltaY =
                                  deltaX * sin(-rotateAngle) +
                                      deltaY * cos(-rotateAngle);

                              if (handlePosition == _HandlePosition.left) {
                                if (containerWidth > minimumContainerWidth ||
                                    transformedDeltaX > 0) {
                                  containerWidth -= transformedDeltaX;
                                  position = position.copyWith(
                                    x: position.x +
                                        transformedDeltaX * cos(rotateAngle),
                                    y: position.y +
                                        transformedDeltaX * sin(rotateAngle),
                                  );
                                } else {
                                  containerWidth = minimumContainerWidth;
                                }
                              } else if (handlePosition ==
                                  _HandlePosition.right) {
                                if (containerWidth > minimumContainerWidth ||
                                    transformedDeltaX > 0) {
                                  containerWidth += transformedDeltaX;
                                } else {
                                  containerWidth = minimumContainerWidth;
                                }

                                if (position.x + containerWidth > screenWidth) {
                                  containerWidth = screenWidth - position.x;
                                }
                              } else if (handlePosition ==
                                  _HandlePosition.top) {
                                if (containerHeight > minimumContainerHeight ||
                                    transformedDeltaY > 0) {
                                  containerHeight -= transformedDeltaY;
                                  position = position.copyWith(
                                    x: position.x -
                                        transformedDeltaY * sin(rotateAngle),
                                    y: position.y +
                                        transformedDeltaY * cos(rotateAngle),
                                  );
                                } else {
                                  containerHeight = minimumContainerHeight;
                                }
                              } else if (handlePosition ==
                                  _HandlePosition.bottom) {
                                if (containerHeight > minimumContainerHeight ||
                                    transformedDeltaY > 0) {
                                  containerHeight += transformedDeltaY;
                                } else {
                                  containerHeight = minimumContainerHeight;
                                }

                                if (position.y + containerHeight >
                                    (widget.height / 2)) {
                                  containerHeight =
                                      (widget.height / 2) - position.y;
                                }
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
                )),
            ],
          ),
        ),
      ),
    );
  }

  void controlHeights() {
    if (setHeights == false &&
        (widget.minimumContainerHeight != null ||
            widget.minimumContainerWidth != null)) {
      minimumContainerHeight =
          widget.minimumContainerHeight ?? minimumContainerHeight;
      minimumContainerWidth =
          widget.minimumContainerWidth ?? minimumContainerWidth;
      containerHeight = minimumContainerHeight;

      setHeights = true;
    }
  }

  double getHandleWidgetHeight(_HandlePosition handlePosition) {
    switch (handlePosition) {
      case _HandlePosition.top:
      case _HandlePosition.bottom:
        return handleWidgetHeight;
      case _HandlePosition.left:
      case _HandlePosition.right:
        return containerHeight / 7;
    }
  }

  double getHandleWidgetWidth(_HandlePosition handlePosition) {
    switch (handlePosition) {
      case _HandlePosition.top:
      case _HandlePosition.bottom:
        return containerWidth / 7;
      case _HandlePosition.left:
      case _HandlePosition.right:
        return handleWidgetWidth;
    }
  }

  double? getHandleLeft(_HandlePosition handlePosition) {
    switch (handlePosition) {
      case _HandlePosition.left:
        return 0;
      case _HandlePosition.right:
        return containerWidth - handleWidgetWidth / 2;
      case _HandlePosition.top:
      case _HandlePosition.bottom:
        return containerWidth / 2 - (containerWidth / 7) / 2;
    }
  }

  double? getHandleTop(_HandlePosition handlePosition) {
    switch (handlePosition) {
      case _HandlePosition.top:
        return 0;
      case _HandlePosition.bottom:
        return containerHeight - handleWidgetHeight / 2;
      case _HandlePosition.left:
      case _HandlePosition.right:
        return containerHeight;
    }
  }

  bool _isXCoordinateMoreThanScreenWidth(
    Offset offset,
    double screenWidth,
  ) {
    return position.x + containerWidth + offset.dx > screenWidth;
  }

  bool _isXCoordinateLessThanZero(Offset offset) => position.x + offset.dx <= 0;

  bool _isYCoordinateMoreThanScreenHeight(
    Offset offset,
    double screenHeight,
  ) {
    return position.y + containerHeight + offset.dy > screenHeight / 2;
  }

  bool _isYCoordinateLessThanZero(Offset offset) => position.y + offset.dy <= 0;
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
