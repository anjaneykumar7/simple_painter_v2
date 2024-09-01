import 'package:flutter/material.dart';
import 'package:flutter_painter/src/controllers/items/text_item.dart';
import 'package:flutter_painter/src/models/position_model.dart';
import 'package:flutter_painter/src/models/size_model.dart';
import 'package:flutter_painter/src/views/widgets/measure_size.dart';
import 'package:flutter_painter/src/views/widgets/painter_container.dart';

class TextItemWidget extends StatefulWidget {
  const TextItemWidget(
      {super.key,
      required this.item,
      required this.height,
      this.onPositionChange,
      this.onSizeChange});
  final TextItem item;
  final double height;
  final void Function(PositionModel)? onPositionChange;
  final void Function(SizeModel)? onSizeChange;
  @override
  State<TextItemWidget> createState() => _TextItemWidgetState();
}

class _TextItemWidgetState extends State<TextItemWidget> {
  double? widgetHeight;
  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: widgetHeight == null
          ? 0
          : 1, // Hide the widget until the height is calculated
      child: PainterContainer(
        selectedItem: true,
        height: widget.height,
        minimumContainerHeight: widgetHeight,
        onPositionChange: (position) {
          widget.onPositionChange?.call(position);
        },
        onSizeChange: (size) {
          widget.onSizeChange?.call(size);
        },
        child: MeasureSize(
          onChange: (size) {
            if (widgetHeight != null) return;
            setState(() {
              widgetHeight = size.height;
            });
          },
          child: Text(
            widget.item.text,
            style: widget.item.textStyle,
          ),
        ),
      ),
    );
  }
}
