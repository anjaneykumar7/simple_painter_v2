import 'package:example/widgets/settings/layers.dart';
import 'package:example/widgets/settings/shapes.dart';
import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import 'package:flutter_painter/flutter_painter.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class Settings extends StatelessWidget {
  const Settings(
      {required this.controller,
      required this.openSettings,
      required this.openLayers,
      required this.openShapes,
      required this.changeSettings,
      required this.changeLayers,
      required this.changeShapes,
      super.key});
  final PainterController controller;
  final bool openSettings;
  final bool openLayers;
  final bool openShapes;
  final void Function({bool value}) changeSettings;
  final void Function({bool value}) changeLayers;
  final void Function({bool value}) changeShapes;
  @override
  Widget build(BuildContext context) {
    Widget settings() {
      Widget buttons(IconData icon, String text, void Function() onTap) {
        return GestureDetector(
          onTap: onTap,
          child: Container(
            margin: const EdgeInsets.fromLTRB(20, 10, 5, 6),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  color: Colors.grey,
                  size: 30,
                ),
                Text(
                  text,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        );
      }

      return SizedBox(
        height: 90,
        child: Row(
          children: [
            const SizedBox(
              width: 10,
            ),
            buttons(PhosphorIconsRegular.stack, 'Layers', () {
              changeLayers(value: !openLayers);
            }),
            buttons(PhosphorIconsRegular.polygon, 'Shapes', () {
              changeShapes(value: !openShapes);
            }),
          ],
        ),
      );
    }

    var height = 0.0;
    if (openSettings) {
      height = 90;
    }
    if (openLayers) {
      height = 170;
    }
    if (openShapes) {
      height = 130;
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 700),
      curve: Curves.fastLinearToSlowEaseIn,
      height: height,
      child: ClipRect(
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF232323),
            border: Border(
              bottom: BorderSide(
                color: Colors.grey.shade800,
              ),
            ),
          ),
          child: SingleChildScrollView(
            child: openLayers
                ? Layers(
                    controller: controller,
                    closeLayers: () {
                      changeLayers(value: !openLayers);
                    },
                  )
                : openShapes
                    ? Shapes(
                        controller: controller,
                        closeShapes: () {
                          changeShapes(value: !openShapes);
                        },
                      )
                    : settings(),
          ),
        ),
      ),
    );
  }
}
