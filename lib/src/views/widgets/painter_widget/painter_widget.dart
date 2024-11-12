import 'package:flutter/material.dart';
import 'package:flutter_painter/flutter_painter.dart';
import 'package:flutter_painter/src/controllers/custom_paint.dart';
import 'package:flutter_painter/src/controllers/items/painter_item.dart';
import 'package:flutter_painter/src/views/widgets/items/image_item_widget.dart';
import 'package:flutter_painter/src/views/widgets/items/shape_item_widget.dart';
import 'package:flutter_painter/src/views/widgets/items/text_item_widget.dart';
part 'widgets/painter_widget_item_widget.dart';
part 'widgets/painter_widget_drawing_widget.dart';
part 'widgets/painter_widget_main_widget.dart';
part 'widgets/painter_widget_viewer_widget.dart';

class PainterWidget extends StatelessWidget {
  const PainterWidget({required this.controller, super.key});
  final PainterController controller;
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<PainterControllerValue>(
      valueListenable: controller,
      builder: (context, value, child) {
        return _ViewerWidget(controller: controller);
      },
    );
  }
}
