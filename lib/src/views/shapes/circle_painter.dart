import 'package:flutter/material.dart';

class CirclePainter extends CustomPainter {
  CirclePainter({
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

    // Dairenin sınırlarını belirleyen dikdörtgen
    //(genişliğe ve yüksekliğe göre esneyen oval)
    final ovalRect = Rect.fromLTWH(0, 0, size.width, size.height);

    // Arka planı doldur
    canvas
      ..drawOval(ovalRect, backgroundPaint)
      // Ovalin kenar çizgilerini çiz
      ..drawOval(ovalRect, borderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
