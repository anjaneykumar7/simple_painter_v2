import 'dart:io';

import 'package:example/changes_list.dart';
import 'package:example/layers.dart';
import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import 'package:flutter_painter/flutter_painter.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        appBarTheme: const AppBarTheme(
          iconTheme: IconThemeData(color: Colors.white),
        ),
      ),
      home: const FlutterPainterExample(),
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
  bool ifOpenChangeList = true;
  bool openSettings = false;
  bool openLayers = false;
  @override
  void initState() {
    super.initState();
    controller = PainterController(
      settings: const PainterSettings(
        scale: Size(800, 800),
        itemDragHandleColor: Colors.blue,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: Colors.grey.shade800.withOpacity(0.6),
      appBar: appBar,
      bottomNavigationBar: bottomBar,
      body: Stack(
        children: [
          SizedBox(
            height: height,
            child: PainterWidget(controller: controller),
          ),
          Positioned.fill(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: settings,
            ),
          ),
          if (ifOpenChangeList)
            Positioned.fill(
              child: Align(
                alignment: Alignment.topLeft,
                child: ChangesList(controller: controller),
              ),
            ),
        ],
      ),
    );
  }

  Widget get settings {
    Widget settings() {
      Widget buttons(IconData icon, String text, void Function() onTap) {
        return GestureDetector(
          onTap: onTap,
          child: Container(
            margin: const EdgeInsets.fromLTRB(5, 10, 5, 6),
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
              setState(() {
                openLayers = !openLayers;
              });
            }),
          ],
        ),
      );
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 700),
      curve: Curves.fastLinearToSlowEaseIn,
      height: openSettings
          ? openLayers
              ? 170
              : 90
          : 0,
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
                  )
                : settings(),
          ),
        ),
      ),
    );
  }

  PreferredSize get appBar {
    return PreferredSize(
      preferredSize: const Size(double.infinity, kToolbarHeight),
      child: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          // Delete the selected drawable
          IconButton(
            icon: const Icon(
              PhosphorIconsRegular.listNumbers,
            ),
            onPressed: () {
              setState(() {
                ifOpenChangeList = !ifOpenChangeList;
              });
            },
          ),
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
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(
              PhosphorIconsRegular.arrowCounterClockwise,
              color: (controller.changeActions.value.index == -1)
                  ? Colors.grey
                  : Colors.white,
            ),
            onPressed: () {
              setState(() {
                controller.undo();
              });
            },
          ),
          IconButton(
            icon: Icon(
              PhosphorIconsRegular.arrowClockwise,
              color: (controller.changeActions.value.index ==
                      controller.changeActions.value.changeList.length - 1)
                  ? Colors.grey
                  : Colors.white,
            ),
            onPressed: () {
              setState(() {
                controller.redo();
              });
            },
          ),
          // Undo action
        ],
      ),
    );
  }

  Widget get bottomBar {
    return Container(
      color: const Color(0xFF232323),
      padding: EdgeInsets.only(
        bottom: Platform.isIOS ? 20 : 0,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          button(
            PhosphorIconsRegular.eraser,
            () {
              setState(() {
                controller.toggleErasing();
              });
            },
            enabled: controller.isErasing,
          ),
          button(
            PhosphorIconsRegular.scribble,
            () {
              setState(() {
                controller.toggleDrawing();
              });
            },
            enabled: controller.isDrawing,
          ),
          button(
            PhosphorIconsRegular.textT,
            () async {
              await controller.addText();
              setState(() {});
            },
            enabled: controller.editingText || controller.addingText,
          ),
          button(
            PhosphorIconsRegular.image,
            () {},
          ),
          button(
            PhosphorIconsRegular.polygon,
            () {},
          ),
          button(
            PhosphorIconsRegular.listBullets,
            () {
              setState(() {
                openSettings = !openSettings;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget button(
    IconData icon,
    void Function()? onPressed, {
    bool enabled = false,
  }) {
    return IntrinsicHeight(
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.fromLTRB(5, 10, 5, 6),
            decoration: BoxDecoration(
              color: enabled ? const Color(0xFF2580eb) : null,
              borderRadius: BorderRadius.circular(10),
            ),
            child: IconButton(
              icon: Icon(
                icon,
                color: enabled ? Colors.white : Colors.grey.shade500,
              ),
              onPressed: onPressed,
            ),
          ),
          Opacity(
            opacity: enabled ? 1 : 0,
            child: Container(
              height: 2,
              width: 10,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
