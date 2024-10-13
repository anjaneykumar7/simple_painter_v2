import 'package:example/widgets/options/options.dart';
import 'package:flutter/material.dart';

// ignore: depend_on_referenced_packages
import 'package:flutter_painter/flutter_painter.dart';

class ImageOptions extends StatelessWidget {
  const ImageOptions({required this.controller, required this.item, super.key});
  final PainterController controller;
  final ImageItem item;
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 160,
      child: listView(
        [
          title('Text Options'),
          fit,
          borderRadius,
          border,
        ],
      ),
    );
  }

  Widget get fit {
    Widget button(String text, BoxFit fit) {
      return GestureDetector(
        onTap: () {
          controller.changeImageValues(item, boxFit: fit);
        },
        child: Container(
          margin: const EdgeInsets.only(left: 5, top: 5),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5),
            border: Border.all(color: Colors.grey),
          ),
          child: Text(
            text,
            style: const TextStyle(color: Colors.white),
          ),
        ),
      );
    }

    return Wrap(
      children: [
        title('Fit'),
        button('Contain', BoxFit.contain),
        button('Cover', BoxFit.cover),
        button('Fill', BoxFit.fill),
        button('Fit Width', BoxFit.fitWidth),
        button('Fit Height', BoxFit.fitHeight),
        button('None', BoxFit.none),
        button('Scale Down', BoxFit.scaleDown),
      ],
    );
  }

  Widget get borderRadius {
    final borderRadius = ValueNotifier(
      item.borderRadius.topLeft.x,
    );
    return Row(
      children: [
        title('Border Radius'),
        const Spacer(),
        ValueListenableBuilder(
          valueListenable: borderRadius,
          builder: (context, colorVal, child) => Slider(
            value: colorVal,
            max: 100,
            onChanged: (value) {
              borderRadius.value = value;
            },
            onChangeEnd: (value) {
              final intValue = value.toInt();
              controller.changeImageValues(
                item,
                borderRadius: BorderRadius.circular(intValue.toDouble()),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget get border {
    final borderColor = ValueNotifier(
      (item.borderColor.red << 16 |
              item.borderColor.green << 8 |
              item.borderColor.blue)
          .toDouble(),
    );
    final borderWidth = ValueNotifier<double>(item.borderWidth);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            title('Border Width'),
            const Spacer(),
            ValueListenableBuilder(
              valueListenable: borderWidth,
              builder: (context, colorVal, child) => Slider(
                value: colorVal,
                max: 10,
                onChanged: (value) {
                  borderWidth.value = value;
                },
                onChangeEnd: (value) {
                  final intValue = value.toInt();
                  controller.changeImageValues(
                    item,
                    borderWidth: intValue.toDouble(),
                  );
                },
              ),
            ),
          ],
        ),
        Opacity(
          opacity: item.enableGradientColor ? 0.5 : 1,
          child: Row(
            children: [
              title('Border Color'),
              const Spacer(),
              ValueListenableBuilder(
                valueListenable: borderColor,
                builder: (context, colorVal, child) => Slider(
                  value: colorVal,
                  max: 0xFFFFFF.toDouble(),
                  thumbColor: Color(colorVal.toInt())
                      .withOpacity(item.borderColor.opacity),
                  onChanged: (value) {
                    borderColor.value = value;
                  },
                  onChangeEnd: (value) {
                    final intValue = value.toInt();
                    controller.changeImageValues(
                      item,
                      borderColor:
                          Color(intValue).withOpacity(item.borderColor.opacity),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
