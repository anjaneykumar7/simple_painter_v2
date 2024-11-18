import 'package:flutter/material.dart';
import 'package:flutter_painter/flutter_painter.dart';
import 'package:fullstack_example/widgets/options/options.dart';

class BrushOptions extends StatelessWidget {
  const BrushOptions({required this.controller, super.key});
  final PainterController controller;
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 160,
      child: listView(
        [
          title('Brush Options'),
          size,
          color,
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

  Widget get color {
    final color = ValueNotifier(
      (controller.value.brushColor.red << 16 |
              controller.value.brushColor.green << 8 |
              controller.value.brushColor.blue)
          .toDouble(),
    );
    return Row(
      children: [
        title('Color'),
        const Spacer(),
        ValueListenableBuilder(
          valueListenable: color,
          builder: (context, colorVal, child) => Slider(
            value: colorVal,
            max: 0xFFFFFF.toDouble(),
            thumbColor: Color(colorVal.toInt())
                .withOpacity(controller.value.brushColor.opacity),
            onChanged: (value) {
              color.value = value;
            },
            onChangeEnd: (value) {
              final intValue = value.toInt();
              controller.changeBrushValues(
                color: Color(intValue)
                    .withOpacity(controller.value.brushColor.opacity),
              );
            },
          ),
        ),
      ],
    );
  }
}
