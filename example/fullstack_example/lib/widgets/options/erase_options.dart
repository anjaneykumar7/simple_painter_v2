import 'package:flutter/material.dart';
import 'package:fullstack_example/widgets/options/options.dart';
import 'package:simple_painter/simple_painter.dart';

class EraseOptions extends StatelessWidget {
  const EraseOptions({required this.controller, super.key});
  final PainterController controller;
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 160,
      child: listView(
        [
          title('Erase Options'),
          size,
        ],
      ),
    );
  }

  Widget get size {
    return doubleSwitch(
      'Size (${(controller.value.brushSize / 100).toStringAsFixed(0)}px)',
      controller.value.brushSize / 100,
      1,
      (value) {
        controller.changeBrushValues(
          size: value * 100,
        );
      },
    );
  }
}
