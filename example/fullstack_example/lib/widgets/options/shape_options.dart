import 'package:flutter/material.dart';
import 'package:simple_painter/simple_painter.dart';
import 'package:fullstack_example/widgets/options/options.dart';

class ShapeOptions extends StatelessWidget {
  const ShapeOptions({required this.controller, required this.item, super.key});
  final PainterController controller;
  final ShapeItem item;
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 160,
      child: listView(
        [
          title('Shape Options'),
          lineColor,
          thickness,
          backgroundColor,
        ],
      ),
    );
  }

  bool get isShapeNotLineOrArrow =>
      item.shapeType != ShapeType.line &&
      item.shapeType != ShapeType.arrow &&
      item.shapeType != ShapeType.doubleArrow;

  Widget get lineColor {
    final color = ValueNotifier(
      (item.lineColor.red << 16 |
              item.lineColor.green << 8 |
              item.lineColor.blue)
          .toDouble(),
    );
    return Row(
      children: [
        title('Line Color'),
        const Spacer(),
        ValueListenableBuilder(
          valueListenable: color,
          builder: (context, colorVal, child) => Slider(
            value: colorVal,
            max: 0xFFFFFF.toDouble(),
            thumbColor:
                Color(colorVal.toInt()).withOpacity(item.lineColor.opacity),
            onChanged: (value) {
              color.value = value;
            },
            onChangeEnd: (value) {
              final intValue = value.toInt();
              controller.changeShapeValues(
                item,
                lineColor: Color(intValue).withOpacity(item.lineColor.opacity),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget get thickness {
    final thickness = ValueNotifier<double>(item.thickness);
    return Row(
      children: [
        title('Thickness'),
        const Spacer(),
        ValueListenableBuilder(
          valueListenable: thickness,
          builder: (context, colorVal, child) => Slider(
            value: colorVal,
            max: 10,
            onChanged: (value) {
              thickness.value = value;
            },
            onChangeEnd: (value) {
              final intValue = value.toInt();
              controller.changeShapeValues(
                item,
                thickness: intValue.toDouble(),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget get backgroundColor {
    final color = ValueNotifier(
      (item.backgroundColor.red << 16 |
              item.backgroundColor.green << 8 |
              item.backgroundColor.blue)
          .toDouble(),
    );
    return Opacity(
      opacity: isShapeNotLineOrArrow ? 1 : 0.5,
      child: Row(
        children: [
          title('Background Color'),
          const Spacer(),
          ValueListenableBuilder(
            valueListenable: color,
            builder: (context, colorVal, child) => Slider(
              value: colorVal,
              max: 0xFFFFFF.toDouble(),
              thumbColor: Color(colorVal.toInt())
                  .withOpacity(item.backgroundColor.opacity),
              onChanged: (value) {
                color.value = value;
              },
              onChangeEnd: (value) {
                final intValue = value.toInt();
                controller.changeShapeValues(
                  item,
                  backgroundColor: Color(intValue).withOpacity(1),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
