import 'dart:math';

import 'package:flutter/material.dart';

class CirclePainter extends CustomPainter {
  CirclePainter({
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

    // Dairenin merkezi, width ve height ile belirlenir
    final center = Offset(width / 2, height / 2);
    final radius = min(width, height) / 2;

    // Arka planı doldur
    canvas
      ..drawCircle(center, radius, backgroundPaint)
      // Dairenin kenar çizgilerini çiz
      ..drawCircle(center, radius, borderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
