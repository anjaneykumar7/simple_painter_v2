import 'package:flutter/material.dart';

class TrianglePainter extends CustomPainter {
  TrianglePainter({
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

    final path = Path()
      ..moveTo(size.width / 2, 0)
      ..lineTo(0, size.height)
      ..lineTo(size.width, size.height)
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
