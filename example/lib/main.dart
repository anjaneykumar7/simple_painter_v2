import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_painter/flutter_painter.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Flutter Demo',
      home: FlutterPainterExample(),
    );
  }
}

class FlutterPainterExample extends StatefulWidget {
  const FlutterPainterExample({super.key});

  @override
  State<FlutterPainterExample> createState() => _FlutterPainterExampleState();
}

class _FlutterPainterExampleState extends State<FlutterPainterExample> {
  late PainterController controller;
  @override
  void initState() {
    super.initState();
    controller = PainterController(
      settings: const PainterSettings(
        scale: Size(800, 800),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: Colors.grey.shade300,
      appBar: appBar,
      bottomNavigationBar: bottomBar,
      body: SizedBox(
          height: height, child: PainterWidget(controller: controller)),
    );
  }

  PreferredSize get appBar {
    return PreferredSize(
      preferredSize: const Size(double.infinity, kToolbarHeight),
      // Listen to the controller and update the UI when it updates.
      child: AppBar(
        title: const Text('Soru Oluştur'),
        actions: [
          // Delete the selected drawable
          IconButton(
            icon: const Icon(
              PhosphorIconsRegular.trash,
            ),
            onPressed: () {},
          ),
          // Delete the selected drawable
          IconButton(
              icon: const Icon(
                Icons.flip,
              ),
              onPressed: () {}),
          // Redo action
          IconButton(
              icon: const Icon(
                PhosphorIconsRegular.arrowClockwise,
              ),
              onPressed: () {}),
          // Undo action
          IconButton(
              icon: const Icon(
                PhosphorIconsRegular.arrowCounterClockwise,
              ),
              onPressed: () {}),
        ],
      ),
    );
  }

  Widget get bottomBar {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.only(
        bottom: Platform.isIOS ? 20 : 0,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          // Free-style eraser
          IconButton(
              icon: Icon(
                PhosphorIconsRegular.eraser,
                color: controller.isErasing ? Colors.blue : null,
              ),
              onPressed: () {
                setState(() {
                  controller.toggleErasing();
                });
              }),
          // Free-style drawing
          IconButton(
            icon: Icon(
              PhosphorIconsRegular.scribble,
              color: controller.isDrawing ? Colors.blue : null,
            ),
            onPressed: () {
              setState(() {
                controller.toggleDrawing();
              });
            },
          ),
          // Add text
          IconButton(
            icon: const Icon(
              PhosphorIconsRegular.textT,
              color: Colors.blue,
            ),
            onPressed: () {},
          ),
          // Add sticker image
          IconButton(
            icon: const Icon(
              PhosphorIconsRegular.image,
            ),
            onPressed: () {},
          ),
          // Add shapes

          IconButton(
            icon: const Icon(
              PhosphorIconsRegular.polygon,
              color: Colors.blue,
            ),
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}
