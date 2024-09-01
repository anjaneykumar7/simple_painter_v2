import 'package:flutter/material.dart';

class TextSettings {
  const TextSettings({
    this.textStyle = const TextStyle(
      fontSize: 14,
      color: Colors.black,
    ),
    this.focusNode,
  });

  final TextStyle textStyle;
  final FocusNode? focusNode;
}
