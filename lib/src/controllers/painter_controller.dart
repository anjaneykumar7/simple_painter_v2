// ignore_for_file: lines_longer_than_80_chars

import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'dart:ui';

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_painter/src/controllers/drawables/background/painter_background.dart';
import 'package:flutter_painter/src/controllers/settings/painter_settings.dart';

class PainterController extends ValueNotifier<PainterControllerValue> {
  PainterController({
    PainterSettings settings = const PainterSettings(),
  }) : this.fromValue(PainterControllerValue(
          settings: settings,
        ));

  final GlobalKey repaintBoundaryKey = GlobalKey();
  PainterBackground background = PainterBackground();
  bool isErasing = false;
  bool isDrawing = false;

  PainterController.fromValue(PainterControllerValue value)
      : background = PainterBackground(
          height: value.settings.scale?.height ?? 0,
          width: value.settings.scale?.width ?? 0,
        ),
        super(value);

  Future<Uint8List?> capturePng() async {
    try {
      final boundary = repaintBoundaryKey.currentContext!.findRenderObject()!
          as RenderRepaintBoundary;
      final image = await boundary.toImage();
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      return byteData?.buffer.asUint8List();
    } catch (e) {
      return null;
    }
  }

  void addPaintPoint(Offset? point) {
    if (isErasing) {
      _erase(point);
    } else {
      value = value.copyWith(
        currentPaintPath: value.currentPaintPath.toList()..add(point),
      );
    }
  }

  void endPath() {
    if (!isErasing && value.currentPaintPath.toList().isNotEmpty) {
      value.paintPaths = value.paintPaths.toList()
        ..add(List.from(value.currentPaintPath.toList()));
      value.currentPaintPath = value.currentPaintPath.toList()..clear();
    }
  }

  void toggleErasing() {
    isErasing = !isErasing;
    if (isErasing) {
      isDrawing = false;
    }
  }

  void toggleDrawing() {
    isDrawing = !isDrawing;
    if (isDrawing) {
      isErasing = false;
    }
  }

  void _erase(Offset? position) {
    if (position == null) return;

    final updatedPaths = <List<Offset?>>[];

    for (final path in value.paintPaths.toList()) {
      final updatedPath = <Offset?>[];

      bool isInEraseRegion = false;
      for (int i = 0; i < path.length; i++) {
        final point = path[i];
        if (point == null) continue;

        // Silme bölgesine girdi mi kontrolü
        if ((point - position).distance < 10) {
          isInEraseRegion = true;
        }

        if (isInEraseRegion) {
          if (i == 0 || (i > 0 && (path[i - 1]! - position).distance >= 10)) {
            // Eğer silgi bölgesindeysek ve önceki noktayı silmediysek
            if (updatedPath.isNotEmpty) {
              updatedPaths.add(List.from(updatedPath));
              updatedPath.clear();
            }
            isInEraseRegion = false;
          }
        } else {
          updatedPath.add(point);
        }
      }

      // Son kalan yolu ekle
      if (updatedPath.isNotEmpty) {
        updatedPaths.add(updatedPath);
      }
    }

    value = value.copyWith(paintPaths: updatedPaths);
  }

  Future<void> setBackgroundImage(Uint8List imageData) async {
    try {
      final completer = Completer<ui.Image>();
      ui.decodeImageFromList(imageData, completer.complete);
      background.image = await completer.future;
      background = background;
    } catch (e) {
      print('Error loading image: $e');
    }
  }
}

class PainterControllerValue {
  PainterControllerValue({
    required this.settings,
    this.scale,
    this.paintPaths = const <List<Offset?>>[],
    this.currentPaintPath = const <Offset?>[],
  });
  final PainterSettings settings;
  final Size? scale;
  List<List<Offset?>> paintPaths =
      <List<Offset?>>[]; // Çizim yollarını saklamak için
  List<Offset?> currentPaintPath = <Offset?>[]; // Geçici çizim yolu

  PainterControllerValue copyWith({
    PainterSettings? settings,
    Size? scale,
    List<List<Offset?>>? paintPaths,
    List<Offset?>? currentPaintPath,
  }) {
    return PainterControllerValue(
      settings: settings ?? this.settings,
      scale: scale ?? this.scale,
      paintPaths: paintPaths ?? this.paintPaths,
      currentPaintPath: currentPaintPath ?? this.currentPaintPath,
    );
  }
}
