import 'package:example/widgets/options/options.dart';
import 'package:flutter/material.dart';

import 'package:flutter_painter/flutter_painter.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

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
          title('Image Options'),
          fit,
          borderRadius,
          border,
          gradient,
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
          controller.changeImageValues(
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
                controller.changeImageValues(
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
                        controller.changeImageValues(
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
                        controller.changeImageValues(
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
                        controller.changeImageValues(
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
