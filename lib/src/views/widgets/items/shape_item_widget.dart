import 'package:flutter/material.dart';
import 'package:flutter_painter/flutter_painter.dart';
import 'package:flutter_painter/src/controllers/paint_actions/main/position_action.dart';
import 'package:flutter_painter/src/controllers/paint_actions/main/rotate_action.dart';
import 'package:flutter_painter/src/controllers/paint_actions/main/size_action.dart';
import 'package:flutter_painter/src/models/position_model.dart';
import 'package:flutter_painter/src/models/size_model.dart';
import 'package:flutter_painter/src/views/shapes/arrow_painter.dart';
import 'package:flutter_painter/src/views/shapes/circle_painter.dart';
import 'package:flutter_painter/src/views/shapes/doouble_arrow_painter.dart';
import 'package:flutter_painter/src/views/shapes/line_painter.dart';
import 'package:flutter_painter/src/views/shapes/rectangle_painter.dart';
import 'package:flutter_painter/src/views/shapes/star_painter.dart';
import 'package:flutter_painter/src/views/shapes/triangle_painter.dart';
import 'package:flutter_painter/src/views/widgets/measure_size.dart';
import 'package:flutter_painter/src/views/widgets/painter_container.dart';

class ShapeItemWidget extends StatefulWidget {
  const ShapeItemWidget({
    required this.item,
    required this.height,
    required this.painterController,
    super.key,
    this.onPositionChange,
    this.onSizeChange,
    this.onRotationChange,
  });
  final ShapeItem item;
  final double height;
  final void Function(PositionModel)? onPositionChange;
  final void Function(PositionModel, SizeModel)? onSizeChange;
  final void Function(double)? onRotationChange;

  final PainterController painterController;
  @override
  State<ShapeItemWidget> createState() => _ShapeItemWidgetState();
}

class _ShapeItemWidgetState extends State<ShapeItemWidget> {
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
          minimumContainerHeight: 1,
          minimumContainerWidth: 1,
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
          centerChild: true,
          child: MeasureSize(
            onChange: (size) {
              if (widgetHeight != null) return;
              setState(() {
                widgetHeight = size.height;
              });
            },
            child: SizedBox(
              width: double.infinity,
              child: shape,
            ),
          ),
        );
      },
    );
  }

  Widget get shape => SizedBox(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return CustomPaint(
              size: Size(
                constraints.maxWidth,
                constraints.maxHeight,
              ),
              painter: returnPainter(
                thickness: widget.item.thickness,
                backgroundColor: widget.item.backgroundColor,
                width: constraints.maxWidth,
                height: constraints.maxHeight,
                lineColor: widget.item.lineColor,
              ),
            );
          },
        ),
      );

  CustomPainter returnPainter({
    required double thickness,
    required Color backgroundColor,
    required double width,
    required double height,
    required Color lineColor,
  }) {
    if (widget.item.shapeType == ShapeType.arrow) {
      return ArrowPainter(
        thickness: thickness,
        lineColor: lineColor,
      );
    } else if (widget.item.shapeType == ShapeType.doubleArrow) {
      return DoubleArrowPainter(
        thickness: thickness,
        lineColor: lineColor,
      );
    } else if (widget.item.shapeType == ShapeType.rectangle) {
      return RectanglePainter(
        thickness: thickness,
        lineColor: lineColor,
        backgroundColor: backgroundColor,
      );
    } else if (widget.item.shapeType == ShapeType.triangle) {
      return TrianglePainter(
        thickness: thickness,
        lineColor: lineColor,
        backgroundColor: backgroundColor,
      );
    } else if (widget.item.shapeType == ShapeType.star) {
      return StarPainter(
        thickness: thickness,
        lineColor: lineColor,
        backgroundColor: backgroundColor,
      );
    } else if (widget.item.shapeType == ShapeType.circle) {
      return CirclePainter(
        thickness: thickness,
        lineColor: lineColor,
        backgroundColor: backgroundColor,
      );
    } else {
      return LinePainter(
        thickness: thickness,
        lineColor: lineColor,
      );
    }
  }
}
