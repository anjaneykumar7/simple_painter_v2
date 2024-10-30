import 'package:flutter/material.dart';

class RectanglePainter extends CustomPainter {
  RectanglePainter({
    required this.lineColor,
    required this.thickness,
    required this.backgroundColor,
  });

  final Color lineColor;
  final Color backgroundColor;
  final double thickness;

  @override
  void paint(Canvas canvas, Size size) {
    // Arka plan için dolgu boyası
    final backgroundPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.fill;

    // Çerçeve için çizim boyası
    final borderPaint = Paint()
      ..color = lineColor
      ..strokeWidth = thickness
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final rect = Rect.fromLTWH(0, 0, size.width, size.height);

    // Arka planı doldur
    canvas
      ..drawRect(rect, backgroundPaint)
      // Dikdörtgenin kenar çizgilerini çiz
      ..drawRect(rect, borderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
