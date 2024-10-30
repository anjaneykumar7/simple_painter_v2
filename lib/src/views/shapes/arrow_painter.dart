import 'dart:math';

import 'package:flutter/material.dart';

class ArrowPainter extends CustomPainter {
  // Yükseklik

  ArrowPainter({
    required this.lineColor,
    required this.thickness,
  });
  final Color lineColor;
  final double thickness;

  @override
  void paint(Canvas canvas, Size size) {
    const angle = pi * 2;
    final paint = Paint()
      ..color = lineColor
      ..strokeWidth = thickness
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Ok uzunluğu: genişlik ve yükseklikten daha küçük olanın %60'ı kadar
    final arrowLength = size.width;

    // Oku soldan başlayacak şekilde başlat
    final startPoint = Offset(0, size.height / 2);
    final endPoint = Offset(
      startPoint.dx + arrowLength * cos(angle),
      startPoint.dy + arrowLength * sin(angle),
    );

    // Ana gövde çizimi
    canvas.drawLine(startPoint, endPoint, paint);

    // Okun uçlarını çizmek için iki kısa çizgi (ok başı)
    var headHeight = size.height; // Okun başının boyutu, ok yüksekliğine bağlı
    const angleOffset = pi / 6; // Ok başının açısı

    // Genişliği hesaplıyoruz.
    var headWidth = headHeight * cos(angleOffset);
    if (headWidth > arrowLength) {
      headHeight = arrowLength / cos(angleOffset);
      headWidth = arrowLength;
    }

    final arrowLeft = Offset(
      endPoint.dx + headHeight * cos(angle + pi - angleOffset),
      endPoint.dy + headHeight * sin(angle + pi - angleOffset),
    );
    final arrowRight = Offset(
      endPoint.dx + headHeight * cos(angle + pi + angleOffset),
      endPoint.dy + headHeight * sin(angle + pi + angleOffset),
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
