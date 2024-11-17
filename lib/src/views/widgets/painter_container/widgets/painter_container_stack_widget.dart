// ignore_for_file: unused_element

part of '../painter_container.dart';

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

  final void Function(
    double? scaleCurrentHeight,
    double? currentRotateAngle,
    double? rotateAngle,
    SizeModel? containerSize,
  ) pointerCount2Change;
  final void Function() onTap;
  final void Function() onScaleStart;
  final void Function(ScaleEndDetails) onScaleEnd;
  final void Function(PositionModel?, PositionModel?) onScaleUpdate;
  final Color? dragHandleColor;
  final void Function() handlePanEnd;
  final void Function(SizeModel containerSize, PositionModel? stackPosition)
      handlePanUpdate;
  final void Function(PositionModel, SizeModel, SizeModel) handleSizeChange;
  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: stackPosition.x,
      top: stackPosition.y,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: handleWidgetHeight,
          vertical: handleWidgetWidth,
        ),
        child: GestureDetector(
          onTap: onTap,
          onScaleStart: (details) => onScaleStart.call(),
          onScaleEnd: onScaleEnd.call,
          onScaleUpdate: (details) {
            if (details.pointerCount == 1) {
              gestureScaleUpdatePointer1(details);
            } else if (details.pointerCount == 2) {
              gestureScaleUpdatePointer2(details);
            }
          },
          child: Container(
            width: containerSize.width,
            height: containerSize.height,
            decoration: BoxDecoration(
              color: Colors.transparent,
              border: Border.all(
                color: selectedItem
                    ? dragHandleColor ?? Colors.blue
                    : Colors.transparent,
              ),
            ),
            child: initializeSize //eğer her zaman align çalışırsa
                //imagefill yapmak istediğimde
                //align widgetı olduğu için height olarak fit
                //yapamıyor, bunu düzeltmek içinde bir
                //kez align çalıştıktan sonra ana widgetı
                //döndürüyorum
                ? (centerChild != null &&
                        centerChild!) //widget her zaman ortaya
                    //alınmak istiyor
                    //ise (örneğin text widgetı)
                    ? Center(child: child)
                    : child
                : Align(child: child),
          ),
        ),
      ),
    );
  }

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

    final realScale =
        (scaleCurrentHeight * (details.scale)) / containerSize.height;

    final realRotateAngle = currentRotateAngle + details.rotation;
    final oldWidth = containerSize.width;
    final oldHeight = containerSize.height;

    pointerCount2Change.call(
      null,
      null,
      realRotateAngle,
      null,
    );
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
    final newStackXPosition = stackWidth / 2 - (containerSize.width / 2);
    final newStackYPosition = stackHeight / 2 - (containerSize.height / 2);

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

  void gestureScaleUpdatePointer1(ScaleUpdateDetails details) {
    final pos = details.focalPointDelta;
    final cosAngle = cos(rotateAngle);
    final sinAngle = sin(rotateAngle);

    final deltaX = pos.dx * cosAngle - pos.dy * sinAngle;
    final deltaY = pos.dx * sinAngle + pos.dy * cosAngle;

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
  }
}
