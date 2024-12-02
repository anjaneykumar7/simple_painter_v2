import 'package:flutter/material.dart';
import 'package:fullstack_example/widgets/options/options.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:simple_painter/simple_painter.dart';

class CustomWidgetOptions extends StatelessWidget {
  const CustomWidgetOptions(
      {required this.controller, required this.item, super.key});
  final PainterController controller;
  final CustomWidgetItem item;
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 160,
      child: listView(
        [
          title('Custom Widget Options'),
          borderRadius,
          border,
          gradient,
        ],
      ),
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
              controller.changeCustomWidgetValues(
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
                  controller.changeCustomWidgetValues(
                    item,
                    borderWidth: intValue.toDouble(),
                  );
                },
              ),
            ),
          ],
        ),
        Row(
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
                  controller.changeCustomWidgetValues(
                    item,
                    borderColor:
                        Color(intValue).withOpacity(item.borderColor.opacity),
                  );
                },
              ),
            ),
          ],
        ),
      ],
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
    final gradientOpacity = ValueNotifier(item.gradientOpacity);
    Widget arrow(IconData icon, Alignment begin, Alignment end) {
      return IconButton(
        onPressed: () {
          controller.changeCustomWidgetValues(
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
                controller.changeCustomWidgetValues(
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
                        controller.changeCustomWidgetValues(
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
                        controller.changeCustomWidgetValues(
                          item,
                          gradientEndColor: Color(intValue)
                              .withOpacity(item.gradientEndColor.opacity),
                        );
                      },
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  title('Gradient Opacity'),
                  const Spacer(),
                  ValueListenableBuilder(
                    valueListenable: gradientOpacity,
                    builder: (context, colorVal, child) => Slider(
                      value: colorVal,
                      onChanged: (value) {
                        gradientOpacity.value = value;
                      },
                      onChangeEnd: (value) {
                        controller.changeCustomWidgetValues(
                          item,
                          gradientOpacity: value,
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
