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
    final sliderValue = ValueNotifier(controller.value.brushSize / 100);
    return ValueListenableBuilder(
      valueListenable: sliderValue,
      builder: (context, sliderVal, child) {
        return Row(
          children: [
            title('Size (${(sliderVal * 100).toStringAsFixed(0)}px)'),
            const Spacer(),
            Slider(
              value: sliderVal,
              onChanged: (value) {
                sliderValue.value = value;
              },
              onChangeEnd: (value) {
                controller.changeBrushValues(
                  size: value * 100,
                );
              },
            ),
          ],
        );
      },
    );
  }
}
