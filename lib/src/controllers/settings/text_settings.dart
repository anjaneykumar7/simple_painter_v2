import 'package:flutter/material.dart';

class TextSettings {
  const TextSettings({
    this.textStyle,
    this.textAlign,
    this.enableGradientColor,
    this.gradientStartColor,
    this.gradientEndColor,
    this.gradientBegin,
    this.gradientEnd,
  });

  final TextStyle? textStyle;
  final TextAlign? textAlign;
  final bool? enableGradientColor;
  final Color? gradientStartColor;
  final Color? gradientEndColor;
  final AlignmentGeometry? gradientBegin;
  final AlignmentGeometry? gradientEnd;
}
