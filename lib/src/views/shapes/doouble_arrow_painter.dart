import 'dart:math';

import 'package:flutter/material.dart';

class DoubleArrowPainter extends CustomPainter {
  DoubleArrowPainter({
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

    // Okları çizecek başlangıç noktaları
    final startPointLeft = Offset(0, size.height / 2);
    final startPointRight = Offset(size.width, size.height / 2);

    // Sağ tarafa olan ok
    final endPointRight = Offset(
      startPointLeft.dx + arrowLength * cos(angle),
      startPointLeft.dy + arrowLength * sin(angle),
    );

    // Sol tarafa olan ok
    final endPointLeft = Offset(
      startPointRight.dx - arrowLength * cos(angle),
      startPointRight.dy - arrowLength * sin(angle),
    );

    // Sağ tarafa ok gövdesi
    canvas
      ..drawLine(startPointLeft, endPointRight, paint)

      // Sol tarafa ok gövdesi
      ..drawLine(startPointRight, endPointLeft, paint);

    // Ok uçları için baş boyutu ve açı farkı
    var headHeight = size.height; // Okun başının boyutu, ok yüksekliğine bağlı
    const angleOffset = pi / 6; // Ok başının açısı

    // Genişliği hesaplıyoruz.
    var headWidth = headHeight * cos(angleOffset);
    if (headWidth > arrowLength / 2.1) {
      // .1 eklenmesi iki okun tamamen birleşmemesi için
      headHeight = arrowLength / 2.1 / cos(angleOffset);
      headWidth = arrowLength;
    }
    // Sağ taraf ok başı
    final arrowRightHeadLeft = Offset(
      endPointRight.dx + headHeight * cos(angle + pi - angleOffset),
      endPointRight.dy + headHeight * sin(angle + pi - angleOffset),
    );
    final arrowRightHeadRight = Offset(
      endPointRight.dx + headHeight * cos(angle + pi + angleOffset),
      endPointRight.dy + headHeight * sin(angle + pi + angleOffset),
    );

    // Sol taraf ok başı
    final arrowLeftHeadLeft = Offset(
      endPointLeft.dx - headHeight * cos(angle + pi - angleOffset),
      endPointLeft.dy - headHeight * sin(angle + pi - angleOffset),
    );
    final arrowLeftHeadRight = Offset(
      endPointLeft.dx - headHeight * cos(angle + pi + angleOffset),
      endPointLeft.dy - headHeight * sin(angle + pi + angleOffset),
    );

    // Sağ taraf ok başını çiz
    canvas
      ..drawLine(endPointRight, arrowRightHeadLeft, paint)
      ..drawLine(endPointRight, arrowRightHeadRight, paint)

      // Sol taraf ok başını çiz

      ..drawLine(endPointLeft, arrowLeftHeadLeft, paint)
      ..drawLine(endPointLeft, arrowLeftHeadRight, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true; // Her durumda yeniden çizer
  }
}
