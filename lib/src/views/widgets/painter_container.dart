// ignore_for_file: lines_longer_than_80_chars

import 'package:flutter/material.dart';
import 'package:flutter_painter/src/models/position_model.dart';
import 'package:flutter_painter/src/models/size_model.dart';

class PainterContainer extends StatefulWidget {
  const PainterContainer(
      {required this.height,
      super.key,
      this.dragHandleColor,
      required this.selectedItem,
      this.onTapItem,
      this.child,
      this.minimumContainerHeight,
      this.minimumContainerWidth,
      this.onPositionChange,
      this.onSizeChange,
      this.itemPosition,
      this.itemSize});
  final double height;
  final Color? dragHandleColor;
  final bool selectedItem;
  final void Function(bool)? onTapItem;
  final void Function(PositionModel)? onPositionChange;
  final void Function(SizeModel)? onSizeChange;
  final Widget? child;
  final double? minimumContainerHeight;
  final double? minimumContainerWidth;
  final PositionModel? itemPosition;
  final SizeModel? itemSize;
  @override
  State<PainterContainer> createState() => _PainterContainerState();
}

class _PainterContainerState extends State<PainterContainer> {
  var position = PositionModel(x: 50, y: 50);
  double containerWidth = 100;
  double containerHeight = 100;
  final handleWidgetWidth = 15.0;
  final handleWidgetHeight = 15.0;
  double minimumContainerWidth = 50.0;
  double minimumContainerHeight = 50.0;
  double scaleCurrentHeight = -1;
  double currentRotateAngel = -1;
  double rotateAngle = 0;
  bool setHeights = false;

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    controlHeights();

    return Transform.rotate(
      angle: rotateAngle,
      child: Stack(
        children: [
          Positioned(
            left: position.x,
            top: position.y,
            child: GestureDetector(
              onTap: () {
                if (widget.onTapItem != null) {
                  widget.onTapItem!(!widget.selectedItem);
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
                  widget.onPositionChange!(
                      PositionModel(x: position.x, y: position.y));
                }
                if (widget.onSizeChange != null) {
                  widget.onSizeChange!(SizeModel(
                      width: containerWidth, height: containerHeight));
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
                    position = position.copyWith(
                        x: _isXCoordinateMoreThanScreenWidth(pos, screenWidth)
                            ? screenWidth -
                                containerWidth // stick to right edge of the screen
                            : _isXCoordinateLessThanZero(pos)
                                ? 0 // stick to left edge, of the screen
                                : position.x + pos.dx,
                        y: _isYCoordinateMoreThanScreenHeight(
                                pos, widget.height)
                            ? (widget.height / 2) -
                                containerHeight // stick to bottom edge of the screen
                            : _isYCoordinateLessThanZero(pos)
                                ? 0 // stick to top edge of the screen
                                : position.y + pos.dy);
                  });
                } else if (details.pointerCount == 2) {
                  if (scaleCurrentHeight == -1) {
                    scaleCurrentHeight = containerHeight;
                  }
                  if (currentRotateAngel == -1) {
                    currentRotateAngel = rotateAngle;
                  }
                  final realScale =
                      (scaleCurrentHeight * details.scale) / containerHeight;
                  final realRotateAngle = currentRotateAngel + details.rotation;
                  final oldWidth = containerWidth;
                  final oldHeight = containerHeight;
                  setState(() {
                    rotateAngle = realRotateAngle; // set rotation
                    if (containerWidth * realScale < minimumContainerWidth ||
                        containerHeight * realScale < minimumContainerHeight) {
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
              child: Container(
                width: containerWidth,
                height: containerHeight,
                child: Center(child: widget.child),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: widget.selectedItem
                        ? widget.dragHandleColor ?? Colors.blue ?? Colors.blue
                        : Colors.transparent,
                  ),
                ),
              ),
            ),
          ),
          if (widget.selectedItem)
            for (_HandlePosition handlePosition in _HandlePosition.values)
              if (handlePosition != _HandlePosition.middleCenter)
                Positioned(
                  left: getHandleLeft(handlePosition),
                  top: getHandleTop(handlePosition),
                  child: GestureDetector(
                    onPanUpdate: (details) {
                      setState(() {
                        if (handlePosition == _HandlePosition.left) {
                          if (containerWidth <= minimumContainerWidth &&
                              details.delta.dx > 0) {
                            //container genişliği minimum genişlikten küçükse ve sola doğru kaydırma yapılıyorsa
                            containerWidth = minimumContainerWidth;
                            return;
                          }
                          containerWidth -= details.delta.dx;

                          position = position.copyWith(
                              x: position.x + details.delta.dx);
                        } else if (handlePosition == _HandlePosition.right) {
                          print(details.delta.dx);
                          if (containerWidth <= minimumContainerWidth &&
                              details.delta.dx < 0) {
                            //container genişliği minimum genişlikten küçükse ve sağa doğru kaydırma yapılıyorsa
                            containerWidth = minimumContainerWidth;
                            return;
                          }
                          if (position.x + containerWidth + details.delta.dx >
                              screenWidth) {
                            containerWidth = screenWidth - position.x;
                          }
                          containerWidth += details.delta.dx;
                        } else if (handlePosition == _HandlePosition.top) {
                          if (containerHeight <= minimumContainerHeight &&
                              details.delta.dy > 0) {
                            //container yüksekliği minimum yükseklikten küçükse ve yukarı doğru kaydırma yapılıyorsa
                            containerHeight = minimumContainerHeight;
                            return;
                          }
                          if (position.y < 0) {
                            //eğer container en yukarı kaydırıldıysa position.y 0.1 sabitler
                            position = position.copyWith(y: 0.1);
                          } else {
                            if (position.y == 0.1 && details.delta.dy > 0) {
                              //eğer container en yukarı kaydırıldıysa ve aşağı doğru kaydırma yapılıyorsa
                              containerHeight -= details.delta.dy;
                              position = position.copyWith(
                                  y: position.y + details.delta.dy);
                            } else if (position.y == 0.1) {
                              //eğer container en yukarı kaydırıldıysa ve yukarı doğru kaydırma yapılıyorsa
                              return;
                            }
                            containerHeight -= details.delta.dy;
                            position = position.copyWith(
                                y: position.y + details.delta.dy);
                          }
                        } else if (handlePosition == _HandlePosition.bottom) {
                          if (containerHeight <= minimumContainerHeight &&
                              details.delta.dy < 0) {
                            //container yüksekliği minimum yükseklikten küçükse ve aşağı doğru kaydırma yapılıyorsa
                            containerHeight = minimumContainerHeight;
                            return;
                          }
                          if (position.y + containerHeight + details.delta.dy >
                              (widget.height / 2)) {
                            //eğer container en aşağı kaydırıldıysa container yüksekliği sabit kalır
                            containerHeight = widget.height / 2 - position.y;
                          } else {
                            containerHeight += details.delta.dy;
                          }
                        }
                      });
                    },
                    child: _HandleWidget(
                      handlePosition: handlePosition,
                      height: getHandleWidgetHeight(handlePosition),
                      width: getHandleWidgetWidth(handlePosition),
                      backgroundColor: widget.dragHandleColor ?? Colors.blue,
                    ),
                  ),
                ),
        ],
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
      case _HandlePosition.middleCenter:
        return containerHeight;
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
      case _HandlePosition.middleCenter:
        return containerWidth / 7;
    }
  }

  double? getHandleLeft(_HandlePosition handlePosition) {
    switch (handlePosition) {
      case _HandlePosition.left:
        return position.x - handleWidgetWidth / 2;
      case _HandlePosition.right:
        return position.x + containerWidth - handleWidgetWidth / 2;
      case _HandlePosition.top:
      case _HandlePosition.bottom:
        return position.x + containerWidth / 2 - (containerWidth / 7) / 2;
      case _HandlePosition.middleCenter:
        return position.x + containerWidth / 2 - 5.0;
    }
  }

  double? getHandleTop(_HandlePosition handlePosition) {
    switch (handlePosition) {
      case _HandlePosition.top:
        return position.y - handleWidgetHeight / 2;
      case _HandlePosition.bottom:
        return position.y + containerHeight - handleWidgetHeight / 2;
      case _HandlePosition.left:
      case _HandlePosition.right:
      case _HandlePosition.middleCenter:
        return position.y + containerHeight / 2 - (containerHeight / 7) / 2;
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
  middleCenter,
}

class _HandleWidget extends StatelessWidget {
  const _HandleWidget(
      {required this.height,
      required this.width,
      required this.handlePosition,
      required this.backgroundColor});
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
      return height / 3;
    } else {
      return height;
    }
  }

  double getWidthFromPosition() {
    if (handlePosition == _HandlePosition.left ||
        handlePosition == _HandlePosition.right) {
      return width / 3;
    } else {
      return width;
    }
  }
}
