// ignore_for_file: lines_longer_than_80_chars

import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_painter/src/controllers/drawables/background/painter_background.dart';
import 'package:flutter_painter/src/controllers/items/image_item.dart';
import 'package:flutter_painter/src/controllers/items/painter_item.dart';
import 'package:flutter_painter/src/controllers/items/text_item.dart';
import 'package:flutter_painter/src/controllers/paint_actions/action_type_enum.dart';
import 'package:flutter_painter/src/controllers/paint_actions/main/add_item_action.dart';
import 'package:flutter_painter/src/controllers/paint_actions/main/draw_action.dart';
import 'package:flutter_painter/src/controllers/paint_actions/main/erase_action.dart';
import 'package:flutter_painter/src/controllers/paint_actions/main/image_actions/image_change_value_action.dart';
import 'package:flutter_painter/src/controllers/paint_actions/main/remove_item_action.dart';
import 'package:flutter_painter/src/controllers/paint_actions/paint_action.dart';
import 'package:flutter_painter/src/controllers/paint_actions/paint_actions.dart';
import 'package:flutter_painter/src/controllers/paint_actions/text_actions/text_change_value_action.dart';
import 'package:flutter_painter/src/controllers/settings/layer_settings.dart';
import 'package:flutter_painter/src/controllers/settings/painter_settings.dart';
import 'package:flutter_painter/src/helpers/actions_service.dart';
import 'package:flutter_painter/src/helpers/layer_service.dart';
import 'package:flutter_painter/src/models/position_model.dart';
import 'package:flutter_painter/src/models/size_model.dart';
import 'package:flutter_painter/src/pages/add_edit_text_page.dart';

class PainterController extends ValueNotifier<PainterControllerValue> {
  PainterController({
    PainterSettings settings = const PainterSettings(),
  }) : this.fromValue(
          PainterControllerValue(
            settings: settings,
          ),
        );

  PainterController.fromValue(super.value)
      : background = PainterBackground(
          height: value.settings.scale?.height ?? 0,
          width: value.settings.scale?.width ?? 0,
        );

  final GlobalKey repaintBoundaryKey = GlobalKey();
  PainterBackground background = PainterBackground();
  // ValueNotifier<List<PaintAction>> changeActions =
  //     ValueNotifier<List<PaintAction>>(<PaintAction>[]);
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

  Future<void> addText() async {
    var text = '';
    await Navigator.push(
      repaintBoundaryKey.currentContext!,
      PageRouteBuilder<Object>(
        opaque: false,
        pageBuilder: (context, animation, secondaryAnimation) =>
            AddEditTextPage(
          onDone: (String textFunction) {
            text = textFunction;
          },
        ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) =>
            FadeTransition(
          opacity: animation,
          child: child,
        ),
      ),
    );

    if (text.isNotEmpty) {
      final painterItem = TextItem(
        position: const PositionModel(),
        text: text,
        layer: LayerSettings(
          title: text,
          index: value.items.length,
        ),
      );
      value = value.copyWith(
        items: value.items.toList()..add(painterItem),
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

  void addImageUint8List(Uint8List image) {
    if (image.isNotEmpty) {
      final painterItem = ImageItem(
        position: const PositionModel(),
        image: image,
        layer: LayerSettings(
          title: 'Image (${value.items.whereType<ImageItem>().length})',
          index: value.items.length,
        ),
      );
      value = value.copyWith(
        items: value.items.toList()..add(painterItem),
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
    if (changeActions.value.index < changeActions.value.changeList.length - 1) {
      // actions en son indeksde değilse ve yeni aksiyon yazılıcaksa en sondan şu anki indekse kadar olan aksiyonları sil
      changeActions.value = changeActions.value.copyWith(
        changeList: changeActions.value.changeList
            .sublist(0, changeActions.value.index + 1),
        index: changeActions.value.index + 1,
      );
    }
    changeActions.value = changeActions.value.copyWith(
      changeList: changeActions.value.changeList.toList()..add(action),
      index: changeActions.value.changeList.length,
    );
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

  void removeSelectedItem() {
    if (value.selectedItem == null) return;
    final index = _getItemIndexFromItem(value.selectedItem!);
    if (index < 0) return;
    final items = value.items.toList();
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
  }

  int _getItemIndexFromItem(PainterItem item) {
    final index = value.items.indexWhere((element) => element.id == item.id);
    return index;
  }

  void changeTextValues(
    TextItem item, {
    double? fontSize,
    Color? color,
    TextAlign? textAlign,
    bool? enableGradientColor,
    Color? gradientStartColor,
    Color? gradientEndColor,
    AlignmentGeometry? gradientBegin,
    AlignmentGeometry? gradientEnd,
  }) {
    final newTextItem = item.copyWith(
      textStyle: item.textStyle.copyWith(
        fontSize: fontSize ?? item.textStyle.fontSize,
        color: color ?? item.textStyle.color,
      ),
      textAlign: textAlign ?? item.textAlign,
      enableGradientColor: enableGradientColor ?? item.enableGradientColor,
      gradientStartColor: gradientStartColor ?? item.gradientStartColor,
      gradientEndColor: gradientEndColor ?? item.gradientEndColor,
      gradientBegin: gradientBegin ?? item.gradientBegin,
      gradientEnd: gradientEnd ?? item.gradientEnd,
    );
    _changeTextItemValues(newTextItem);
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
    final newImageItem = item.copyWith(
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
    _changeImageItemValues(newImageItem);
  }

  void _changeTextItemValues(
    TextItem item,
  ) {
    final items = value.items.toList();
    final index = _getItemIndexFromItem(item);
    final lastItem = items[index] as TextItem;
    final newItem = item.copyWith(
      size: lastItem.size,
      position: lastItem.position,
      rotation: lastItem.rotation,
    );
    items
      ..removeAt(index)
      ..insert(index, newItem);
    addAction(
      ActionTextChangeValue(
        currentItem: item,
        lastItem: lastItem,
        timestamp: DateTime.now(),
        actionType: ActionType.changeTextValue,
      ),
    );
    value = value.copyWith(items: items, selectedItem: item);
  }

  void _changeImageItemValues(ImageItem item) {
    final items = value.items.toList();
    final index = _getItemIndexFromItem(item);
    final lastItem = items[index] as ImageItem;
    final newItem = item.copyWith(
      size: lastItem.size,
      position: lastItem.position,
      rotation: lastItem.rotation,
    );
    items
      ..removeAt(index)
      ..insert(index, newItem);
    addAction(
      ActionImageChangeValue(
        currentItem: item,
        lastItem: lastItem,
        timestamp: DateTime.now(),
        actionType: ActionType.changeImageValue,
      ),
    );
    value = value.copyWith(items: items, selectedItem: item);
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
