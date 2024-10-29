import 'dart:math';

import 'package:flutter/material.dart';

class ArrowPainter extends CustomPainter {
  // Yükseklik

  ArrowPainter({
    required this.lineColor,
    required this.thickness,
    required this.width,
    required this.height,
  });
  final Color lineColor;
  final double thickness;
  final double width; // Genişlik
  final double height;

  @override
  void paint(Canvas canvas, Size size) {
    const angle = pi * 2;
    final paint = Paint()
      ..color = lineColor
      ..strokeWidth = thickness
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
