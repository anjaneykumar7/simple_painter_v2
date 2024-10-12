import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_painter/src/controllers/items/painter_item.dart';
import 'package:flutter_painter/src/controllers/settings/layer_settings.dart';
import 'package:flutter_painter/src/models/position_model.dart';
import 'package:flutter_painter/src/models/size_model.dart';

class ImageItem extends PainterItem {
  ImageItem({
    required this.image,
    required super.position,
    required super.layer,
    this.textStyle = const TextStyle(fontSize: 16, color: Colors.black),
    this.textAlign = TextAlign.center,
    this.enableGradientColor = false,
    this.gradientStartColor = Colors.black,
    this.gradientEndColor = Colors.white,
    this.gradientBegin = Alignment.centerLeft,
    this.gradientEnd = Alignment.centerRight,
    this.gradientOpacity = 1.0,
    this.fit = BoxFit.contain,
    super.id,
    super.size,
    super.enabled = true,
    super.rotation,
  });

  final Uint8List image;
  final TextStyle textStyle;
  final TextAlign textAlign;
  final bool enableGradientColor;
  final Color gradientStartColor;
  final Color gradientEndColor;
  final AlignmentGeometry gradientBegin;
  final AlignmentGeometry gradientEnd;
  final double gradientOpacity;
  final BoxFit fit;

  @override
  ImageItem copyWith({
    Uint8List? image,
    TextStyle? textStyle,
    TextAlign? textAlign,
    bool? enableGradientColor,
    Color? gradientStartColor,
    Color? gradientEndColor,
    AlignmentGeometry? gradientBegin,
    AlignmentGeometry? gradientEnd,
    double? gradientOpacity,
    PositionModel? position,
    LayerSettings? layer,
    SizeModel? size,
    double? rotation,
    bool? enabled,
  }) {
    return ImageItem(
      id: id,
      image: image ?? this.image,
      textStyle: textStyle ?? this.textStyle,
      textAlign: textAlign ?? this.textAlign,
      enableGradientColor: enableGradientColor ?? this.enableGradientColor,
      gradientStartColor: gradientStartColor ?? this.gradientStartColor,
      gradientEndColor: gradientEndColor ?? this.gradientEndColor,
      gradientBegin: gradientBegin ?? this.gradientBegin,
      gradientEnd: gradientEnd ?? this.gradientEnd,
      gradientOpacity: gradientOpacity ?? this.gradientOpacity,
      position: position ?? this.position,
      layer: layer ?? this.layer,
      rotation: rotation ?? this.rotation,
      size: size ?? this.size,
      enabled: enabled ?? this.enabled,
    );
  }
}
