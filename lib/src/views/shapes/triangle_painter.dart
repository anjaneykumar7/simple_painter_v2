import 'package:flutter/material.dart';

class TrianglePainter extends CustomPainter {
  TrianglePainter({
    required this.lineColor,
    required this.thickness,
    required this.width,
    required this.height,
    required this.backgroundColor,
  });

  final Color lineColor;
  final Color backgroundColor;
  final double thickness;
  final double width;
  final double height;

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

    final path = Path()
      ..moveTo(width / 2, 0)
      ..lineTo(0, height)
      ..lineTo(width, height)
      ..close();

    // Arka planı doldur
    canvas
      ..drawPath(path, backgroundPaint)
      // Üçgenin kenar çizgilerini çiz
      ..drawPath(path, borderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
