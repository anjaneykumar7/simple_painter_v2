import 'package:flutter/material.dart';
import 'package:fullstack_example/widgets/options/options.dart';
import 'package:simple_painter/simple_painter.dart';

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
    return colorSwitch(
      'Line Color',
      item.lineColor,
      (value) {
        controller.changeShapeValues(
          item,
          lineColor: Color(value.toInt()).withValues(alpha: 1),
        );
      },
    );
  }

  Widget get thickness {
    return doubleSwitch(
      'Thickness',
      item.thickness,
      10,
      (value) {
        controller.changeShapeValues(
          item,
          thickness: value,
        );
      },
    );
  }

  Widget get backgroundColor {
    return colorSwitch(
      'Background Color',
      item.backgroundColor,
      (value) {
        controller.changeShapeValues(
          item,
          backgroundColor: Color(value.toInt()).withValues(alpha: 1),
        );
      },
      opacityCondition: !isShapeNotLineOrArrow,
    );
  }
}
