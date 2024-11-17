import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_painter/src/models/brush_model.dart';

class PainterCustomPaint extends CustomPainter {
  PainterCustomPaint({
    required this.paths,
    required this.points,
    required this.isErasing,
    required this.backgroundImage,
  });

  final List<List<DrawModel?>> paths;
  final List<DrawModel?> points;
  final bool isErasing;
  final ui.Image? backgroundImage;
  @override
  void paint(Canvas canvas, Size size) {
    Paint paint(Color color, double strokeWidth) {
      return Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = strokeWidth;
    }

    final backgroundPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);

    // Arka plan resmi varsa çiz
    if (backgroundImage != null) {
      canvas.drawImageRect(
        backgroundImage!,
        Rect.fromLTWH(
          0,
          0,
          backgroundImage!.width.toDouble(),
          backgroundImage!.height.toDouble(),
        ),
        rect,
        Paint(),
      );
    } else {
      // Arka plan dikdörtgenini boyar
      canvas.drawRect(rect, backgroundPaint);
    }

    // Çizim yollarını çiz
    for (final path in paths) {
      if (path.isEmpty) continue;

      for (var i = 0; i < path.length - 1; i++) {
        if (path[i] != null && path[i + 1] != null) {
          canvas.drawLine(path[i]!.offset, path[i + 1]!.offset,
              paint(path[i]!.color, path[i]!.strokeWidth));
        }
      }
    }

    // Kullanıcının geçici yolunu çiz
    for (var i = 0; i < points.length - 1; i++) {
      if (points[i] != null && points[i + 1] != null) {
        canvas.drawLine(points[i]!.offset, points[i + 1]!.offset,
            paint(points[i]!.color, points[i]!.strokeWidth));
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
