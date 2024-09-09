import 'package:flutter/material.dart';
import 'package:flutter_painter/src/controllers/items/text_item.dart';
import 'package:flutter_painter/src/models/position_model.dart';
import 'package:flutter_painter/src/models/size_model.dart';
import 'package:flutter_painter/src/views/widgets/measure_size.dart';
import 'package:flutter_painter/src/views/widgets/painter_container.dart';

class TextItemWidget extends StatefulWidget {
  const TextItemWidget({
    required this.item,
    required this.height,
    super.key,
    this.onPositionChange,
    this.onSizeChange,
  });
  final TextItem item;
  final double height;
  final void Function(PositionModel)? onPositionChange;
  final void Function(SizeModel)? onSizeChange;
  @override
  State<TextItemWidget> createState() => _TextItemWidgetState();
}

class _TextItemWidgetState extends State<TextItemWidget> {
  double? widgetHeight;
  ValueNotifier<PositionModel> position =
      ValueNotifier(const PositionModel(x: 50, y: 50));
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: position,
      builder: (context, value, child) {
        return PainterContainer(
          selectedItem: true,
          height: widget.height,
          minimumContainerHeight: widgetHeight,
          onPositionChange: (positionValue) {
            position.value = positionValue;
            widget.onPositionChange?.call(positionValue);
          },
          onSizeChange: (size) {
            widget.onSizeChange?.call(size);
          },
          enabled: widgetHeight != null,
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
        );
      },
    );
  }
}
