// ignore_for_file: lines_longer_than_80_chars

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_painter/src/models/position_model.dart';

class PainterContainerStable extends StatefulWidget {
  const PainterContainerStable({required this.height, super.key});
  final double height;
  @override
  State<PainterContainerStable> createState() => _PainterContainerStableState();
}

class _PainterContainerStableState extends State<PainterContainerStable> {
  PositionModel position = const PositionModel();
  PositionModel stackPosition = const PositionModel();
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
  bool stackPositionControl = false;

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double stackHeight = widget.height / 2;
    double stackWidth = screenWidth;

    if (stackPositionControl == false) {
      stackPosition = PositionModel(
        x: stackWidth / 2 - containerWidth / 2,
        y: stackHeight / 2 - containerHeight / 2,
      );

      stackPositionControl = true;
    }

    print('position $position');
    print('stackPosition $stackPosition');
    print('containerWidth $containerWidth');
    print('containerHeight $containerHeight');
    print('stackHeight $stackHeight');
    print('stackWidth $stackWidth');
    print('rotateAngle $rotateAngle');
    print('minimumContainerWidth $minimumContainerWidth');
    print('minimumContainerHeight $minimumContainerHeight');
    print('scaleCurrentHeight $scaleCurrentHeight');
    print('currentRotateAngel $currentRotateAngel');
    print('setHeights $setHeights');
    print('stackPositionControl $stackPositionControl');
    print('--------------------------------------------------');
    return Positioned(
      left: position.x,
      top: position.y,
      child: SizedBox(
        height: stackHeight,
        width: stackWidth,
        child: Transform.rotate(
          angle: rotateAngle,
          child: ColoredBox(
            color: Colors.green,
            child: Stack(
              children: [
                Positioned(
                  left: stackPosition.x,
                  top: stackPosition.y,
                  child: GestureDetector(
                    onScaleStart: (details) {
                      scaleCurrentHeight = -1;
                    },
                    onScaleEnd: (details) {
                      currentRotateAngel = rotateAngle;
                    },
                    onScaleUpdate: (details) {
                      if (details.pointerCount == 1) {
                        final pos = details.focalPointDelta;
                        setState(() {
                          final cosAngle = cos(rotateAngle);
                          final sinAngle = sin(rotateAngle);

                          final deltaX = pos.dx * cosAngle - pos.dy * sinAngle;
                          final deltaY = pos.dx * sinAngle + pos.dy * cosAngle;

                          position = position.copyWith(
                              x: position.x + deltaX, y: position.y + deltaY);

                          stackPosition = stackPosition.copyWith(
                            x: stackWidth / 2 - containerWidth / 2,
                            y: stackHeight / 2 - containerHeight / 2,
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
                          final oldStackXPosition = stackPosition.x;
                          final oldStackYPosition = stackPosition.y;
                          final newStackXPosition =
                              stackWidth / 2 - containerWidth / 2;
                          final newStackYPosition =
                              stackHeight / 2 - containerHeight / 2;
                          position = position.copyWith(
                            x: position.x - (containerWidth - oldWidth) / 2,
                            y: position.y - (containerHeight - oldHeight) / 2,
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
                      width: containerWidth,
                      height: containerHeight,
                      child: Center(
                          child: Container(
                        color: Colors.amber,
                        child: Text(
                            'asda sda sdas das as dasddas asd a sdasd asd  asd asd'),
                      )),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: stackPosition.x,
                  top: stackPosition.y,
                  child: Container(
                    width: containerWidth,
                    height: containerHeight,
                    child: Stack(
                      children: _HandlePosition.values
                          .map(
                            (handlePosition) => Align(
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
                                  setState(() {
                                    final oldStackXPosition = stackPosition.x;
                                    final oldStackYPosition = stackPosition.y;
                                    final newStackXPosition =
                                        stackWidth / 2 - containerWidth / 2;
                                    final newStackYPosition =
                                        stackHeight / 2 - containerHeight / 2;

                                    if (rotateAngle != 0) {
                                      // rotateAngle 0'dan farklı olduğunda trigonometrik dönüşümler kullan
                                      final deltaX =
                                          oldStackXPosition - newStackXPosition;
                                      final deltaY =
                                          oldStackYPosition - newStackYPosition;
                                      final cosAngle = cos(rotateAngle);
                                      final sinAngle = sin(rotateAngle);

                                      position = position.copyWith(
                                        x: position.x +
                                            (deltaX * cosAngle -
                                                deltaY * sinAngle),
                                        y: position.y +
                                            (deltaX * sinAngle +
                                                deltaY * cosAngle),
                                      );
                                    } else {
                                      // rotateAngle 0 olduğunda mevcut hesaplamaları kullan

                                      position = position.copyWith(
                                        x: position.x +
                                            (oldStackXPosition -
                                                newStackXPosition),
                                        y: position.y +
                                            (oldStackYPosition -
                                                newStackYPosition),
                                      );
                                    }

                                    stackPosition = stackPosition.copyWith(
                                      x: newStackXPosition,
                                      y: newStackYPosition,
                                    );
                                  });
                                },
                                onPanUpdate: (details) {
                                  setState(() {
                                    if (handlePosition ==
                                        _HandlePosition.left) {
                                      if (containerWidth <=
                                              minimumContainerWidth &&
                                          details.delta.dx > 0) {
                                        //container genişliği minimum genişlikten küçükse ve sola doğru kaydırma yapılıyorsa
                                        containerWidth = minimumContainerWidth;
                                        return;
                                      }
                                      containerWidth -= details.delta.dx;

                                      stackPosition = stackPosition.copyWith(
                                        x: stackPosition.x + details.delta.dx,
                                      );
                                    } else if (handlePosition ==
                                        _HandlePosition.right) {
                                      if (containerWidth <=
                                              minimumContainerWidth &&
                                          details.delta.dx < 0) {
                                        //container genişliği minimum genişlikten küçükse ve sağa doğru kaydırma yapılıyorsa
                                        containerWidth = minimumContainerWidth;
                                        return;
                                      }
                                      containerWidth += details.delta.dx;
                                    } else if (handlePosition ==
                                        _HandlePosition.top) {
                                      if (containerHeight <=
                                              minimumContainerHeight &&
                                          details.delta.dy > 0) {
                                        //container yüksekliği minimum yükseklikten küçükse ve yukarı doğru kaydırma yapılıyorsa
                                        containerHeight =
                                            minimumContainerHeight;
                                        return;
                                      } else {
                                        containerHeight -= details.delta.dy;
                                        stackPosition = stackPosition.copyWith(
                                          y: stackPosition.y + details.delta.dy,
                                        );
                                      }
                                    } else if (handlePosition ==
                                        _HandlePosition.bottom) {
                                      if (containerHeight <=
                                              minimumContainerHeight &&
                                          details.delta.dy < 0) {
                                        //container yüksekliği minimum yükseklikten küçükse ve aşağı doğru kaydırma yapılıyorsa
                                        containerHeight =
                                            minimumContainerHeight;
                                        return;
                                      }
                                      if (position.y +
                                              containerHeight +
                                              details.delta.dy >
                                          widget.height) {
                                        //eğer container en aşağı kaydırıldıysa container yüksekliği sabit kalır
                                        containerHeight =
                                            widget.height - position.y;
                                      } else {
                                        containerHeight += details.delta.dy;
                                      }
                                    }

                                    // stackXPosition =
                                    //     stackWidth / 2 - containerWidth / 2;
                                    // stackYPosition =
                                    //     stackHeight / 2 - containerHeight / 2;
                                  });
                                },
                                child: _HandleWidget(
                                  handlePosition: handlePosition,
                                  height: getHandleWidgetHeight(handlePosition),
                                  width: getHandleWidgetWidth(handlePosition),
                                ),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  double getHandleWidgetHeight(_HandlePosition position) {
    switch (position) {
      case _HandlePosition.top:
      case _HandlePosition.bottom:
        return handleWidgetHeight;
      case _HandlePosition.left:
      case _HandlePosition.right:
        return containerHeight / 7;
    }
  }

  double getHandleWidgetWidth(_HandlePosition position) {
    switch (position) {
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
        return position.x - handleWidgetWidth / 2;
      case _HandlePosition.right:
        return position.x + containerWidth - handleWidgetWidth / 2;
      case _HandlePosition.top:
      case _HandlePosition.bottom:
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
        return position.y + containerHeight / 2 - 5.0;
    }
  }

  // onPanUpdate: (tapInfo) {
  //   setState(() {
  //     xPosition = _isXCoordinateMoreThanScreenWidth(tapInfo, screenWidth)
  //         ? screenWidth -
  //             containerWidth // stick to right edge of the screen
  //         : _isXCoordinateLessThanZero(tapInfo)
  //             ? 0 // stick to left edge of the screen
  //             : xPosition + tapInfo.delta.dx;
  //     yPosition =
  //         _isYCoordinateMoreThanScreenHeight(tapInfo, widget.height)
  //             ? widget.height -
  //                 containerHeight // stick to bottom edge of the screen
  //             : _isYCoordinateLessThanZero(tapInfo)
  //                 ? 0 // stick to top edge of the screen
  //                 : yPosition + tapInfo.delta.dy;
  //   });
  // },

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
    return position.y + containerHeight + offset.dy > screenHeight;
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
  const _HandleWidget(
      {required this.height,
      required this.width,
      required this.handlePosition});
  final double height;
  final double width;
  final _HandlePosition handlePosition;
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
            color: Colors.grey,
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
