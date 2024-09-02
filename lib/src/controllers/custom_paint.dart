import 'dart:ui' as ui;

import 'package:flutter/material.dart';

class PainterCustomPaint extends CustomPainter {
  PainterCustomPaint({
    required this.paths,
    required this.points,
    required this.isErasing,
    required this.backgroundImage,
    required this.color,
  });

  final List<List<Offset?>> paths;
  final List<Offset?> points;
  final bool isErasing;
  final ui.Image? backgroundImage; // Arka plan resmi
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 5.0;

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
          canvas.drawLine(path[i]!, path[i + 1]!, paint);
        }
      }
    }

    // Kullanıcının geçici yolunu çiz
    for (var i = 0; i < points.length - 1; i++) {
      if (points[i] != null && points[i + 1] != null) {
        canvas.drawLine(points[i]!, points[i + 1]!, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
