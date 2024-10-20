import 'package:flutter/material.dart';
import 'package:flutter_painter/src/controllers/items/painter_item.dart';
import 'package:flutter_painter/src/controllers/settings/layer_settings.dart';
import 'package:flutter_painter/src/models/position_model.dart';
import 'package:flutter_painter/src/models/size_model.dart';

class TextItem extends PainterItem {
  TextItem({
    required this.text,
    required super.position,
    required super.layer,
    this.textStyle = const TextStyle(
      fontSize: 16,
      color: Colors.black,
      backgroundColor: Colors.transparent,
    ),
    this.textAlign = TextAlign.center,
    this.enableGradientColor = false,
    this.gradientStartColor = Colors.black,
    this.gradientEndColor = Colors.white,
    this.gradientBegin = Alignment.centerLeft,
    this.gradientEnd = Alignment.centerRight,
    super.id,
    super.size,
    super.enabled = true,
    super.rotation,
  });

  final String text;
  final TextStyle textStyle;
  final TextAlign textAlign;
  final bool enableGradientColor;
  final Color gradientStartColor;
  final Color gradientEndColor;
  final AlignmentGeometry gradientBegin;
  final AlignmentGeometry gradientEnd;

  @override
  TextItem copyWith({
    String? text,
    TextStyle? textStyle,
    TextAlign? textAlign,
    bool? enableGradientColor,
    Color? gradientStartColor,
    Color? gradientEndColor,
    AlignmentGeometry? gradientBegin,
    AlignmentGeometry? gradientEnd,
    PositionModel? position,
    LayerSettings? layer,
    SizeModel? size,
    double? rotation,
    bool? enabled,
  }) {
    return TextItem(
      id: id,
      text: text ?? this.text,
      textStyle: textStyle ?? this.textStyle,
      textAlign: textAlign ?? this.textAlign,
      enableGradientColor: enableGradientColor ?? this.enableGradientColor,
      gradientStartColor: gradientStartColor ?? this.gradientStartColor,
      gradientEndColor: gradientEndColor ?? this.gradientEndColor,
      gradientBegin: gradientBegin ?? this.gradientBegin,
      gradientEnd: gradientEnd ?? this.gradientEnd,
      position: position ?? this.position,
      layer: layer ?? this.layer,
      rotation: rotation ?? this.rotation,
      size: size ?? this.size,
      enabled: enabled ?? this.enabled,
    );
  }
}
