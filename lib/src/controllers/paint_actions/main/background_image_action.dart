import 'dart:typed_data';

import 'package:simple_painter/src/controllers/paint_actions/paint_action.dart';

/// A paint action that represents changing the background image.
///
/// This action stores the new and old background images as [Uint8List]s,
/// allowing the background image to be changed and potentially reverted.
class ActionChangeBackgroundImage extends PaintAction {
  const ActionChangeBackgroundImage({
    required this.newImage,
    required this.oldImage,
    required super.timestamp,
    required super.actionType,
  });

  // The new background image to be set.
  final Uint8List? newImage;

  // The previous background image that was replaced.
  final Uint8List? oldImage;
}
