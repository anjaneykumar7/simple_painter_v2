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
        child: LayoutBuilder(
          // Bu widget, mevcut alanı kullanmak için boyut belirleyecek
          builder: (context, constraints) {
            print(constraints.maxHeight);
            return CustomPaint(
              size: Size(
                constraints.maxWidth,
                constraints.maxHeight,
              ), // Expanded boyutlarına göre çizim yapacak
              painter: StarPainter(
                  width: constraints.maxWidth,
                  height: constraints.maxHeight,
                  starColor: Colors.black,
                  starBorderThickness: 2),
            );
          },
        ),
      );
}

class StarPainter extends CustomPainter {
  StarPainter({
    required this.starColor,
    required this.starBorderThickness,
    required this.width,
    required this.height,
  });

  final Color starColor;
  final double starBorderThickness;
  final double width;
  final double height;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = starColor
      ..strokeWidth = starBorderThickness
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Yıldızın merkez noktası
    final center = Offset(width / 2, height / 2);

    // Yıldızın dış ve iç yarıçapları
    final outerRadius = min(width, height) / 2;
    final innerRadius = outerRadius / 2.5;

    final path = Path();
    final angleStep = (2 * pi) / 5; // 5 köşeli yıldız için açı adımı

    // Dış köşelerin hesaplanması
    for (int i = 0; i < 5; i++) {
      final outerX = center.dx + outerRadius * cos(i * angleStep - pi / 2);
      final outerY = center.dy + outerRadius * sin(i * angleStep - pi / 2);
      final innerX = center.dx +
          innerRadius *
              cos((i + 0.5) * angleStep - pi / 2); // İç köşelerin hesaplanması
      final innerY = center.dy +
          innerRadius *
              sin((i + 0.5) * angleStep - pi / 2); // İç köşelerin hesaplanması

      if (i == 0) {
        path.moveTo(outerX, outerY); // İlk noktaya git
      } else {
        path.lineTo(outerX, outerY); // Dış köşeleri bağla
      }
      path.lineTo(innerX, innerY); // İç köşelere bağla
    }
    path.close();

    // Yıldızın dış hatlarını çiz
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

class TrianglePainter extends CustomPainter {
  TrianglePainter({
    required this.triangleColor,
    required this.triangleBorderThickness,
    required this.width,
    required this.height,
  });

  final Color triangleColor;
  final double triangleBorderThickness;
  final double width;
  final double height;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = triangleColor
      ..strokeWidth = triangleBorderThickness
      ..style = PaintingStyle.stroke // Çerçeve için
      ..strokeCap = StrokeCap.round;

    // Üçgenin köşelerini hesapla
    final path = Path()
      ..moveTo(width / 2, 0) // Üst tepe noktası
      ..lineTo(0, height) // Sol alt köşe
      ..lineTo(width, height) // Sağ alt köşe
      ..close(); // Üçgeni kapat

    // Üçgeni çiz
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

class LinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..strokeWidth = 2.0;

    final startPoint = Offset(0, size.height / 2);
    final endPoint = Offset(size.width, size.height / 2);

    canvas.drawLine(startPoint, endPoint, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}

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

class DoubleArrowPainter extends CustomPainter {
  DoubleArrowPainter({
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

    // Okları çizecek başlangıç noktaları
    final startPointLeft = Offset(0, height / 2);
    final startPointRight = Offset(width, height / 2);

    // Sağ tarafa olan ok
    final endPointRight = Offset(
      startPointLeft.dx + arrowLength * cos(angle),
      startPointLeft.dy + arrowLength * sin(angle),
    );

    // Sol tarafa olan ok
    final endPointLeft = Offset(
      startPointRight.dx - arrowLength * cos(angle),
      startPointRight.dy - arrowLength * sin(angle),
    );

    // Sağ tarafa ok gövdesi
    canvas.drawLine(startPointLeft, endPointRight, paint);

    // Sol tarafa ok gövdesi
    canvas.drawLine(startPointRight, endPointLeft, paint);

    // Ok uçları için baş boyutu ve açı farkı
    final headSize = arrowLength * 0.2; // Okun başının boyutu
    const angleOffset = pi / 6; // Ok başının açısı

    // Sağ taraf ok başı
    final arrowRightHeadLeft = Offset(
      endPointRight.dx + headSize * cos(angle + pi - angleOffset),
      endPointRight.dy + headSize * sin(angle + pi - angleOffset),
    );
    final arrowRightHeadRight = Offset(
      endPointRight.dx + headSize * cos(angle + pi + angleOffset),
      endPointRight.dy + headSize * sin(angle + pi + angleOffset),
    );

    // Sol taraf ok başı
    final arrowLeftHeadLeft = Offset(
      endPointLeft.dx - headSize * cos(angle + pi - angleOffset),
      endPointLeft.dy - headSize * sin(angle + pi - angleOffset),
    );
    final arrowLeftHeadRight = Offset(
      endPointLeft.dx - headSize * cos(angle + pi + angleOffset),
      endPointLeft.dy - headSize * sin(angle + pi + angleOffset),
    );

    // Sağ taraf ok başını çiz
    canvas
      ..drawLine(endPointRight, arrowRightHeadLeft, paint)
      ..drawLine(endPointRight, arrowRightHeadRight, paint)

      // Sol taraf ok başını çiz

      ..drawLine(endPointLeft, arrowLeftHeadLeft, paint)
      ..drawLine(endPointLeft, arrowLeftHeadRight, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true; // Her durumda yeniden çizer
  }
}

class RectanglePainter extends CustomPainter {
  RectanglePainter({
    required this.rectangleColor,
    required this.rectangleBorderThickness,
    required this.width,
    required this.height,
  });

  final Color rectangleColor;
  final double rectangleBorderThickness;
  final double width; // Dikdörtgenin genişliği
  final double height; // Dikdörtgenin yüksekliği

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = rectangleColor
      ..strokeWidth = rectangleBorderThickness
      ..style = PaintingStyle.stroke // Çerçeve çizmek için
      ..strokeCap = StrokeCap.round;

    // Dikdörtgenin başlangıç noktası (soldan üst köşe)
    final startPoint = Offset(0, 0);

    // Dikdörtgenin boyutu
    final rect = Rect.fromLTWH(startPoint.dx, startPoint.dy, width, height);

    // Dikdörtgeni çiz
    canvas.drawRect(rect, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true; // Her durumda yeniden çizer
  }
}
