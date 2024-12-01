import 'package:flutter/material.dart';
import 'package:fullstack_example/widgets/options/options.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:simple_painter/simple_painter.dart';

class TextOptions extends StatelessWidget {
  const TextOptions({required this.controller, required this.item, super.key});
  final PainterController controller;
  final TextItem item;
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 160,
      child: listView(
        [
          title('Text Options'),
          fontSize,
          color,
          bgColor,
          textAlign,
          gradient,
        ],
      ),
    );
  }

  Widget get textAlign {
    return Row(
      children: [
        title('Text Align'),
        const Spacer(),
        IconButton(
          icon: const Icon(Icons.format_align_left),
          onPressed: () {
            controller.changeTextValues(item, textAlign: TextAlign.left);
          },
        ),
        IconButton(
          icon: const Icon(Icons.format_align_center),
          onPressed: () {
            controller.changeTextValues(item, textAlign: TextAlign.center);
          },
        ),
        IconButton(
          icon: const Icon(Icons.format_align_right),
          onPressed: () {
            controller.changeTextValues(item, textAlign: TextAlign.right);
          },
        ),
      ],
    );
  }

  Widget get fontSize {
    final sliderValue = ValueNotifier(item.textStyle.fontSize! / 100);
    return ValueListenableBuilder(
      valueListenable: sliderValue,
      builder: (context, sliderVal, child) {
        return Row(
          children: [
            title('Font Size (${(sliderVal * 100).toStringAsFixed(0)}px)'),
            const Spacer(),
            Slider(
              value: sliderVal,
              onChanged: (value) {
                sliderValue.value = value;
              },
              onChangeEnd: (value) {
                controller.changeTextValues(
                  item,
                  textStyle: item.textStyle.copyWith(fontSize: value * 100),
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
      (item.textStyle.color!.red << 16 |
              item.textStyle.color!.green << 8 |
              item.textStyle.color!.blue)
          .toDouble(),
    );
    return Opacity(
      opacity: item.enableGradientColor ? 0.5 : 1,
      child: Row(
        children: [
          title('Color'),
          const Spacer(),
          ValueListenableBuilder(
            valueListenable: color,
            builder: (context, colorVal, child) => Slider(
              value: colorVal,
              max: 0xFFFFFF.toDouble(),
              thumbColor: Color(colorVal.toInt())
                  .withOpacity(item.textStyle.color!.opacity),
              onChanged: (value) {
                color.value = value;
              },
              onChangeEnd: (value) {
                final intValue = value.toInt();
                controller.changeTextValues(
                  item,
                  textStyle: item.textStyle.copyWith(
                    color: Color(intValue)
                        .withOpacity(item.textStyle.color!.opacity),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget get bgColor {
    final bgColor = ValueNotifier(
      (item.textStyle.backgroundColor!.red << 16 |
              item.textStyle.backgroundColor!.green << 8 |
              item.textStyle.backgroundColor!.blue)
          .toDouble(),
    );
    return Opacity(
      opacity: item.enableGradientColor ? 0.5 : 1,
      child: Row(
        children: [
          title('Background Color'),
          const Spacer(),
          ValueListenableBuilder(
            valueListenable: bgColor,
            builder: (context, colorVal, child) => Slider(
              value: colorVal,
              max: 0xFFFFFF.toDouble(),
              thumbColor: Color(colorVal.toInt()).withOpacity(1),
              onChanged: (value) {
                bgColor.value = value;
              },
              onChangeEnd: (value) {
                final intValue = value.toInt();
                controller.changeTextValues(
                  item,
                  textStyle: item.textStyle.copyWith(
                    backgroundColor: Color(intValue).withOpacity(1),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget get gradient {
    final gradientStartColor = ValueNotifier(
      (item.gradientStartColor.red << 16 |
              item.gradientStartColor.green << 8 |
              item.gradientStartColor.blue)
          .toDouble(),
    );
    final gradientEndColor = ValueNotifier(
      (item.gradientEndColor.red << 16 |
              item.gradientEndColor.green << 8 |
              item.gradientEndColor.blue)
          .toDouble(),
    );
    Widget arrow(IconData icon, Alignment begin, Alignment end) {
      return IconButton(
        onPressed: () {
          controller.changeTextValues(
            item,
            gradientBegin: begin,
            gradientEnd: end,
          );
        },
        icon: Icon(
          icon,
          color: Colors.white,
        ),
      );
    }

    return Column(
      children: [
        Row(
          children: [
            title('Gradient'),
            const Spacer(),
            Switch(
              value: item.enableGradientColor,
              onChanged: (value) {
                controller.changeTextValues(
                  item,
                  enableGradientColor: value,
                );
              },
            ),
          ],
        ),
        Opacity(
          opacity: item.enableGradientColor ? 1 : 0.5,
          child: Column(
            children: [
              Row(
                children: [
                  title('Gradient Start Color'),
                  const Spacer(),
                  ValueListenableBuilder(
                    valueListenable: gradientStartColor,
                    builder: (context, colorVal, child) => Slider(
                      value: colorVal,
                      max: 0xFFFFFF.toDouble(),
                      thumbColor: Color(colorVal.toInt())
                          .withOpacity(item.gradientStartColor.opacity),
                      onChanged: (value) {
                        gradientStartColor.value = value;
                      },
                      onChangeEnd: (value) {
                        final intValue = value.toInt();
                        controller.changeTextValues(
                          item,
                          gradientStartColor: Color(intValue)
                              .withOpacity(item.gradientStartColor.opacity),
                        );
                      },
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  title('Gradient End Color'),
                  const Spacer(),
                  ValueListenableBuilder(
                    valueListenable: gradientEndColor,
                    builder: (context, colorVal, child) => Slider(
                      value: colorVal,
                      max: 0xFFFFFF.toDouble(),
                      thumbColor: Color(colorVal.toInt())
                          .withOpacity(item.gradientEndColor.opacity),
                      onChanged: (value) {
                        gradientEndColor.value = value;
                      },
                      onChangeEnd: (value) {
                        final intValue = value.toInt();
                        controller.changeTextValues(
                          item,
                          gradientEndColor: Color(intValue)
                              .withOpacity(item.gradientEndColor.opacity),
                        );
                      },
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 60,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    arrow(
                      PhosphorIconsRegular.arrowLeft,
                      Alignment.centerRight,
                      Alignment.centerLeft,
                    ),
                    arrow(
                      PhosphorIconsRegular.arrowRight,
                      Alignment.centerLeft,
                      Alignment.centerRight,
                    ),
                    arrow(
                      PhosphorIconsRegular.arrowUp,
                      Alignment.bottomCenter,
                      Alignment.topCenter,
                    ),
                    arrow(
                      PhosphorIconsRegular.arrowDown,
                      Alignment.topCenter,
                      Alignment.bottomCenter,
                    ),
                    arrow(
                      PhosphorIconsRegular.arrowUpRight,
                      Alignment.bottomLeft,
                      Alignment.topRight,
                    ),
                    arrow(
                      PhosphorIconsRegular.arrowUpLeft,
                      Alignment.bottomRight,
                      Alignment.topLeft,
                    ),
                    arrow(
                      PhosphorIconsRegular.arrowDownRight,
                      Alignment.topLeft,
                      Alignment.bottomRight,
                    ),
                    arrow(
                      PhosphorIconsRegular.arrowDownLeft,
                      Alignment.topRight,
                      Alignment.bottomLeft,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
