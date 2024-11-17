import 'package:flutter/material.dart';

class BrushSettings {
  const BrushSettings({
    required this.color,
    required this.size,
  });

  final Color color;
  final double size;

  BrushSettings copyWith({
    Color? color,
    double? size,
  }) {
    return BrushSettings(
      color: color ?? this.color,
      size: size ?? this.size,
    );
  }
}
