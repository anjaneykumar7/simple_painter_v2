import 'package:example/widgets/options/options.dart';
import 'package:flutter/material.dart';

// ignore: depend_on_referenced_packages
import 'package:flutter_painter/flutter_painter.dart';

class ImageOptions extends StatelessWidget {
  const ImageOptions({super.key, required this.controller, required this.item});
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
        ],
      ),
    );
  }

  Widget get fit {
    Widget button(String text, BoxFit fit) {
      return GestureDetector(
        onTap: () {
          controller.changeImageBoxFit(item, fit);
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
}
