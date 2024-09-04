// ignore_for_file: lines_longer_than_80_chars

import 'dart:math';

import 'package:flutter/material.dart';

class PainterContainer extends StatefulWidget {
  const PainterContainer({required this.height, super.key});
  final double height;
  @override
  State<PainterContainer> createState() => _PainterContainerState();
}

class _PainterContainerState extends State<PainterContainer> {
  double yPosition = 0;
  double xPosition = 0;
  double stackYPosition = 0;
  double stackXPosition = 0;
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
      stackYPosition = stackHeight / 2 - containerHeight / 2;
      stackXPosition = stackWidth / 2 - containerWidth / 2;
      stackPositionControl = true;
    }

    return Positioned(
      left: xPosition,
      top: yPosition,
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
                  left: stackXPosition,
                  top: stackYPosition,
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

                          xPosition = xPosition + deltaX;
                          yPosition = yPosition + deltaY;

                          stackXPosition = stackWidth / 2 - containerWidth / 2;
                          stackYPosition =
                              stackHeight / 2 - containerHeight / 2;
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
                          final oldStackXPosition = stackXPosition;
                          final oldStackYPosition = stackYPosition;
                          final newStackXPosition =
                              stackWidth / 2 - containerWidth / 2;
                          final newStackYPosition =
                              stackHeight / 2 - containerHeight / 2;
                          xPosition =
                              xPosition - (containerWidth - oldWidth) / 2;
                          yPosition =
                              yPosition - (containerHeight - oldHeight) / 2;
                          xPosition += oldStackXPosition - newStackXPosition;
                          yPosition += oldStackYPosition - newStackYPosition;
                          stackXPosition = newStackXPosition;
                          stackYPosition = newStackYPosition;
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
                  left: stackXPosition,
                  top: stackYPosition,
                  child: Container(
                    width: containerWidth,
                    height: containerHeight,
                    child: Stack(
                      children: _HandlePosition.values
                          .map(
                            (position) => Align(
                              alignment: position == _HandlePosition.top
                                  ? Alignment.topCenter
                                  : position == _HandlePosition.bottom
                                      ? Alignment.bottomCenter
                                      : position == _HandlePosition.left
                                          ? Alignment.centerLeft
                                          : position == _HandlePosition.right
                                              ? Alignment.centerRight
                                              : Alignment.center,
                              child: GestureDetector(
                                onPanEnd: (details) {
                                  setState(() {
                                    final oldStackXPosition = stackXPosition;
                                    final oldStackYPosition = stackYPosition;
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

                                      xPosition +=
                                          deltaX * cosAngle - deltaY * sinAngle;
                                      yPosition +=
                                          deltaX * sinAngle + deltaY * cosAngle;
                                    } else {
                                      // rotateAngle 0 olduğunda mevcut hesaplamaları kullan
                                      xPosition +=
                                          oldStackXPosition - newStackXPosition;
                                      yPosition +=
                                          oldStackYPosition - newStackYPosition;
                                    }

                                    stackXPosition = newStackXPosition;
                                    stackYPosition = newStackYPosition;
                                  });
                                },
                                onPanUpdate: (details) {
                                  setState(() {
                                    if (position == _HandlePosition.left) {
                                      if (containerWidth <=
                                              minimumContainerWidth &&
                                          details.delta.dx > 0) {
                                        //container genişliği minimum genişlikten küçükse ve sola doğru kaydırma yapılıyorsa
                                        containerWidth = minimumContainerWidth;
                                        return;
                                      }
                                      containerWidth -= details.delta.dx;
                                      stackXPosition += details.delta.dx;
                                    } else if (position ==
                                        _HandlePosition.right) {
                                      if (containerWidth <=
                                              minimumContainerWidth &&
                                          details.delta.dx < 0) {
                                        //container genişliği minimum genişlikten küçükse ve sağa doğru kaydırma yapılıyorsa
                                        containerWidth = minimumContainerWidth;
                                        return;
                                      }
                                      containerWidth += details.delta.dx;
                                    } else if (position ==
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
                                        stackYPosition += details.delta.dy;
                                      }
                                    } else if (position ==
                                        _HandlePosition.bottom) {
                                      if (containerHeight <=
                                              minimumContainerHeight &&
                                          details.delta.dy < 0) {
                                        //container yüksekliği minimum yükseklikten küçükse ve aşağı doğru kaydırma yapılıyorsa
                                        containerHeight =
                                            minimumContainerHeight;
                                        return;
                                      }
                                      if (yPosition +
                                              containerHeight +
                                              details.delta.dy >
                                          widget.height) {
                                        //eğer container en aşağı kaydırıldıysa container yüksekliği sabit kalır
                                        containerHeight =
                                            widget.height - yPosition;
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
                                  handlePosition: position,
                                  height: getHandleWidgetHeight(position),
                                  width: getHandleWidgetWidth(position),
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

  double? getHandleLeft(_HandlePosition position) {
    switch (position) {
      case _HandlePosition.left:
        return xPosition - handleWidgetWidth / 2;
      case _HandlePosition.right:
        return xPosition + containerWidth - handleWidgetWidth / 2;
      case _HandlePosition.top:
      case _HandlePosition.bottom:
        return xPosition + containerWidth / 2 - 5.0;
    }
  }

  double? getHandleTop(_HandlePosition position) {
    switch (position) {
      case _HandlePosition.top:
        return yPosition - handleWidgetHeight / 2;
      case _HandlePosition.bottom:
        return yPosition + containerHeight - handleWidgetHeight / 2;
      case _HandlePosition.left:
      case _HandlePosition.right:
        return yPosition + containerHeight / 2 - 5.0;
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
    return xPosition + containerWidth + offset.dx > screenWidth;
  }

  bool _isXCoordinateLessThanZero(Offset offset) => xPosition + offset.dx <= 0;

  bool _isYCoordinateMoreThanScreenHeight(
    Offset offset,
    double screenHeight,
  ) {
    return yPosition + containerHeight + offset.dy > screenHeight;
  }

  bool _isYCoordinateLessThanZero(Offset offset) => yPosition + offset.dy <= 0;
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
