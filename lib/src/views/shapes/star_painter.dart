import 'dart:math';
import 'package:flutter/material.dart';

class StarPainter extends CustomPainter {
  StarPainter({
    required this.lineColor,
    required this.thickness,
    required this.backgroundColor,
  });

  final Color lineColor;
  final Color backgroundColor;
  final double thickness;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    // x ve y yönünde yarıçapları ayrı ayrı hesapla
    final outerRadiusX = size.width / 2;
    final outerRadiusY = size.height / 2;
    final innerRadiusX = outerRadiusX / 2.5;
    final innerRadiusY = outerRadiusY / 2.5;
    const angleStep = (2 * pi) / 5;

    // Arka plan için dolgu boyası
    final backgroundPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.fill;

    // Yıldız kenar çizgileri için boyama
    final borderPaint = Paint()
      ..color = lineColor
      ..strokeWidth = thickness
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();

    // Yıldızın köşe noktalarını belirleyerek path oluştur
    for (var i = 0; i < 5; i++) {
      final outerX = center.dx + outerRadiusX * cos(i * angleStep - pi / 2);
      final outerY = center.dy + outerRadiusY * sin(i * angleStep - pi / 2);
      final innerX =
          center.dx + innerRadiusX * cos((i + 0.5) * angleStep - pi / 2);
      final innerY =
          center.dy + innerRadiusY * sin((i + 0.5) * angleStep - pi / 2);

      if (i == 0) {
        path.moveTo(outerX, outerY);
      } else {
        path.lineTo(outerX, outerY);
      }
      path.lineTo(innerX, innerY);
    }
    path.close();

    // Arka plan rengini doldur
    canvas
      ..drawPath(path, backgroundPaint)
      // Yıldızın kenar çizgilerini çiz
      ..drawPath(path, borderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
