import 'package:flutter/material.dart';
import 'package:fullstack_example/widgets/options/brush_options.dart';
import 'package:fullstack_example/widgets/options/erase_options.dart';
import 'package:fullstack_example/widgets/options/image_options.dart';
import 'package:fullstack_example/widgets/options/shape_options.dart';
import 'package:fullstack_example/widgets/options/text_options.dart';
import 'package:simple_painter/simple_painter.dart';

class Options extends StatelessWidget {
  const Options({required this.controller, super.key});
  final PainterController controller;
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: controller,
      builder: (context, value, child) {
        if (controller.isDrawing) {
          return BrushOptions(controller: controller);
        }
        if (controller.isErasing) {
          return EraseOptions(controller: controller);
        }
        if (value.selectedItem is TextItem) {
          return TextOptions(
            controller: controller,
            item: value.selectedItem! as TextItem,
          );
        } else if (value.selectedItem is ImageItem) {
          return ImageOptions(
            controller: controller,
            item: value.selectedItem! as ImageItem,
          );
        } else if (value.selectedItem is ShapeItem) {
          return ShapeOptions(
            controller: controller,
            item: value.selectedItem! as ShapeItem,
          );
        } else {
          return const SizedBox.shrink();
        }
      },
    );
  }
}

Widget listView(List<Widget> children) => Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: ListView(
        shrinkWrap: true,
        children: children,
      ),
    );

Widget title(String text) => Align(
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        style: const TextStyle(color: Colors.white, fontSize: 16),
      ),
    );
