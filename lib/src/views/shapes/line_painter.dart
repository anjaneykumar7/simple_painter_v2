import 'package:flutter/material.dart';

class LinePainter extends CustomPainter {
  LinePainter({
    required this.lineColor,
    required this.thickness,
    required this.width,
    required this.height,
  });

  final Color lineColor;
  final double thickness;
  final double width;
  final double height;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = lineColor
      ..strokeWidth = thickness;

    // Çizginin başlangıç ve bitiş noktaları
    final startPoint = Offset(0, height / 2);
    final endPoint = Offset(width, height / 2);

    // Çizgiyi çiz
    canvas.drawLine(startPoint, endPoint, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }

  Size get size => Size(width, height);
}
