import 'dart:typed_data';
import 'dart:ui';

import 'package:simple_painter/simple_painter.dart';
import 'package:simple_painter/src/controllers/items/painter_item.dart';
import 'package:simple_painter/src/models/brush_model.dart';

/// Stores essential painter data without reference to the original controller
class ImportPainterSnapshot {
  /// Creates an immutable snapshot of painter data
  ///  with deep copies of all collections
  ImportPainterSnapshot({
    required List<List<DrawModel?>> paintPaths,
    required List<PainterItem> items,
    required this.settings,
    required Uint8List? backgroundImage,
    required this.brushSize,
    required this.eraseSize,
    required this.brushColor,
  })  :
        // Deep copy of paintPaths to ensure immutability
        _paintPaths = paintPaths
            .map(
              (path) => List<DrawModel?>.from(
                path.map(
                  (point) => point != null
                      ? DrawModel(
                          offset: Offset(point.offset.dx, point.offset.dy),
                          color: Color(point.color),
                          strokeWidth: point.strokeWidth,
                        )
                      : null,
                ),
              ),
            )
            .toList(),
        // Deep copy of items to ensure immutability
        _items = List<PainterItem>.from(items.map((item) => item.copyWith())),
        // Deep copy of background image if exists
        _backgroundImage = backgroundImage != null
            ? Uint8List.fromList(backgroundImage)
            : null;

  // Store as private fields to prevent external modification
  final List<List<DrawModel?>> _paintPaths;
  final List<PainterItem> _items;
  final Uint8List? _backgroundImage;
  final PainterSettings settings;
  final double brushSize;
  final double eraseSize;
  final Color brushColor;

  // Public getters that return copies to prevent modification
  List<List<DrawModel?>> get paintPaths => _paintPaths
      .map(
        (path) => List<DrawModel?>.from(
          path.map(
            (point) => point != null
                ? DrawModel(
                    offset: Offset(point.offset.dx, point.offset.dy),
                    color: Color(point.color),
                    strokeWidth: point.strokeWidth,
                  )
                : null,
          ),
        ),
      )
      .toList();

  List<PainterItem> get items =>
      List<PainterItem>.from(_items.map((item) => item.copyWith()));

  Uint8List? get backgroundImage =>
      _backgroundImage != null ? Uint8List.fromList(_backgroundImage) : null;
}
