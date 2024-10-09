import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import 'package:flutter_painter/flutter_painter.dart';

class Options extends StatelessWidget {
  const Options({super.key, required this.controller});
  final PainterController controller;
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: controller,
      builder: (context, value, child) {
        if (value.selectedItem is TextItem) {
          return textOptions;
        } else {
          return const SizedBox.shrink();
        }
      },
    );
  }

  Widget get textOptions => SizedBox(
        height: 160,
        child: column(
          [title('Text Options')],
        ),
      );

  Widget title(String text) => Align(
        alignment: Alignment.centerLeft,
        child: Text(
          text,
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
      );
  Widget column(List<Widget> children) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          children: children,
        ),
      );
}
