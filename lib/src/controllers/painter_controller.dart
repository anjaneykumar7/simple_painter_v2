// ignore_for_file: lines_longer_than_80_chars

import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
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
import 'package:flutter_painter/src/models/brush_model.dart';
import 'package:flutter_painter/src/models/position_model.dart';
import 'package:flutter_painter/src/models/size_model.dart';

/// Controller class for managing painter-related functionalities.
/// This class handles state management, drawing operations, erasing,
/// adding text or images, and other actions for a painting application.
class PainterController extends ValueNotifier<PainterControllerValue> {
  /// Constructor to initialize the controller with default or custom settings.
  PainterController({
    PainterSettings settings = const PainterSettings(),
    Uint8List? backgroundImage,
  }) : this.fromValue(
          PainterControllerValue(
            settings: settings,
            brushColor:
                settings.brush?.color ?? Colors.blue, // Default brush color
            brushSize: settings.brush?.size ?? 5, // Default brush size
            eraseSize: settings.erase?.size ?? 5, // Default erase size
          ),
          backgroundImage: backgroundImage,
        );

  /// Alternate constructor that initializes the controller with a specific value
  /// and optional background image.
  PainterController.fromValue(super.value, {Uint8List? backgroundImage})
      : background = PainterBackground(
          image: backgroundImage,
          height: value.settings.scale?.height ??
              0, // Height scaling for background
          width:
              value.settings.scale?.width ?? 0, // Width scaling for background
        );

  /// GlobalKey used to identify the repaint boundary for rendering images.
  final GlobalKey repaintBoundaryKey = GlobalKey();

  /// Stream controller for broadcasting events related to the painter.
  final StreamController<ControllerEvent> _eventController =
      StreamController<ControllerEvent>.broadcast();

  /// Background object for handling the painting canvas background.
  PainterBackground background = PainterBackground();

  /// Cached image of the background for performance improvements.
  ui.Image? cacheBackgroundImage;

  /// ValueNotifier to track changes in paint actions.
  ValueNotifier<PaintActions> changeActions =
      ValueNotifier<PaintActions>(PaintActions());

  /// Flags to determine the current state of the painter (drawing, erasing, etc.).
  bool isErasing = false;
  bool isDrawing = false;
  bool editingText = false;
  bool addingText = false;

  /// Renders the current painting as an image and returns it as a Uint8List.
  /// This can be used to save or share the painted content.
  Future<Uint8List?> renderImage() async {
    try {
      clearSelectedItem(); // Deselect any selected item before rendering.
      await Future.delayed(const Duration(milliseconds: 100), () {});
      final boundary = repaintBoundaryKey.currentContext!.findRenderObject()!
          as RenderRepaintBoundary;
      final image = await boundary.toImage();
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      return byteData?.buffer.asUint8List();
    } catch (e) {
      return null; // Return null if rendering fails.
    }
  }

  /// Adds a paint point to the current drawing path or performs erasing
  /// if the eraser mode is enabled.
  void addPaintPoint(DrawModel point) {
    if (isErasing) {
      // Save the state of paint paths before erasing begins.
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

  /// Ends the current drawing or erasing path, updating the state accordingly.
  void endPath() {
    if (!isErasing && value.currentPaintPath.toList().isNotEmpty) {
      value.paintPaths = value.paintPaths.toList()
        ..add(
          List.from(value.currentPaintPath.toList()),
        ); // Save the drawn path.
      addAction(
        ActionDraw(
          paintPath: value.currentPaintPath.toList(),
          listIndex: value.paintPaths.length - 1,
          timestamp: DateTime.now(),
          actionType: ActionType.draw,
        ),
      );
      value.currentPaintPath = value.currentPaintPath.toList()
        ..clear(); // Clear the path.
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

  /// Toggles the erasing mode. If enabled, disables the drawing mode.
  void toggleErasing() {
    isErasing = !isErasing;
    if (isErasing) {
      isDrawing = false;
    }
  }

  /// Toggles the drawing mode. If enabled, disables the erasing mode.
  void toggleDrawing() {
    isDrawing = !isDrawing;
    if (isDrawing) {
      isErasing = false;
    }
  }

  /// Internal method for erasing parts of the canvas.
  void _erase(DrawModel draw) {
    final position = draw.offset;
    final updatedPaths = <List<DrawModel?>>[];

    for (final path in value.paintPaths.toList()) {
      final updatedPath = <DrawModel?>[];

      var isInEraseRegion = false;
      for (var i = 0; i < path.length; i++) {
        final point = path[i];
        if (point == null) continue;

        // Check if the point is within the eraser's region.
        if (((point.offset - position).distance) <
            value.eraseSize + draw.strokeWidth) {
          isInEraseRegion = true;
        }

        if (isInEraseRegion) {
          if (i == 0 ||
              (i > 0 &&
                  (path[i - 1]!.offset - position).distance >=
                      value.eraseSize)) {
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

      if (updatedPath.isNotEmpty) {
        updatedPaths.add(updatedPath);
      }
    }

    value = value.copyWith(
      paintPaths: updatedPaths,
    ); // Update the state with erased paths.
  }

  /// Sets a background image for the painter.
  Future<void> setBackgroundImage(Uint8List imageData) async {
    cacheBackgroundImage = null;
    background.image = imageData;
  }

  /// Adds a text item to the painting canvas.
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

  /// Listens to events triggered by the controller and executes the provided callback.
  /// Returns a subscription that can be used to manage the listener.
  StreamSubscription<ControllerEvent> eventListener(
    void Function(ControllerEvent) onData,
  ) {
    return _eventController.stream.listen(onData);
  }

  /// Triggers an event for all listeners of the event stream.
  void triggerEvent(ControllerEvent event) {
    _eventController.add(event);
  }

  /// Adds an image to the painter as a new item, using the provided Uint8List.
  /// The image is inserted at the top of the items list, and an action is logged.
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

  /// Adds an action to the action history and updates the current change actions.
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

  /// Retrieves the layer index of the specified item.
  int getLayerIndex(PainterItem item) {
    return LayerService().getLayerIndex(item, value.items.toList());
  }

  /// Updates the position of an item in the items list at the specified index.
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

  /// Updates the rotation of an item in the items list at the specified index.
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

  /// Updates the size of an item in the items list at the specified index.
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

  // updates the action by changing the action index and updating the state
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

  // undoes the last action and updates the state
  void undo() {
    ActionsService().undo(changeActions, value.paintPaths, value, (items) {
      value = value.copyWith(items: items);
    }, (index) {
      changeActions.value = changeActions.value.copyWith(index: index);
    }, (pathList) {
      value = value.copyWith(paintPaths: pathList);
    });
  }

  // redoes the previously undone action and updates the state
  void redo() {
    ActionsService().redo(changeActions, value.paintPaths, value, (items) {
      value = value.copyWith(items: items);
    }, (index) {
      changeActions.value = changeActions.value.copyWith(index: index);
    }, (pathList) {
      value = value.copyWith(paintPaths: pathList);
    });
  }

  // updates the layer index for a given painter item
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

  // removes a painter item from the list based on layer index or selected item
  void removeItem({int? layerIndex}) {
    if (value.selectedItem == null && layerIndex == null) return;
    final itemsReversed = value.items.reversed.toList();
    var index = 0;
    if (layerIndex != null && layerIndex < itemsReversed.length + 1) {
      index = layerIndex;
    } else {
      index =
          value.items.length - 1 - _getItemIndexFromItem(value.selectedItem!);
    }
    if (index < 0) return;
    for (var i = 0; i < itemsReversed.length; i++) {
      if (i == index) {
      } else {}
    }
    final item = itemsReversed[index];
    itemsReversed.removeAt(index);
    for (var i = index; i < itemsReversed.length; i++) {
      itemsReversed[i] = itemsReversed[i].copyWith(
        layer: itemsReversed[i].layer.copyWith(index: i),
      );
    }
    value = value.copyWith(items: itemsReversed.reversed.toList());
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

  // adds a new shape to the canvas
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

  // clears the selected item in the canvas
  void clearSelectedItem() {
    value.selectedItem = null;
    value = value.copyWith();
  }

  // retrieves the index of a given painter item
  int _getItemIndexFromItem(PainterItem item) {
    final index = value.items.indexWhere((element) => element.id == item.id);
    return index;
  }

  // updates text-related properties for a TextItem
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

  // updates brush size or color
  void changeBrushValues({
    double? size,
    Color? color,
  }) {
    value = value.copyWith(
      brushSize: size ?? value.brushSize,
      brushColor: color ?? value.brushColor,
    );
  }

  // updates eraser size
  void changeEraseValues({
    double? size,
    Color? color,
  }) {
    value = value.copyWith(
      eraseSize: size ?? value.eraseSize,
    );
  }

  // updates properties for a ShapeItem
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

  // updates properties for an ImageItem
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

  // applies changes to a specific item and updates the state
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

/// This class is used to hold the values for the PainterController.
/// It manages the state of the drawing application, including settings,
/// drawn paths, selected items, and tool properties.
class PainterControllerValue {
  /// Constructor to initialize the controller's values.
  PainterControllerValue({
    required this.settings,
    this.scale,
    this.paintPaths = const <List<DrawModel?>>[],
    this.currentPaintPath = const <DrawModel?>[],
    this.paintPathsBeforeErasing = const <List<DrawModel?>>[],
    this.items = const <PainterItem>[],
    this.selectedItem,
    this.brushSize = 5,
    this.eraseSize = 5,
    this.brushColor = Colors.blue,
  });

  /// General painter settings.
  final PainterSettings settings;

  /// The scale of the canvas.
  final Size? scale;

  /// List of all paint paths (each path is a list of draw models).
  List<List<DrawModel?>> paintPaths = <List<DrawModel?>>[];

  /// The current paint path being drawn (not yet finalized).
  List<DrawModel?> currentPaintPath = <DrawModel?>[];

  /// List of paint paths before erasing (for undo/redo support).
  List<List<DrawModel?>> paintPathsBeforeErasing = <List<DrawModel?>>[];

  /// List of all items (shapes, images, text) on the canvas.
  List<PainterItem> items = <PainterItem>[];

  /// The currently selected item, if any.
  PainterItem? selectedItem;

  /// The size of the brush tool.
  final double brushSize;

  /// The size of the eraser tool.
  final double eraseSize;

  /// The color of the brush tool.
  final Color brushColor;

  /// Creates a copy of the current controller value with optional changes.
  PainterControllerValue copyWith({
    PainterSettings? settings,
    Size? scale,
    List<List<DrawModel?>>? paintPaths,
    List<DrawModel?>? currentPaintPath,
    List<List<DrawModel?>>? paintPathsBeforeErasing,
    List<PainterItem>? items,
    PainterItem? selectedItem,
    double? brushSize,
    double? eraseSize,
    Color? brushColor,
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
      brushSize: brushSize ?? this.brushSize,
      eraseSize: eraseSize ?? this.eraseSize,
      brushColor: brushColor ?? this.brushColor,
    );
  }
}
