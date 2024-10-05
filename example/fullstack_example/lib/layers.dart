// ignore_for_file: depend_on_referenced_packages, implementation_imports

import 'package:flutter/material.dart';
import 'package:flutter_painter/flutter_painter.dart';
import 'package:flutter_painter/src/controllers/items/painter_item.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class Layers extends StatelessWidget {
  const Layers({required this.controller, super.key});
  final PainterController controller;
  @override
  Widget build(BuildContext context) {
    Widget iconButton(IconData icon, Color color, void Function() onTap) {
      return GestureDetector(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 3),
          child: Icon(
            icon,
            color: color,
            size: 22,
          ),
        ),
      );
    }

    Widget section(String title, PainterItem item) {
      return Container(
        height: 40,
        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
          border: Border.all(
            color: Colors.grey.shade700,
          ),
        ),
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 10),
              child: Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                ),
              ),
            ),
            const Spacer(),
            iconButton(
              PhosphorIconsRegular.trash,
              Colors.red,
              () {
                // Add your onTap functionality here
              },
            ),
            iconButton(
              PhosphorIconsRegular.arrowDown,
              Colors.white,
              () {
                controller.updateLayerIndex(item, item.layer.index + 1);
              },
            ),
            iconButton(
              PhosphorIconsRegular.arrowUp,
              Colors.white,
              () {
                controller.updateLayerIndex(item, item.layer.index - 1);
              },
            ),
            const SizedBox(
              width: 10,
            ),
          ],
        ),
      );
    }

    return SizedBox(
      height: 170,
      child: ValueListenableBuilder(
        valueListenable: controller,
        builder: (context, value, child) => ListView.builder(
          itemCount: value.items.length,
          itemBuilder: (context, index) {
            return section(
              value.items[index].layer.title,
              value.items[index],
            );
          },
        ),
      ),
    );
  }
}
