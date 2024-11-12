// ignore_for_file: lines_longer_than_80_chars

import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_painter/flutter_painter.dart';
import 'package:flutter_painter/src/controllers/drawables/background/painter_background.dart';
import 'package:flutter_painter/src/controllers/items/painter_item.dart';
import 'package:flutter_painter/src/controllers/paint_actions/main/add_item_action.dart';
import 'package:flutter_painter/src/controllers/paint_actions/main/draw_action.dart';
import 'package:flutter_painter/src/controllers/paint_actions/main/erase_action.dart';
import 'package:flutter_painter/src/controllers/paint_actions/main/remove_item_action.dart';
import 'package:flutter_painter/src/controllers/paint_actions/paint_action.dart';
import 'package:flutter_painter/src/controllers/paint_actions/paint_actions.dart';
import 'package:flutter_painter/src/controllers/settings/layer_settings.dart';
import 'package:flutter_painter/src/helpers/actions_service.dart';
import 'package:flutter_painter/src/helpers/change_item_values_service.dart';
import 'package:flutter_painter/src/helpers/layer_service.dart';
import 'package:flutter_painter/src/models/position_model.dart';
import 'package:flutter_painter/src/models/size_model.dart';

class PainterController extends ValueNotifier<PainterControllerValue> {
  PainterController({
    PainterSettings settings = const PainterSettings(),
    ui.Image? backgroundImage,
  }) : this.fromValue(
          PainterControllerValue(
            settings: settings,
          ),
          backgroundImage: backgroundImage,
        );

  PainterController.fromValue(super.value, {ui.Image? backgroundImage})
      : background = PainterBackground(
          image: backgroundImage,
          height: value.settings.scale?.height ?? 0,
          width: value.settings.scale?.width ?? 0,
        );

  final GlobalKey repaintBoundaryKey = GlobalKey();
  final StreamController<ControllerEvent> _eventController =
      StreamController<ControllerEvent>.broadcast();
  PainterBackground background = PainterBackground();
  ValueNotifier<PaintActions> changeActions =
      ValueNotifier<PaintActions>(PaintActions());
  bool isErasing = false;
  bool isDrawing = false;
  bool editingText = false;
  bool addingText = false;

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
      if (value.paintPathsBeforeErasing.isEmpty) {
        value =
            value.copyWith(paintPathsBeforeErasing: value.paintPaths.toList());
      }
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
      addAction(
        ActionDraw(
          paintPath: value.currentPaintPath.toList(),
          listIndex: value.paintPaths.length - 1,
          timestamp: DateTime.now(),
          actionType: ActionType.draw,
        ),
      );
      value.currentPaintPath = value.currentPaintPath.toList()..clear();
    } else if (isErasing) {
      addAction(
        ActionErase(
          currentPaintPath: value.paintPaths.toList(),
          lastPaintPath: value.paintPathsBeforeErasing.toList(),
          timestamp: DateTime.now(),
          actionType: ActionType.erase,
        ),
      );
      value = value.copyWith(
        paintPathsBeforeErasing: value.paintPathsBeforeErasing..clear(),
      );
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

      var isInEraseRegion = false;
      for (var i = 0; i < path.length; i++) {
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
    final completer = Completer<ui.Image>();
    ui.decodeImageFromList(imageData, completer.complete);
    background.image = await completer.future;
  }

  Future<void> addText(String text) async {
    if (text.isNotEmpty) {
      final painterItem = TextItem(
        position: const PositionModel(),
        text: text,
        layer: LayerSettings(
          title: text,
          index: value.items.length,
        ),
      ).copyWith(
        textStyle: value.settings.text?.textStyle,
        textAlign: value.settings.text?.textAlign,
        enableGradientColor: value.settings.text?.enableGradientColor,
        gradientStartColor: value.settings.text?.gradientStartColor,
        gradientEndColor: value.settings.text?.gradientEndColor,
        gradientBegin: value.settings.text?.gradientBegin,
        gradientEnd: value.settings.text?.gradientEnd,
      );
      value = value.copyWith(
        items: value.items.toList()..insert(0, painterItem),
      );

      addAction(
        ActionAddItem(
          item: painterItem,
          listIndex: value.items.length - 1,
          timestamp: DateTime.now(),
          actionType: ActionType.addedTextItem,
        ),
      );
      value.selectedItem = painterItem;
    }
  }

  StreamSubscription<ControllerEvent> eventListener(
    void Function(ControllerEvent) onData,
  ) {
    return _eventController.stream.listen(onData);
  }

  void triggerEvent(ControllerEvent event) {
    _eventController.add(event);
  }

  void addImageUint8List(Uint8List image) {
    if (image.isNotEmpty) {
      final painterItem = ImageItem(
        position: const PositionModel(),
        image: image,
        layer: LayerSettings(
          title: 'Image (${value.items.whereType<ImageItem>().length})',
          index: value.items.length,
        ),
        size: const SizeModel(width: 100, height: 100),
      );
      value = value.copyWith(
        items: value.items.toList()..insert(0, painterItem),
      );
      addAction(
        ActionAddItem(
          item: painterItem,
          listIndex: value.items.length - 1,
          timestamp: DateTime.now(),
          actionType: ActionType.addedImageItem,
        ),
      );
      value.selectedItem = painterItem;
    }
  }

  void addAction(PaintAction action) {
    ActionsService().addAction(
      action,
      changeActions,
      value,
      (list, index) {
        changeActions.value = changeActions.value.copyWith(
          changeList: list,
          index: index,
        );
      },
    );
  }

  int getLayerIndex(PainterItem item) {
    return LayerService().getLayerIndex(item, value.items.toList());
  }

  void setItemPosition(int index, PositionModel position) {
    final items = value.items.toList();
    var item = items[index];
    if (item is TextItem) {
      item = item.copyWith(position: position);
    } else {
      item = item.copyWith(position: position);
    }
    items
      ..removeAt(index)
      ..insert(index, item);
    value = value.copyWith(items: items);
  }

  void setItemRotation(int index, double rotation) {
    final items = value.items.toList();
    var item = items[index];
    if (item is TextItem) {
      item = item.copyWith(rotation: rotation);
    } else {
      item = item.copyWith(rotation: rotation);
    }
    items
      ..removeAt(index)
      ..insert(index, item);
    value = value.copyWith(items: items);
  }

  void setItemSize(int index, SizeModel size) {
    final items = value.items.toList();
    var item = items[index];
    if (item is TextItem) {
      item = item.copyWith(size: size);
    } else {
      item = item.copyWith(size: size);
    }
    items
      ..removeAt(index)
      ..insert(index, item);
    value = value.copyWith(items: items);
  }

  void updateActionWithChangeActionIndex(int index) {
    ActionsService().updateActionWithChangeActionIndex(
        changeActions, value.paintPaths, value, index, (items) {
      value = value.copyWith(items: items);
    }, (index) {
      changeActions.value = changeActions.value.copyWith(index: index);
    }, (pathList) {
      value = value.copyWith(paintPaths: pathList);
    });
  }

  void undo() {
    ActionsService().undo(changeActions, value.paintPaths, value, (items) {
      value = value.copyWith(items: items);
    }, (index) {
      changeActions.value = changeActions.value.copyWith(index: index);
    }, (pathList) {
      value = value.copyWith(paintPaths: pathList);
    });
  }

  void redo() {
    ActionsService().redo(changeActions, value.paintPaths, value, (items) {
      value = value.copyWith(items: items);
    }, (index) {
      changeActions.value = changeActions.value.copyWith(index: index);
    }, (pathList) {
      value = value.copyWith(paintPaths: pathList);
    });
  }

  void updateLayerIndex(PainterItem item, int newIndex) {
    LayerService().updateLayerIndex(
      item,
      newIndex,
      value.items.toList(),
      (items) {
        value = value.copyWith(items: items);
      },
      addAction,
    );
  }

  void removeItem({int? layerIndex}) {
    if (value.selectedItem == null && layerIndex == null) return;
    final items = value.items.toList();
    var index = 0;
    if (layerIndex != null && layerIndex < items.length) {
      index = layerIndex;
    } else {
      index = _getItemIndexFromItem(value.selectedItem!);
    }
    if (index < 0) return;
    final item = items[index];
    items.removeAt(index);
    value = value.copyWith(items: items);
    addAction(
      ActionRemoveItem(
        item: item,
        listIndex: index,
        timestamp: DateTime.now(),
        actionType: ActionType.removedItem,
      ),
    );
    clearSelectedItem();
  }

  void addShape(ShapeType shapeType) {
    final shapeItem = ShapeItem(
      shapeType: shapeType,
      position: const PositionModel(),
      layer: LayerSettings(
        title: 'Shape (${value.items.whereType<ShapeItem>().length})',
        index: value.items.length,
      ),
      size: ShapeItem.defaultSize(shapeType),
    );
    value = value.copyWith(
      items: value.items.toList()..insert(0, shapeItem),
    );
    addAction(
      ActionAddItem(
        item: shapeItem,
        listIndex: value.items.length - 1,
        timestamp: DateTime.now(),
        actionType: ActionType.addedShapeItem,
      ),
    );
    value.selectedItem = shapeItem;
  }

  void clearSelectedItem() {
    value.selectedItem = null;
    value = value.copyWith();
  }

  int _getItemIndexFromItem(PainterItem item) {
    final index = value.items.indexWhere((element) => element.id == item.id);
    return index;
  }

  void changeTextValues(
    TextItem item, {
    TextStyle? textStyle,
    TextAlign? textAlign,
    bool? enableGradientColor,
    Color? gradientStartColor,
    Color? gradientEndColor,
    AlignmentGeometry? gradientBegin,
    AlignmentGeometry? gradientEnd,
  }) {
    final newItem = item.copyWith(
      textStyle: textStyle ?? item.textStyle,
      textAlign: textAlign ?? item.textAlign,
      enableGradientColor: enableGradientColor ?? item.enableGradientColor,
      gradientStartColor: gradientStartColor ?? item.gradientStartColor,
      gradientEndColor: gradientEndColor ?? item.gradientEndColor,
      gradientBegin: gradientBegin ?? item.gradientBegin,
      gradientEnd: gradientEnd ?? item.gradientEnd,
    );
    _changeItemValues(newItem);
  }

  void changeShapeValues(
    ShapeItem item, {
    ShapeType? shapeType,
    Color? backgroundColor,
    Color? lineColor,
    double? thickness,
  }) {
    final newItem = item.copyWith(
      shapeType: shapeType ?? item.shapeType,
      backgroundColor: backgroundColor ?? item.backgroundColor,
      lineColor: lineColor ?? item.lineColor,
      thickness: thickness ?? item.thickness,
    );
    _changeItemValues(newItem);
  }

  void changeImageValues(
    ImageItem item, {
    BoxFit? boxFit,
    BorderRadius? borderRadius,
    Color? borderColor,
    double? borderWidth,
    bool? enableGradientColor,
    Color? gradientStartColor,
    Color? gradientEndColor,
    AlignmentGeometry? gradientBegin,
    AlignmentGeometry? gradientEnd,
    double? gradientOpacity,
  }) {
    final newItem = item.copyWith(
      fit: boxFit ?? item.fit,
      borderRadius: borderRadius ?? item.borderRadius,
      borderColor: borderColor ?? item.borderColor,
      borderWidth: borderWidth ?? item.borderWidth,
      enableGradientColor: enableGradientColor ?? item.enableGradientColor,
      gradientStartColor: gradientStartColor ?? item.gradientStartColor,
      gradientEndColor: gradientEndColor ?? item.gradientEndColor,
      gradientBegin: gradientBegin ?? item.gradientBegin,
      gradientEnd: gradientEnd ?? item.gradientEnd,
      gradientOpacity: gradientOpacity ?? item.gradientOpacity,
    );
    _changeItemValues(newItem);
  }

  void _changeItemValues(PainterItem item) {
    ChangeItemValuesService().changeItemValues(
      item,
      value.items.toList(),
      (action, items, selectedItem) {
        value = value.copyWith(
          items: items,
          selectedItem: selectedItem as PainterItem,
        );
        addAction(action);
      },
    );
  }
}

class PainterControllerValue {
  PainterControllerValue({
    required this.settings,
    this.scale,
    this.paintPaths = const <List<Offset?>>[],
    this.currentPaintPath = const <Offset?>[],
    this.paintPathsBeforeErasing = const <List<Offset?>>[],
    this.items = const <PainterItem>[],
    this.selectedItem,
  });
  final PainterSettings settings;
  final Size? scale;
  List<List<Offset?>> paintPaths =
      <List<Offset?>>[]; // Çizim yollarını saklamak için
  List<Offset?> currentPaintPath = <Offset?>[]; // Geçici çizim yolu
  List<List<Offset?>> paintPathsBeforeErasing = <List<Offset?>>[];
  List<PainterItem> items = <PainterItem>[];
  PainterItem? selectedItem;

  PainterControllerValue copyWith({
    PainterSettings? settings,
    Size? scale,
    List<List<Offset?>>? paintPaths,
    List<Offset?>? currentPaintPath,
    List<List<Offset?>>? paintPathsBeforeErasing,
    List<PainterItem>? items,
    PainterItem? selectedItem,
  }) {
    return PainterControllerValue(
      settings: settings ?? this.settings,
      scale: scale ?? this.scale,
      paintPaths: paintPaths ?? this.paintPaths,
      currentPaintPath: currentPaintPath ?? this.currentPaintPath,
      paintPathsBeforeErasing:
          paintPathsBeforeErasing ?? this.paintPathsBeforeErasing,
      items: items ?? this.items,
      selectedItem: selectedItem ?? this.selectedItem,
    );
  }
}
