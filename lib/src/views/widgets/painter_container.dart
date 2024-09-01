// ignore_for_file: lines_longer_than_80_chars

import 'package:flutter/material.dart';

class PainterContainer extends StatefulWidget {
  const PainterContainer({required this.height, super.key});
  final double height;
  @override
  State<PainterContainer> createState() => _PainterContainerState();
}

class _PainterContainerState extends State<PainterContainer> {
  double xPosition = 50;
  double yPosition = 50;
  double containerWidth = 100;
  double containerHeight = 100;
  final handleWidgetWidth = 15.0;
  final handleWidgetHeight = 15.0;
  final minimumContainerWidth = 50.0;
  final minimumContainerHeight = 50.0;
  double scaleCurrentHeight = -1;
  double rotateAngle = 0;
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Transform.rotate(
      angle: rotateAngle,
      child: Stack(
        children: [
          Positioned(
            left: xPosition,
            top: yPosition,
            child: GestureDetector(
              onScaleStart: (details) => scaleCurrentHeight = -1,
              onScaleUpdate: (details) {
                if (details.pointerCount == 1) {
                  final pos = details.focalPointDelta;
                  setState(() {
                    xPosition = _isXCoordinateMoreThanScreenWidth(
                            pos, screenWidth)
                        ? screenWidth -
                            containerWidth // stick to right edge of the screen
                        : _isXCoordinateLessThanZero(pos)
                            ? 0 // stick to left edge of the screen
                            : xPosition + pos.dx;
                    yPosition = _isYCoordinateMoreThanScreenHeight(
                            pos, widget.height)
                        ? widget.height -
                            containerHeight // stick to bottom edge of the screen
                        : _isYCoordinateLessThanZero(pos)
                            ? 0 // stick to top edge of the screen
                            : yPosition + pos.dy;
                  });
                } else if (details.pointerCount == 2) {
                  if (scaleCurrentHeight == -1) {
                    scaleCurrentHeight = containerHeight;
                  }
                  final realScale =
                      (scaleCurrentHeight * details.scale) / containerHeight;
                  print(realScale);
                  final oldWidth = containerWidth;
                  final oldHeight = containerHeight;
                  setState(() {
                    rotateAngle = details.rotation; // set rotation
                    if (containerWidth * realScale < minimumContainerWidth ||
                        containerHeight * realScale < minimumContainerHeight) {
                      return;
                    } else {
                      containerWidth = containerWidth * realScale;
                      containerHeight = containerHeight * realScale;
                    }
                    xPosition = xPosition - (containerWidth - oldWidth) / 2;
                    yPosition = yPosition - (containerHeight - oldHeight) / 2;
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
          for (_HandlePosition position in _HandlePosition.values)
            if (position != _HandlePosition.middleCenter)
              Positioned(
                left: getHandleLeft(position),
                top: getHandleTop(position),
                child: GestureDetector(
                  onPanUpdate: (details) {
                    setState(() {
                      if (position == _HandlePosition.left) {
                        if (containerWidth <= minimumContainerWidth &&
                            details.delta.dx > 0) {
                          //container genişliği minimum genişlikten küçükse ve sola doğru kaydırma yapılıyorsa
                          containerWidth = minimumContainerWidth;
                          return;
                        }
                        containerWidth -= details.delta.dx;
                        xPosition += details.delta.dx;
                      } else if (position == _HandlePosition.right) {
                        if (containerWidth <= minimumContainerWidth &&
                            details.delta.dx < 0) {
                          //container genişliği minimum genişlikten küçükse ve sağa doğru kaydırma yapılıyorsa
                          containerWidth = minimumContainerWidth;
                          return;
                        }
                        containerWidth += details.delta.dx;
                      } else if (position == _HandlePosition.top) {
                        if (containerHeight <= minimumContainerHeight &&
                            details.delta.dy > 0) {
                          //container yüksekliği minimum yükseklikten küçükse ve yukarı doğru kaydırma yapılıyorsa
                          containerHeight = minimumContainerHeight;
                          return;
                        }
                        if (yPosition < 0) {
                          //eğer container en yukarı kaydırıldıysa yPosition 0.1 sabitler
                          yPosition = 0.1;
                        } else {
                          print('set height ${details.delta.dy}');
                          if (yPosition == 0.1 && details.delta.dy > 0) {
                            //eğer container en yukarı kaydırıldıysa ve aşağı doğru kaydırma yapılıyorsa
                            containerHeight -= details.delta.dy;
                            yPosition += details.delta.dy;
                          } else if (yPosition == 0.1) {
                            //eğer container en yukarı kaydırıldıysa ve yukarı doğru kaydırma yapılıyorsa
                            return;
                          }
                          containerHeight -= details.delta.dy;
                          yPosition += details.delta.dy;
                        }
                      } else if (position == _HandlePosition.bottom) {
                        if (containerHeight <= minimumContainerHeight &&
                            details.delta.dy < 0) {
                          //container yüksekliği minimum yükseklikten küçükse ve aşağı doğru kaydırma yapılıyorsa
                          containerHeight = minimumContainerHeight;
                          return;
                        }
                        if (yPosition + containerHeight + details.delta.dy >
                            widget.height) {
                          //eğer container en aşağı kaydırıldıysa container yüksekliği sabit kalır
                          containerHeight = widget.height - yPosition;
                        } else {
                          containerHeight += details.delta.dy;
                        }
                      }
                    });
                  },
                  child: _HandleWidget(
                    handlePosition: position,
                    height: getHandleWidgetHeight(position),
                    width: getHandleWidgetWidth(position),
                  ),
                ),
              ),
        ],
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
      case _HandlePosition.middleCenter:
        return containerHeight;
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
      case _HandlePosition.middleCenter:
        return containerWidth / 7;
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
      case _HandlePosition.middleCenter:
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
      case _HandlePosition.middleCenter:
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
  middleCenter,
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
