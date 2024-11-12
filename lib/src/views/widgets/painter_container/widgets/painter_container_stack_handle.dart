part of '../painter_container.dart';

class _StackHandle extends StatelessWidget {
  const _StackHandle({
    required this.stackPosition,
    required this.containerSize,
    required this.oldContainerSize,
    required this.handleWidgetHeight,
    required this.handleWidgetWidth,
    required this.minimumContainerWidth,
    required this.minimumContainerHeight,
    required this.stackWidth,
    required this.stackHeight,
    required this.position,
    required this.height,
    required this.onPanEnd,
    required this.onPanUpdate,
    this.dragHandleColor,
    this.onSizeChange,
  });
  final PositionModel stackPosition;
  final SizeModel containerSize;
  final SizeModel oldContainerSize;
  final double handleWidgetHeight;
  final double handleWidgetWidth;
  final double minimumContainerWidth;
  final double minimumContainerHeight;
  final double stackWidth;
  final double stackHeight;
  final PositionModel position;
  final double height;
  final Color? dragHandleColor;
  final void Function() onPanEnd;
  final void Function(SizeModel containerSize, PositionModel? stackPosition)
      onPanUpdate;

  final void Function(
    PositionModel newPosition,
    SizeModel oldSize,
    SizeModel newSize,
  )? onSizeChange;
  @override
  Widget build(BuildContext context) {
    return Positioned(
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
                  onPanEnd: (details) => onPanEnd.call(),
                  onPanUpdate: (details) =>
                      gestureUpdate(details, handlePosition),
                  child: _HandleWidget(
                    handlePosition: handlePosition,
                    height: _getHandleWidgetHeight(
                      handlePosition,
                      handleWidgetHeight,
                      containerSize,
                    ),
                    width: _getHandleWidgetWidth(
                      handlePosition,
                      handleWidgetWidth,
                      containerSize,
                    ),
                    backgroundColor: dragHandleColor ?? Colors.blue,
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
    DragUpdateDetails details,
    _HandlePosition handlePosition,
  ) {
    {
      // endSizeControl = true;

      if (handlePosition == _HandlePosition.left) {
        stackLeftUpdate(details);
      } else if (handlePosition == _HandlePosition.right) {
        stackRightUpdate(details);
      } else if (handlePosition == _HandlePosition.top) {
        stackTopUpdate(details);
      } else if (handlePosition == _HandlePosition.bottom) {
        stackBottomUpdate(details);
      }
      if (onSizeChange != null) {
        onSizeChange?.call(
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
    }
  }

  void stackLeftUpdate(DragUpdateDetails details) {
    if (containerSize.width <= minimumContainerWidth && details.delta.dx > 0) {
      //container genişliği minimum genişlikten küçükse ve
      //ola doğru kaydırma yapılıyorsa

      onPanUpdate.call(
        containerSize.copyWith(
          width: minimumContainerWidth,
        ),
        null,
      );
      return;
    }

    onPanUpdate.call(
      containerSize.copyWith(
        width: containerSize.width - details.delta.dx,
      ),
      stackPosition.copyWith(
        x: stackPosition.x + details.delta.dx,
      ),
    );
  }

  void stackRightUpdate(DragUpdateDetails details) {
    if (containerSize.width <= minimumContainerWidth && details.delta.dx < 0) {
      //container genişliği minimum genişlikten küçükse ve
      //sağa doğru kaydırma yapılıyorsa

      onPanUpdate.call(
        containerSize.copyWith(
          width: minimumContainerWidth,
        ),
        null,
      );
      return;
    }
    onPanUpdate.call(
      containerSize.copyWith(
        width: containerSize.width + details.delta.dx,
      ),
      null,
    );
  }

  void stackTopUpdate(DragUpdateDetails details) {
    if (containerSize.height <= minimumContainerHeight &&
        details.delta.dy > 0) {
      //container yüksekliği minimum yükseklikten küçükse
      //ve yukarı doğru kaydırma yapılıyorsa

      onPanUpdate.call(
        containerSize.copyWith(
          height: minimumContainerHeight,
        ),
        null,
      );
      return;
    } else {
      onPanUpdate.call(
        containerSize.copyWith(
          height: containerSize.height - details.delta.dy,
        ),
        stackPosition.copyWith(
          y: stackPosition.y + details.delta.dy,
        ),
      );
    }
  }

  void stackBottomUpdate(DragUpdateDetails details) {
    if (containerSize.height <= minimumContainerHeight &&
        details.delta.dy < 0) {
      //container yüksekliği minimum yükseklikten küçükse
      //ve aşağı doğru kaydırma yapılıyorsa

      onPanUpdate.call(
        containerSize.copyWith(
          height: minimumContainerHeight,
        ),
        null,
      );
      return;
    }
    if (position.y + containerSize.height + details.delta.dy > height) {
      //eğer container en aşağı kaydırıldıysa container yüksekliği sabit kalır

      onPanUpdate.call(
        containerSize.copyWith(
          height: height - position.y,
        ),
        null,
      );
    } else {
      onPanUpdate.call(
        containerSize.copyWith(
          height: containerSize.height + details.delta.dy,
        ),
        null,
      );
    }
  }
}
