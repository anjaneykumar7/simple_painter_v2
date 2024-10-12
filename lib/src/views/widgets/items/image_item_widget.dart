import 'package:flutter/material.dart';
import 'package:flutter_painter/flutter_painter.dart';
import 'package:flutter_painter/src/controllers/items/image_item.dart';
import 'package:flutter_painter/src/controllers/paint_actions/main/position_action.dart';
import 'package:flutter_painter/src/controllers/paint_actions/main/rotate_action.dart';
import 'package:flutter_painter/src/controllers/paint_actions/main/size_action.dart';
import 'package:flutter_painter/src/models/position_model.dart';
import 'package:flutter_painter/src/models/size_model.dart';
import 'package:flutter_painter/src/views/widgets/measure_size.dart';
import 'package:flutter_painter/src/views/widgets/painter_container.dart';

class ImageItemWidget extends StatefulWidget {
  const ImageItemWidget({
    required this.item,
    required this.height,
    required this.painterController,
    super.key,
    this.onPositionChange,
    this.onSizeChange,
    this.onRotationChange,
  });
  final ImageItem item;
  final double height;
  final void Function(PositionModel)? onPositionChange;
  final void Function(PositionModel, SizeModel)? onSizeChange;
  final void Function(double)? onRotationChange;

  final PainterController painterController;
  @override
  State<ImageItemWidget> createState() => _ImageItemWidgetState();
}

class _ImageItemWidgetState extends State<ImageItemWidget> {
  double? widgetHeight;
  ValueNotifier<PositionModel> position =
      ValueNotifier(const PositionModel(x: 50, y: 50));
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: position,
      builder: (context, value, child) {
        return PainterContainer(
          selectedItem: widget.painterController.value.selectedItem != null &&
              widget.painterController.value.selectedItem?.id == widget.item.id,
          height: widget.height,
          minimumContainerHeight: widgetHeight,
          position: widget.item.position,
          rotateAngle: widget.item.rotation,
          size: widget.item.size,
          selectedItemChange: () {
            widget.painterController.value = widget.painterController.value
                .copyWith(selectedItem: widget.item);
          },
          onPositionChange: (oldPosition, newPosition) {
            position.value = newPosition;
            widget.onPositionChange?.call(newPosition);
          },
          onRotateAngleChange: (oldRotateAngle, newRotateAngle) {
            widget.onRotationChange?.call(newRotateAngle);
          },
          onSizeChange: (newPosition, oldSize, newSize) {
            widget.onSizeChange?.call(newPosition, newSize);
          },
          onPositionChangeEnd: (
            oldPosition,
            newPosition,
          ) {
            widget.painterController.addAction(
              ActionPosition(
                item: widget.item,
                oldPosition: oldPosition,
                newPosition: newPosition,
                timestamp: DateTime.now(),
                actionType: ActionType.positionItem,
              ),
            );
          },
          onRotateAngleChangeEnd: (oldRotateAngle, newRotateAngle) {
            widget.painterController.addAction(
              ActionRotation(
                item: widget.item,
                oldRotateAngle: oldRotateAngle,
                newRotateAngle: newRotateAngle,
                timestamp: DateTime.now(),
                actionType: ActionType.rotationItem,
              ),
            );
          },
          onSizeChangeEnd: (oldPosition, oldSize, newPosition, newSize) {
            widget.painterController.addAction(
              ActionSize(
                item: widget.item,
                oldPosition: oldPosition,
                newPosition: newPosition,
                oldSize: oldSize,
                newSize: newSize,
                timestamp: DateTime.now(),
                actionType: ActionType.sizeItem,
              ),
            );
          },
          enabled: widgetHeight != null,
          child: MeasureSize(
            onChange: (size) {
              if (widgetHeight != null) return;
              setState(() {
                widgetHeight = size.height;
              });
            },
            child: SizedBox(
              width: double.infinity,
              child: widget.item.enableGradientColor
                  ? Stack(
                      children: [
                        ShaderMask(
                          blendMode: BlendMode.srcIn,
                          shaderCallback: (Rect bounds) {
                            return LinearGradient(
                              begin: widget.item.gradientBegin,
                              end: widget.item.gradientEnd,
                              colors: [
                                widget.item.gradientStartColor,
                                widget.item.gradientEndColor,
                              ],
                              stops: const [0.0, 1.0],
                            ).createShader(bounds);
                          },
                          child: image,
                        ),
                        if (widget.item.gradientOpacity > 0)
                          Positioned.fill(
                            child: Opacity(
                              opacity: widget.item.gradientOpacity,
                              child: image,
                            ),
                          ),
                      ],
                    )
                  : image,
            ),
          ),
        );
      },
    );
  }

  Widget get image => Image(
        image: MemoryImage(widget.item.image),
        fit: widget.item.fit,
      );
}
