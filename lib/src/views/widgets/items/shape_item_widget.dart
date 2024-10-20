import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_painter/flutter_painter.dart';
import 'package:flutter_painter/src/controllers/items/shape_item.dart';
import 'package:flutter_painter/src/controllers/paint_actions/main/position_action.dart';
import 'package:flutter_painter/src/controllers/paint_actions/main/rotate_action.dart';
import 'package:flutter_painter/src/controllers/paint_actions/main/size_action.dart';
import 'package:flutter_painter/src/models/position_model.dart';
import 'package:flutter_painter/src/models/size_model.dart';
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
        height: 50,
        child: LayoutBuilder(
          // Bu widget, mevcut alanı kullanmak için boyut belirleyecek
          builder: (context, constraints) {
            return CustomPaint(
              size: Size(
                constraints.maxWidth,
                constraints.maxHeight,
              ), // Expanded boyutlarına göre çizim yapacak
              painter: ArrowPainter(
                arrowColor: Colors.black,
                arrowThickness: 2,
                angle: 0,
                width: constraints.maxWidth,
                height: constraints.maxHeight,
              ),
            );
          },
        ),
      );
}

// class LinePainter extends CustomPainter {
//   @override
//   void paint(Canvas canvas, Size size) {
//     final paint = Paint()
//       ..color = Colors.black
//       ..strokeWidth = 2.0;

//     final startPoint = Offset(0, size.height / 2);
//     final endPoint = Offset(size.width, size.height / 2);

//     canvas.drawLine(startPoint, endPoint, paint);
//   }

//   @override
//   bool shouldRepaint(covariant CustomPainter oldDelegate) {
//     return false;
//   }
// }

class ArrowPainter extends CustomPainter {
  // Yükseklik

  ArrowPainter({
    required this.arrowColor,
    required this.arrowThickness,
    required this.angle,
    required this.width,
    required this.height,
  });
  final Color arrowColor;
  final double arrowThickness;
  final double angle; // Radyan cinsinden yön (0 = sağa, pi/2 = yukarı vb.)
  final double width; // Genişlik
  final double height;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = arrowColor
      ..strokeWidth = arrowThickness
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Ok uzunluğu: genişlik ve yükseklikten daha küçük olanın %60'ı kadar
    final arrowLength = width;

    // Oku soldan başlayacak şekilde başlat
    final startPoint = Offset(0, height / 2);
    final endPoint = Offset(
      startPoint.dx + arrowLength * cos(angle),
      startPoint.dy + arrowLength * sin(angle),
    );

    // Ana gövde çizimi
    canvas.drawLine(startPoint, endPoint, paint);

    // Okun uçlarını çizmek için iki kısa çizgi (ok başı)
    final headSize =
        arrowLength * 0.2; // Okun başının boyutu, ok uzunluğuna bağlı
    const angleOffset = pi / 6; // Ok başının açısı

    final arrowLeft = Offset(
      endPoint.dx + headSize * cos(angle + pi - angleOffset),
      endPoint.dy + headSize * sin(angle + pi - angleOffset),
    );
    final arrowRight = Offset(
      endPoint.dx + headSize * cos(angle + pi + angleOffset),
      endPoint.dy + headSize * sin(angle + pi + angleOffset),
    );

    // Okun başındaki iki çizgi
    canvas
      ..drawLine(endPoint, arrowLeft, paint)
      ..drawLine(endPoint, arrowRight, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true; // Her durumda yeniden çizer
  }
}
