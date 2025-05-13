part of 'painter_controller.dart';

extension PainterControllerImportExport on PainterController {
  Future<Map<String, dynamic>> exportPainter() async {
    return _toJson();
  }

  // Method to import PainterController from JSON data
  Future<bool> importPainter(Map<String, dynamic> data) async {
    try {
      // Create a snapshot of the current state before making changes
      final oldSnapshot = ImportPainterSnapshotModel(
        paintPaths: value.paintPaths,
        items: value.items,
        settings: PainterSettings(
          size: Size(value.settings.size.width, value.settings.size.height),
          brush: value.settings.brush != null
              ? BrushSettings(
                  color: value.settings.brush!.color,
                  size: value.settings.brush!.size)
              : null,
          erase: value.settings.erase != null
              ? EraseSettings(size: value.settings.erase!.size)
              : null,
        ),
        backgroundImage: background.image,
        brushSize: value.brushSize,
        eraseSize: value.eraseSize,
        brushColor: value.brushColor,
      );

      // Settings
      if (data.containsKey('settings')) {
        final settingsData = data['settings'] as Map<String, dynamic>;

        // Update settings
        if (settingsData.containsKey('size')) {
          final sizeData = settingsData['size'] as Map<String, dynamic>;
          final newSize = Size(
            sizeData['width'] as double,
            sizeData['height'] as double,
          );

          // Create a new PainterSettings
          final newSettings = PainterSettings(
            size: newSize,
            brush: settingsData.containsKey('brush') &&
                    settingsData['brush'] != null
                ? _createBrushSettings(
                    settingsData['brush'] as Map<String, dynamic>)
                : null,
            erase: settingsData.containsKey('erase') &&
                    settingsData['erase'] != null
                ? _createEraseSettings(
                    settingsData['erase'] as Map<String, dynamic>)
                : null,
          );

          // Update controller values
          value = PainterControllerValue(
            settings: newSettings,
            paintPaths: value.paintPaths,
            currentPaintPath: value.currentPaintPath,
            paintPathsBeforeErasing: value.paintPathsBeforeErasing,
            items: value.items,
            selectedItem: value.selectedItem,
            brushSize: value.brushSize,
            eraseSize: value.eraseSize,
            brushColor: value.brushColor,
          );
        }

        // Update brush and color settings
        if (data.containsKey('brushSize')) {
          changeBrushValues(
            size: data['brushSize'] as double,
            color: data.containsKey('brushColor')
                ? _hexToColor(data['brushColor'] as String)
                : value.brushColor,
          );
        }

        if (data.containsKey('eraseSize')) {
          changeEraseValues(size: data['eraseSize'] as double);
        }
      }

      // Paint Paths
      if (data.containsKey('paintPaths')) {
        final paths = _deserializePaintPaths(data['paintPaths'] as List);
        value = value.copyWith(paintPaths: paths);
      }

      // Items
      if (data.containsKey('items')) {
        final items = _deserializeItems(data['items'] as List);
        value = value.copyWith(items: items);
      }

      // Background
      if (data.containsKey('background')) {
        final bgData = data['background'] as Map<String, dynamic>;
        if (bgData.containsKey('width') && bgData.containsKey('height')) {
          background = PainterBackground(
            width: bgData['width'] as double,
            height: bgData['height'] as double,
            image:
                bgData.containsKey('imageData') && bgData['imageData'] != null
                    ? _base64ToUint8List(bgData['imageData'] as String)
                    : null,
          );
        }
      }

      // Create a snapshot of the updated state
      final newSnapshot = ImportPainterSnapshotModel(
        paintPaths: value.paintPaths,
        items: value.items,
        settings: PainterSettings(
          size: Size(value.settings.size.width, value.settings.size.height),
          brush: value.settings.brush != null
              ? BrushSettings(
                  color: value.settings.brush!.color,
                  size: value.settings.brush!.size)
              : null,
          erase: value.settings.erase != null
              ? EraseSettings(size: value.settings.erase!.size)
              : null,
        ),
        backgroundImage: background.image,
        brushSize: value.brushSize,
        eraseSize: value.eraseSize,
        brushColor: value.brushColor,
      );

      addAction(
        ActionImportPainter(
          newSnapshot: newSnapshot,
          oldSnapshot: oldSnapshot,
          timestamp: DateTime.now(),
          actionType: ActionType.importPainter,
        ),
      );
      return true;
    } catch (e) {
      return false;
    }
  }

  // Create brush settings
  BrushSettings _createBrushSettings(Map<String, dynamic> data) {
    return BrushSettings(
      color: _hexToColor(data['color'] as String),
      size: data['size'] as double,
    );
  }

  // Create erase settings
  EraseSettings _createEraseSettings(Map<String, dynamic> data) {
    return EraseSettings(
      size: data['size'] as double,
    );
  }

  // Paint paths deserialize
  List<List<DrawModel?>> _deserializePaintPaths(List pathsData) {
    return pathsData.map<List<DrawModel?>>((path) {
      return (path as List).map<DrawModel?>((point) {
        final pointData = point as Map<String, dynamic>;
        final offsetData = pointData['offset'] as Map<String, dynamic>;

        return DrawModel(
          offset: Offset(
            offsetData['x'] as double,
            offsetData['y'] as double,
          ),
          color: _hexToColor(pointData['color'] as String),
          strokeWidth: pointData['strokeWidth'] as double,
        );
      }).toList();
    }).toList();
  }

  // Items deserialize
  List<PainterItem> _deserializeItems(List itemsData) {
    return itemsData.map<PainterItem>((item) {
      final data = item as Map<String, dynamic>;
      final type = data['type'] as String?;

      // Position
      final posData = data['position'] as Map<String, dynamic>;
      final position = PositionModel(
        x: posData['x'] as double,
        y: posData['y'] as double,
      );

      // Layer
      final layerData = data['layer'] as Map<String, dynamic>;
      final layer = LayerSettings(
        index: layerData['index'] as int,
        title: layerData['name'] as String,
      );

      // Size
      SizeModel? size;
      if (data.containsKey('size') && data['size'] != null) {
        final sizeData = data['size'] as Map<String, dynamic>;
        size = SizeModel(
          width: sizeData['width'] as double,
          height: sizeData['height'] as double,
        );
      }

      final rotation = data['rotation'] as double;
      final enabled = data['enabled'] as bool;
      final id = data['id'] as String;

      // Parse alignment values for gradients
      AlignmentGeometry _parseAlignment(String alignmentStr) {
        if (alignmentStr.contains('Alignment.topLeft'))
          return Alignment.topLeft;
        if (alignmentStr.contains('Alignment.topCenter'))
          return Alignment.topCenter;
        if (alignmentStr.contains('Alignment.topRight'))
          return Alignment.topRight;
        if (alignmentStr.contains('Alignment.centerLeft'))
          return Alignment.centerLeft;
        if (alignmentStr.contains('Alignment.center')) return Alignment.center;
        if (alignmentStr.contains('Alignment.centerRight'))
          return Alignment.centerRight;
        if (alignmentStr.contains('Alignment.bottomLeft'))
          return Alignment.bottomLeft;
        if (alignmentStr.contains('Alignment.bottomCenter'))
          return Alignment.bottomCenter;
        if (alignmentStr.contains('Alignment.bottomRight'))
          return Alignment.bottomRight;
        return Alignment.centerLeft; // Default
      }

      // Create item based on type
      if (type == 'text') {
        final text = data['text'] as String;
        final textStyleData = data['textStyle'] as Map<String, dynamic>;

        // Get gradient properties with defaults
        final enableGradientColor = data.containsKey('enableGradientColor')
            ? data['enableGradientColor'] as bool
            : false;
        final gradientStartColor = data.containsKey('gradientStartColor')
            ? _hexToColor(data['gradientStartColor'] as String)
            : Colors.black;
        final gradientEndColor = data.containsKey('gradientEndColor')
            ? _hexToColor(data['gradientEndColor'] as String)
            : Colors.white;
        final gradientBegin = data.containsKey('gradientBegin')
            ? _parseAlignment(data['gradientBegin'] as String)
            : Alignment.centerLeft;
        final gradientEnd = data.containsKey('gradientEnd')
            ? _parseAlignment(data['gradientEnd'] as String)
            : Alignment.centerRight;

        // TextAlign parsing
        TextAlign _parseTextAlign(String alignStr) {
          if (alignStr.contains('TextAlign.left')) return TextAlign.left;
          if (alignStr.contains('TextAlign.center')) return TextAlign.center;
          if (alignStr.contains('TextAlign.right')) return TextAlign.right;
          if (alignStr.contains('TextAlign.justify')) return TextAlign.justify;
          if (alignStr.contains('TextAlign.start')) return TextAlign.start;
          if (alignStr.contains('TextAlign.end')) return TextAlign.end;
          return TextAlign.center; // Default
        }

        final textAlign = data.containsKey('textAlign')
            ? _parseTextAlign(data['textAlign'] as String)
            : TextAlign.center;

        return TextItem(
          id: id,
          text: text,
          position: position,
          layer: layer,
          size: size,
          rotation: rotation,
          enabled: enabled,
          textAlign: textAlign,
          textStyle: TextStyle(
            fontSize: textStyleData['fontSize'] as double,
            color: _hexToColor(textStyleData['color'] as String),
            backgroundColor:
                _hexToColor(textStyleData['backgroundColor'] as String),
          ),
          enableGradientColor: enableGradientColor,
          gradientStartColor: gradientStartColor,
          gradientEndColor: gradientEndColor,
          gradientBegin: gradientBegin,
          gradientEnd: gradientEnd,
        );
      } else if (type == 'image') {
        // Convert image item from base64 format
        Uint8List? imageData;
        if (data.containsKey('imageData') && data['imageData'] != null) {
          imageData = _base64ToUint8List(data['imageData'] as String);
        }

        // Get gradient properties with defaults
        final enableGradientColor = data.containsKey('enableGradientColor')
            ? data['enableGradientColor'] as bool
            : false;
        final gradientStartColor = data.containsKey('gradientStartColor')
            ? _hexToColor(data['gradientStartColor'] as String)
            : Colors.black;
        final gradientEndColor = data.containsKey('gradientEndColor')
            ? _hexToColor(data['gradientEndColor'] as String)
            : Colors.white;
        final gradientBegin = data.containsKey('gradientBegin')
            ? _parseAlignment(data['gradientBegin'] as String)
            : Alignment.centerLeft;
        final gradientEnd = data.containsKey('gradientEnd')
            ? _parseAlignment(data['gradientEnd'] as String)
            : Alignment.centerRight;
        final gradientOpacity = data.containsKey('gradientOpacity')
            ? (data['gradientOpacity'] as num).toDouble()
            : 0.5;

        return ImageItem(
          id: id,
          image: imageData ?? Uint8List(0),
          position: position,
          layer: layer,
          size: size,
          rotation: rotation,
          enabled: enabled,
          fit: data.containsKey('fit')
              ? _stringToBoxFit(data['fit'] as String)
              : BoxFit.contain,
          borderRadius: data.containsKey('borderRadius')
              ? _stringToBorderRadius(data['borderRadius'] as String)
              : BorderRadius.zero,
          borderColor: data.containsKey('borderColor')
              ? _hexToColor(data['borderColor'] as String)
              : Colors.transparent,
          borderWidth: data.containsKey('borderWidth')
              ? (data['borderWidth'] as num).toDouble()
              : 0,
          enableGradientColor: enableGradientColor,
          gradientStartColor: gradientStartColor,
          gradientEndColor: gradientEndColor,
          gradientBegin: gradientBegin,
          gradientEnd: gradientEnd,
          gradientOpacity: gradientOpacity,
        );
      } else if (type == 'shape') {
        return ShapeItem(
          id: id,
          shapeType: ShapeType.values.firstWhere(
            (element) => element.toString() == data['shapeType'],
            orElse: () => ShapeType.rectangle,
          ),
          position: position,
          layer: layer,
          size: size,
          rotation: rotation,
          enabled: enabled,
          backgroundColor: _hexToColor(data['backgroundColor'] as String),
          lineColor: _hexToColor(data['lineColor'] as String),
          thickness: data['thickness'] as double,
        );
      } else if (type == 'customWidget') {
        // Get gradient properties with defaults
        final enableGradientColor = data.containsKey('enableGradientColor')
            ? data['enableGradientColor'] as bool
            : false;
        final gradientStartColor = data.containsKey('gradientStartColor')
            ? _hexToColor(data['gradientStartColor'] as String)
            : Colors.black;
        final gradientEndColor = data.containsKey('gradientEndColor')
            ? _hexToColor(data['gradientEndColor'] as String)
            : Colors.white;
        final gradientBegin = data.containsKey('gradientBegin')
            ? _parseAlignment(data['gradientBegin'] as String)
            : Alignment.centerLeft;
        final gradientEnd = data.containsKey('gradientEnd')
            ? _parseAlignment(data['gradientEnd'] as String)
            : Alignment.centerRight;
        final gradientOpacity = data.containsKey('gradientOpacity')
            ? (data['gradientOpacity'] as num).toDouble()
            : 0.5;

        return CustomWidgetItem(
          id: id,
          widget:
              const SizedBox(), // Widget cannot be recreated, return empty widget
          position: position,
          layer: layer,
          size: size,
          rotation: rotation,
          enabled: enabled,
          borderRadius: data.containsKey('borderRadius')
              ? _stringToBorderRadius(data['borderRadius'] as String)
              : BorderRadius.zero,
          borderColor: data.containsKey('borderColor')
              ? _hexToColor(data['borderColor'] as String)
              : Colors.transparent,
          borderWidth: data.containsKey('borderWidth')
              ? (data['borderWidth'] as num).toDouble()
              : 0,
          enableGradientColor: enableGradientColor,
          gradientStartColor: gradientStartColor,
          gradientEndColor: gradientEndColor,
          gradientBegin: gradientBegin,
          gradientEnd: gradientEnd,
          gradientOpacity: gradientOpacity,
        );
      } else {
        // Default PainterItem
        return PainterItem(
          id: id,
          position: position,
          layer: layer,
          size: size,
          rotation: rotation,
          enabled: enabled,
        );
      }
    }).toList();
  }

  Map<String, dynamic> _toJson() {
    // Convert PainterController's value and properties to a JSON serializable Map
    final result = <String, dynamic>{
      'settings': _serializeSettings(value.settings),
      'background': _serializeBackground(background),
      'paintPaths': _serializePaintPaths(value.paintPaths),
      'items': _serializeItems(value.items),
      'brushSize': value.brushSize,
      'eraseSize': value.eraseSize,
      'brushColor': _colorToHex(value.brushColor),
    };

    return result;
  }

  // Serialize settings
  Map<String, dynamic> _serializeSettings(PainterSettings settings) {
    return {
      'size': {
        'width': settings.size.width,
        'height': settings.size.height,
      },
      'brush': settings.brush != null
          ? {
              'color': _colorToHex(settings.brush!.color),
              'size': settings.brush!.size,
            }
          : null,
      'erase': settings.erase != null
          ? {
              'size': settings.erase!.size,
            }
          : null,
    };
  }

  // Serialize background
  Map<String, dynamic> _serializeBackground(PainterBackground background) {
    final result = <String, dynamic>{
      'width': background.width,
      'height': background.height,
      'hasImage': background.image != null,
    };

    // If image exists, add it as base64
    if (background.image != null) {
      result['imageData'] = _uint8ListToBase64(background.image!);
    }

    return result;
  }

  // Serialize paint paths
  List<List<Map<String, dynamic>>> _serializePaintPaths(
      List<List<DrawModel?>> paintPaths) {
    return paintPaths.map((path) {
      return path
          .where((point) => point != null)
          .map((point) => {
                'offset': {'x': point!.offset.dx, 'y': point.offset.dy},
                'color': _colorToHex(point.color),
                'strokeWidth': point.strokeWidth,
              })
          .toList();
    }).toList();
  }

  // Serialize items
  List<Map<String, dynamic>> _serializeItems(List<PainterItem> items) {
    return items.map((item) {
      final Map<String, dynamic> baseItem = {
        'id': item.id,
        'enabled': item.enabled,
        'position': {
          'x': item.position.x,
          'y': item.position.y,
        },
        'rotation': item.rotation,
        'layer': {
          'index': item.layer.index,
          'name': item.layer.title,
        },
      };

      if (item.size != null) {
        baseItem['size'] = {
          'width': item.size!.width,
          'height': item.size!.height,
        };
      }

      // Add type-specific properties
      if (item is TextItem) {
        baseItem['type'] = 'text';
        baseItem['text'] = item.text;
        baseItem['textAlign'] = item.textAlign.toString();
        baseItem['textStyle'] = {
          'fontSize': item.textStyle.fontSize,
          'color': _colorToHex(item.textStyle.color ?? Colors.black),
          'backgroundColor':
              _colorToHex(item.textStyle.backgroundColor ?? Colors.transparent),
        };

        // Add gradient properties
        baseItem['enableGradientColor'] = item.enableGradientColor;
        baseItem['gradientStartColor'] = _colorToHex(item.gradientStartColor);
        baseItem['gradientEndColor'] = _colorToHex(item.gradientEndColor);
        baseItem['gradientBegin'] = item.gradientBegin.toString();
        baseItem['gradientEnd'] = item.gradientEnd.toString();
      } else if (item is ImageItem) {
        baseItem['type'] = 'image';
        baseItem['fit'] = item.fit.toString();
        baseItem['borderRadius'] = item.borderRadius.toString();
        baseItem['borderColor'] = _colorToHex(item.borderColor);
        baseItem['borderWidth'] = item.borderWidth;

        // Add gradient properties
        baseItem['enableGradientColor'] = item.enableGradientColor;
        baseItem['gradientStartColor'] = _colorToHex(item.gradientStartColor);
        baseItem['gradientEndColor'] = _colorToHex(item.gradientEndColor);
        baseItem['gradientBegin'] = item.gradientBegin.toString();
        baseItem['gradientEnd'] = item.gradientEnd.toString();
        baseItem['gradientOpacity'] = item.gradientOpacity;

        // Add image data as base64
        if (item.image.isNotEmpty) {
          baseItem['imageData'] = _uint8ListToBase64(item.image);
        }
      } else if (item is ShapeItem) {
        baseItem['type'] = 'shape';
        baseItem['shapeType'] = item.shapeType.toString();
        baseItem['backgroundColor'] = _colorToHex(item.backgroundColor);
        baseItem['lineColor'] = _colorToHex(item.lineColor);
        baseItem['thickness'] = item.thickness;
      } else if (item is CustomWidgetItem) {
        baseItem['type'] = 'customWidget';
        baseItem['borderRadius'] = item.borderRadius.toString();
        baseItem['borderColor'] = _colorToHex(item.borderColor);
        baseItem['borderWidth'] = item.borderWidth;

        // Add gradient properties
        baseItem['enableGradientColor'] = item.enableGradientColor;
        baseItem['gradientStartColor'] = _colorToHex(item.gradientStartColor);
        baseItem['gradientEndColor'] = _colorToHex(item.gradientEndColor);
        baseItem['gradientBegin'] = item.gradientBegin.toString();
        baseItem['gradientEnd'] = item.gradientEnd.toString();
        baseItem['gradientOpacity'] = item.gradientOpacity;
      }

      return baseItem;
    }).toList();
  }

  // Helper to convert Color to hex string
  String _colorToHex(Color color) {
    return '#${color.value.toRadixString(16).padLeft(8, '0')}';
  }

  // Helper to convert hex string to Color
  Color _hexToColor(String hexString) {
    hexString = hexString.toUpperCase().replaceAll('#', '');
    if (hexString.length == 6) {
      hexString = 'FF$hexString';
    }
    return Color(int.parse(hexString, radix: 16));
  }

  // Helper to convert Uint8List to base64 string
  String _uint8ListToBase64(Uint8List bytes) {
    return base64Encode(bytes);
  }

  // Helper to convert base64 string to Uint8List
  Uint8List _base64ToUint8List(String base64String) {
    return base64Decode(base64String);
  }

  // Helper to convert string to BoxFit
  BoxFit _stringToBoxFit(String fitString) {
    switch (fitString) {
      case 'BoxFit.fill':
        return BoxFit.fill;
      case 'BoxFit.contain':
        return BoxFit.contain;
      case 'BoxFit.cover':
        return BoxFit.cover;
      case 'BoxFit.fitWidth':
        return BoxFit.fitWidth;
      case 'BoxFit.fitHeight':
        return BoxFit.fitHeight;
      case 'BoxFit.none':
        return BoxFit.none;
      case 'BoxFit.scaleDown':
        return BoxFit.scaleDown;
      default:
        return BoxFit.contain;
    }
  }

  // Helper to convert string to BorderRadius
  BorderRadius _stringToBorderRadius(String radiusString) {
    // For simple conversion, apply the same value to all corners
    if (radiusString.contains('circular')) {
      // Extract number from string format BorderRadius.circular(10.0)
      final regex = RegExp(r'circular\(([0-9\.]+)\)');
      final match = regex.firstMatch(radiusString);
      if (match != null && match.groupCount >= 1) {
        final value = double.tryParse(match.group(1)!) ?? 0.0;
        return BorderRadius.circular(value);
      }
    }
    return BorderRadius.zero;
  }
}
